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

    public var touchActionID(default, null):Hash;
    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    var _targetsID:Array<Hash> = [];
    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();
    var _targetsState:RawTable<Hash, TargetState> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<Event, Array<EventListener>>> = new RawTable();
    var _targetsStateStyle:RawTable<Hash, TargetStyle<TStyle>> = new RawTable();
    var _targetsStartPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsHeldPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsMaxDistance:RawTable<Hash, Float> = new RawTable();
    var _targetsDirection:RawTable<Hash, DragDirection> = new RawTable();
    var _messagesListeners:RawTable<Hash, Array<Dynamic->Void>> = new RawTable();
    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();
    var _userdata:RawTable<Hash, Dynamic> = new RawTable();

    public function new(?touchActionID:HashOrString) {
        if (touchActionID == null)
            this.touchActionID = "touch".hash();
        else if (Std.isOfType(touchActionID, String))
            this.touchActionID = touchActionID.hash();
        else
            this.touchActionID = touchActionID;
    }

    // Override these.
    public function applyStateStyle(id:HashOrString, style:TStyle):Void {}
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

    public function style(ids:OneOrMany<HashOrString>, style:TargetStyle<TStyle>):MGuiBase<TTarget, TStyle> {
        for (id in ids.toArray()) {
            initTarget(id);

            _targetsStateStyle[id] = style;
            applyStateStyle(id, Reflect.field(style, _targetsState[id].toString()));
        }

        return this;
    }

    public function styleGroup(group:HashOrString, style:TargetStyle<TStyle>):MGuiBase<TTarget, TStyle> {
        if (_groups[group] != null)
            this.style(_groups[group], style);
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

    public function slider(id:HashOrString, length:Float, ?direction:DragDirection = X_RIGHT, ?thumbStyle:TargetStyle<TStyle>):MGuiBase<TTarget, TStyle> {
        initTarget(id);
        _targetsMaxDistance[id] = length;
        _targetsDirection[id] = direction;
        _targetsStartPos[id] = getPos(id);
        if (thumbStyle != null)
            style(id, thumbStyle);
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
            if (!_targetsState[id].touched)
                setState(id, HOVERED);

        } else {
            if (_targetsState[id].touched)
                setState(id, UNTOUCHED);
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (action.pressed) {
            if (pointerPick(id)) {
                _targetsTapInited[id] = true;
                setState(id, PRESSED);
                if (_targetsDirection[id] != null)
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
        if (_targetsStartPos[id] == null)
            _targetsStartPos[id] = getPos(id);
        if (_targetsHeldPos[id] == null)
            _targetsHeldPos[id] = Vmath.vector3();

        var pos = getPos(id);
        _targetsHeldPos[id].x = pointerX - pos.x;
        _targetsHeldPos[id].y = pointerY - pos.y;

        setState(id, DRAGGED);
    }

    function updateDrag(id:Hash):Void {
        var pos = Vmath.vector3();
        var start = _targetsStartPos[id];
        var maxDistance = _targetsMaxDistance[id];
        switch (_targetsDirection[id]) {
            case X_RIGHT:
                pos.x = pointerX - _targetsHeldPos[id].x;
                if (start != null) {
                    if (pos.x < start.x)
                        pos.x = start.x;
                    else if (maxDistance != null && pos.x > start.x + maxDistance)
                        pos.x = start.x + maxDistance;
                }
                setPos(id, pos);
                
            case X_LEFT:
                pos.x = pointerX - _targetsHeldPos[id].x;
                if (start != null) {
                    if (pos.x > start.x)
                        pos.x = start.x;
                    else if (maxDistance != null && pos.x < start.x - maxDistance)
                        pos.x = start.x - maxDistance;
                }
                setPos(id, pos);
        }
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
        applyStateStyle(id, getStateStyle(id));

        dispatch(id, STATE(null));
        dispatch(id, STATE(state));
    }

    function initTarget(id:Hash):Void {
        if (_targetsID.indexOf(id) > -1)
            return;

        _targetsID.push(id);
        _targetsTapInited[id] = false;
        _targetsListeners[id] = new RawTable();
        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
    }

    public inline function pointerPick(id:Hash):Bool {
        return pick(id, pointerX, pointerY);
    }

    function getStateStyle(id:Hash):TStyle {
        var style = _targetsStateStyle[id];
        if (style == null)
            return null;

        return switch (_targetsState[id]) {
            case UNTOUCHED: style.untouched;
            case HOVERED:   style.hovered;
            case PRESSED:   style.pressed;
            case DRAGGED:   style.dragged;
            case SLEEPING:  style.sleeping;
        }
    }

}

@:forward
abstract UserDataMap(Map<Hash, Dynamic>) from Map<Hash, Dynamic> {

    @:from static inline function fromStringMap(map:Map<String, Dynamic>):UserDataMap {
        return [ for (key => style in map) key.hash() => style ];
    }
    
}