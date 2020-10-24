package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.HashOrString;
import ixia.defold.gui.m.Event;
import ixia.defold.gui.m.TargetState;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;

class MGuiBase<TTarget, TStyle> {

    public var event(default, null):EventData<TTarget>;
    var _eventData:EventData<TTarget> = new EventData();

    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    
    var _targetsID:Array<Hash> = [];
    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();
    var _targetsState:RawTable<Hash, TargetState> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<Event, Array<Void->Void>>> = new RawTable();
    var _targetsStateStyle:RawTable<Hash, RawTable<TargetState, TStyle>> = new RawTable();
    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();

    public function new() {}

    // Override these.
    function idToTarget(id:HashOrString):TTarget return null;
    function pick(id:HashOrString, x:Float, y:Float):Bool return false;
    public function applyStyle(target:TTarget, style:TStyle):Void {}

    //

    public function sub(ids:OneOrMany<HashOrString>, listeners:Map<Event, Void->Void>):MGuiBase<TTarget, TStyle> {
        for (id in ids.toArray()) {
            initTarget(id);

            for (event => listener in listeners) {
                if (_targetsListeners[id][event] == null)
                    _targetsListeners[id][event] = [];

                var addedIndex = _targetsListeners[id][event].indexOf(listener);
                if (addedIndex > -1)
                    _targetsListeners[id][event].splice(addedIndex, 1);
                _targetsListeners[id][event].push(listener);
            }
        }

        return this;
    }

    public function style(ids:OneOrMany<HashOrString>, styles:Map<TargetState, TStyle>):MGuiBase<TTarget, TStyle> {
        for (id in ids.toArray()) {
            initTarget(id);

            for (state => style in styles) {
                _targetsStateStyle[id][state] = style;
                if (_targetsState[id] == state)
                    applyStyle(idToTarget(id), style);
            }
        }
        return this;
    }

    public function group(groups:OneOrMany<HashOrString>, ids:OneOrMany<HashOrString>):MGuiBase<TTarget, TStyle> {
        for (groupID in groups.toArray()) {
            if (_groups[groupID] == null)
                _groups[groupID] = [];
            
            for (id in ids.toArray()) {
                if (_groups[groupID].indexOf(id) == -1)
                    _groups[groupID].push(id);
            }
        }
        return this;
    }

    public function handleInput(actionID:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Bool {
        if (actionID == null) {
            pointerX = action.x;
            pointerY = action.y;

            for (id in _targetsID) {
                if (isAwake(id))
                    handleTargetPointerMove(id, action, scriptData);
            }

        } else if (actionID == Defold.hash("touch")) {
            pointerX = action.x;
            pointerY = action.y;
            
            if (action.pressed)
                pointerState = JUST_PRESSED;
            else if (action.released)
                pointerState = JUST_PRESSED;

            for (id in _targetsID) {
                if (isAwake(id))
                    handleTargetPressOrRelease(id, action, scriptData);
            }

            if (action.pressed)
                pointerState = PRESSED;
            else if (action.released)
                pointerState = RELEASED;
        }

        return false;
    }

    function handleTargetPointerMove(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(id, pointerX, pointerY)) {
            if (!_targetsState[id].isIn())
                setState(id, HOVERED);

        } else {
            if (_targetsState[id].isIn())
                setState(id, UNTOUCHED);
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(id, pointerX, pointerY)) {
            if (action.pressed) {
                _targetsTapInited[id] = true;
                setState(id, PRESSED);
            
            } else if (action.released) {
                if (_targetsTapInited[id]) {
                    _targetsTapInited[id] = false;
                    dispatch(id, TAP, action);
                }
                if (isAwake(id))
                    setState(id, HOVERED);
            }
        }
    }

    public function dispatch(id:Hash, event:Event, ?action:ScriptOnInputAction):Void {
        if (_targetsListeners[id][event] == null)
            return;

        _eventData.id = id;
        _eventData.target = idToTarget(id);
        _eventData.event = event;
        _eventData.action = action;
        this.event = _eventData;
        for (listener in _targetsListeners[id][event])
            listener();
        _eventData.clear();
        this.event = null;
    }

    public function wake(id:HashOrString):Void {
        initTarget(id);
        
        if (_targetsState[id] != SLEEPING)
            return;

        setState(id, pick(id, pointerX, pointerY) ? HOVERED : UNTOUCHED);
        dispatch(id, WAKE);
    }

    public function wakeGroup(group:HashOrString):Void {
        for (id in _groups[group])
            wake(id);
    }

    public function sleep(id:HashOrString):Void {
        if (_targetsState[id] == SLEEPING)
            return;

        setState(id, SLEEPING);
    }

    public function sleepGroup(group:HashOrString):Void {
        for (id in _groups[group])
            sleep(id);
    }

    public inline function isAwake(id:Hash):Bool {
        return _targetsState[id] != null && _targetsState[id] != SLEEPING;
    }

    public inline function getState(id:HashOrString):TargetState {
        return _targetsState[id];
    }

    function setState(id:HashOrString, state:TargetState):Void {
        if (_targetsState[id] == state)
            return;

        _targetsState[id] = state;
        if (_targetsStateStyle[id][state] != null)
            applyStyle(idToTarget(id), _targetsStateStyle[id][state]);

        dispatch(id, STATE(null));
        dispatch(id, STATE(state));
    }

    function initTarget(id:Hash):Void {
        if (_targetsID.indexOf(id) > -1)
            return;

        _targetsID.push(id);
        _targetsTapInited[id] = false;
        _targetsListeners[id] = new RawTable();
        _targetsStateStyle[id] = new RawTable();
        setState(id, pick(id, pointerX, pointerY) ? HOVERED : UNTOUCHED);
    }

}