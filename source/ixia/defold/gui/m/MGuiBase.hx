package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import haxe.ds.Either;
import ixia.defold.gui.m.TargetPointerState;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;

class MGuiBase<TTarget, TStyle> {

    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    
    var _targetsID:Array<Hash> = [];
    var _targetsState:RawTable<Hash, TargetPointerState> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<Event, Array<Listener<TTarget>>>> = new RawTable();
    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();

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

    function initTarget(id:Hash):Void {
        _targetsID.push(id);
        _targetsState[id] = OUT;
        _targetsListeners[id] = new RawTable();
        _targetsTapInited[id] = false;
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
            if (!_targetsState[id].isIn()) {
                _targetsState[id] = HOVER;
                dispatch(id, ROLL_IN, action);
            }
        } else {
            if (_targetsState[id].isIn()) {
                _targetsState[id] = OUT;
                dispatch(id, ROLL_OUT, action);
            }
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(id, pointerX, pointerY)) {
            if (action.pressed) {
                _targetsTapInited[id] = true;
                _targetsState[id] = DOWN;
                dispatch(id, PRESS, action);
            
            } else if (action.released) {
                if (_targetsTapInited[id]) {
                    _targetsTapInited[id] = false;
                    dispatch(id, TAP, action);
                }

                _targetsState[id] = HOVER;
                dispatch(id, RELEASE, action);
            }
        }
    }

    public function dispatch(id:Hash, event:Event, ?action:ScriptOnInputAction):Void {
        if (_targetsListeners[id][event] == null)
            return;

        var target = idToTarget(id);
        for (listener in _targetsListeners[id][event])
            listener(target, event, action);
    }

    public inline function isActive(id:Hash):Bool {
        return _targetsState[id] != null && _targetsState[id] != DEACTIVATED;
    }

    public function activate(id:Hash):Void {
        if (_targetsState[id] == null)
            initTarget(id);
        
        if (_targetsState[id] != DEACTIVATED)
            return;

        _targetsState[id] = pick(id, pointerX, pointerY) ? HOVER : OUT;
        dispatch(id, ACTIVATE);
    }

    public function deactivate(id:Hash):Void {
        if (_targetsState[id] == DEACTIVATED)
            return;

        _targetsState[id] = DEACTIVATED;
        dispatch(id, DEACTIVATE);
    }

    public inline function getState(id:Hash):TargetPointerState {
        return _targetsState[id];
    }

}