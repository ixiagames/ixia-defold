package ixia.defold.mgui;

import ixia.ds.OneOfTwo;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import haxe.ds.Either;
import ixia.defold.mgui.TargetPointerState;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;

class MGuiBase<TTarget, TStyle> {

    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    
    var _targetsID:Array<Hash> = [];
    var _targetsIDState:RawTable<Hash, TargetPointerState> = new RawTable();
    var _targetsIDListeners:RawTable<Hash, RawTable<Event, Array<Listener<TTarget>>>> = new RawTable();
    var _targetsIDTapInited:RawTable<Hash, Bool> = new RawTable();

    public function new() {}

    // Override these.
    function idToTarget(id:Hash):TTarget return null;
    function pick(id:Hash, x:Float, y:Float):Bool return false;

    //

    public function sub(ids:OneOrMany<Hash>, events:OneOrMany<Event>, listener:Listener<TTarget>):MGuiBase<TTarget, TStyle> {
        var ids:Array<Hash> = switch(ids) {
            case Left(id): [ id ];
            case Right(ids): ids;
        }
        var events:Array<Event> = switch(events) {
            case Left(event): [ event ];
            case Right(events): events;
        }
        for (id in ids) {
            if (_targetsID.indexOf(id) == -1)
                initTarget(id);

            for (event in events) {
                if (_targetsIDListeners[id][event] == null)
                    _targetsIDListeners[id][event] = [];

                var addedIndex = _targetsIDListeners[id][event].indexOf(listener);
                if (addedIndex > -1)
                    _targetsIDListeners[id][event].splice(addedIndex, 1);
                _targetsIDListeners[id][event].push(listener);
            }
        }

        return this;
    }

    function initTarget(id:Hash):Void {
        _targetsID.push(id);
        _targetsIDState[id] = OUT;
        _targetsIDListeners[id] = new RawTable();
        _targetsIDTapInited[id] = false;
    }

    public function handleInput(actionID:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Bool {
        if (actionID == null) {
            pointerX = action.x;
            pointerY = action.y;

            for (id in _targetsID) {
                if (isActive(id))
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
                if (isActive(id))
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
            if (!_targetsIDState[id].isIn()) {
                _targetsIDState[id] = HOVER;
                dispatch(id, ROLL_IN, action);
            }
        } else {
            if (_targetsIDState[id].isIn()) {
                _targetsIDState[id] = OUT;
                dispatch(id, ROLL_OUT, action);
            }
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(id, action.x, action.y)) {
            if (action.pressed) {
                _targetsIDTapInited[id] = true;
                _targetsIDState[id] = DOWN;
                dispatch(id, PRESS, action);
            
            } else if (action.released) {
                if (_targetsIDTapInited[id]) {
                    _targetsIDTapInited[id] = false;
                    dispatch(id, TAP, action);
                }

                _targetsIDState[id] = HOVER;
                dispatch(id, RELEASE, action);
            }
        }
    }

    public function dispatch(id:Hash, event:Event, ?action:ScriptOnInputAction):Void {
        if (_targetsIDListeners[id][event] == null)
            return;

        var target = idToTarget(id);
        for (listener in _targetsIDListeners[id][event])
            listener(target, event, action);
    }

    public inline function isActive(id:Hash):Bool {
        return _targetsIDState[id] != null && _targetsIDState[id] != DEACTIVATED;
    }

    public function activate(id:Hash):Void {
        if (_targetsIDState[id] == null)
            initTarget(id);
        
        if (_targetsIDState[id] != DEACTIVATED)
            return;

        _targetsIDState[id] = pick(id, pointerX, pointerY) ? HOVER : OUT;
        dispatch(id, ACTIVATE);
    }

    public function deactivate(id:Hash):Void {
        if (_targetsIDState[id] == DEACTIVATED)
            return;

        _targetsIDState[id] = DEACTIVATED;
        dispatch(id, DEACTIVATE);
    }

    public inline function getState(id:Hash):TargetPointerState {
        return _targetsIDState[id];
    }

}