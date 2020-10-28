package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.HashOrString;
import defold.types.Message;
import defold.types.Url;
import defold.types.Vector3;
import defold.Vmath;
import haxe.extern.EitherType;
import ixia.defold.gui.m.Event;
import ixia.defold.gui.m.TargetState;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;
using Defold;

class MGuiBase<TTarget, TStyle> {

    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    var _targetsID:Array<Hash> = [];
    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();
    var _targetsState:RawTable<Hash, TargetState> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<Event, Array<EventListener>>> = new RawTable();
    var _targetsStateStyle:RawTable<Hash, RawTable<TargetState, TStyle>> = new RawTable();
    var _targetsDragStartPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsDragRelPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsDragMaxDistance:RawTable<Hash, Float> = new RawTable();
    var _targetsDragAxis:RawTable<Hash, DragAxis> = new RawTable();
    var _messagesListeners:RawTable<Hash, Array<Dynamic->Void>> = new RawTable();
    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();
    var _userdata:RawTable<Hash, Dynamic> = new RawTable();

    public function new() {}

    // Override these.
    public function applyStyle(id:HashOrString, style:TStyle):Void {}
    function idToTarget(id:HashOrString):TTarget return null;
    function pick(id:HashOrString, x:Float, y:Float):Bool return false;
    function getPos(id:HashOrString):Vector3 return null;
    function setPos(id:HashOrString, pos:Vector3):Void {}

    //

    public function sub(ids:OneOrMany<HashOrString>, listeners:Map<Event, EventListener>):MGuiBase<TTarget, TStyle> {
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

    public function subMes<T>(message:Message<T>, listener:EitherType<Void->Void, T->Void>):MGuiBase<TTarget, TStyle> {
        if (_messagesListeners[cast message] == null)
            _messagesListeners[cast message] = [];

        var addedIndex = _messagesListeners[cast message].indexOf(listener);
        if (addedIndex > -1)
            _messagesListeners[cast message].splice(addedIndex, 1);
        _messagesListeners[cast message].push(listener);

        return this;
    }

    public function style(ids:OneOrMany<HashOrString>, styles:Map<TargetState, TStyle>):MGuiBase<TTarget, TStyle> {
        for (id in ids.toArray()) {
            initTarget(id);

            for (state => style in styles) {
                _targetsStateStyle[id][state] = style;
                if (_targetsState[id] == state)
                    applyStyle(id, style);
            }
        }

        return this;
    }

    public function styleGroup(group:HashOrString, styles:Map<TargetState, TStyle>):MGuiBase<TTarget, TStyle> {
        if (_groups[group] != null)
            style(_groups[group], styles);
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

    public function map(dataMap:UserDataMap):MGuiBase<TTarget, TStyle> {
        for (id => data in dataMap)
            _userdata[id] = data;
        return this;
    }

    public function set(dataID:HashOrString, data:Dynamic):MGuiBase<TTarget, TStyle> {
        _userdata[dataID] = data;
        return this;
    }

    public inline function get<T>(dataID:HashOrString):T {
        return _userdata[dataID];
    }

    public function slider(id:HashOrString, length:Float, ?axis:DragAxis = X, ?thumbStyles:Map<TargetState, TStyle>):MGuiBase<TTarget, TStyle> {
        initTarget(id);
        _targetsDragMaxDistance[id] = length;
        _targetsDragAxis[id] = axis;
        _targetsDragStartPos[id] = getPos(id);
        if (thumbStyles != null)
            style(id, thumbStyles);
        return this;
    }

    public function input(actionID:Hash, action:ScriptOnInputAction, ?scriptData:Dynamic):Bool {
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
        if (_targetsState[id].dragged) {
            updateDrag(id);

        } else if (pointerPick(id)) {
            if (!_targetsState[id].isIn())
                setState(id, HOVERED);

        } else {
            if (_targetsState[id].isIn())
                setState(id, UNTOUCHED);
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (action.pressed) {
            if (pointerPick(id)) {
                _targetsTapInited[id] = true;
                setState(id, PRESSED);
                if (_targetsDragAxis[id] != null)
                    startDrag(id);
            }
        } else if (action.released) {
            if (pointerPick(id)) {
                if (_targetsTapInited[id]) {
                    _targetsTapInited[id] = false;
                    dispatch(id, TAP, action);
                }
                if (isAwake(id))
                    setState(id, HOVERED);
            }

            if (_targetsState[id].dragged)
                setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
        }
    }

    function startDrag(id:Hash):Void {
        if (_targetsDragStartPos[id] == null)
            _targetsDragStartPos[id] = getPos(id);
        if (_targetsDragRelPos[id] == null)
            _targetsDragRelPos[id] = Vmath.vector3();

        var pos = getPos(id);
        _targetsDragRelPos[id].x = pointerX - pos.x;
        _targetsDragRelPos[id].y = pointerY - pos.y;

        setState(id, DRAGGED);
    }

    function updateDrag(id:Hash):Void {
        var pos = Vmath.vector3();
        pos.x = pointerX - _targetsDragRelPos[id].x;
        pos.y = pointerY - _targetsDragRelPos[id].y;
        setPos(id, pos);
    }

    public function message<T>(messageID:Message<T>, ?message:T, ?sender:Url):Void {
        if (_messagesListeners[cast messageID] != null) {
            for (listener in _messagesListeners[cast messageID])
                listener(message);
        }
    }

    public function dispatch(id:Hash, event:Event, ?action:ScriptOnInputAction):Void {
        if (_targetsListeners[id][event] == null)
            return;

        for (listener in _targetsListeners[id][event])
            listener.call(id, event, action);
    }

    public function wake(id:HashOrString):Void {
        initTarget(id);
        
        if (_targetsState[id] != SLEEPING)
            return;

        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
        dispatch(id, WAKE);
    }

    public function wakeGroup(group:HashOrString):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                wake(id);
        }
    }

    public function sleep(id:HashOrString):Void {
        if (_targetsState[id] == SLEEPING)
            return;

        setState(id, SLEEPING);
    }

    public function sleepGroup(group:HashOrString):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                sleep(id);
        }
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
            applyStyle(id, _targetsStateStyle[id][state]);

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
        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
    }

    public inline function pointerPick(id:Hash):Bool {
        return pick(id, pointerX, pointerY);
    }

}

@:forward
abstract UserDataMap(Map<Hash, Dynamic>) from Map<Hash, Dynamic> {

    @:from static inline function fromStringMap(map:Map<String, Dynamic>):UserDataMap {
        return [ for (key => style in map) key.hash() => style ];
    }
    
}