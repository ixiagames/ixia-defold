package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import ixia.defold.gui.m.TargetState;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;

class MGuiBase<TTarget, TStyle> {

    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    
    var _targetsID:Array<Hash> = [];
    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();
    var _targetsState:RawTable<Hash, TargetState> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<Event, Array<Listener<TTarget>>>> = new RawTable();
    var _targetsStateStyle:RawTable<Hash, RawTable<TargetState, TStyle>> = new RawTable();

    public function new() {}

    // Override these.
    function idToTarget(id:Hash):TTarget return null;
    function pick(id:Hash, x:Float, y:Float):Bool return false;
    public function applyStyle(ids:OneOrMany<Hash>, style:TStyle):Void {}

    //

    public function sub(ids:OneOrMany<Hash>, events:OneOrMany<Event>, listener:Listener<TTarget>):MGuiBase<TTarget, TStyle> {
        var ids = ids.toArray();
        var events = events.toArray();
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
        _targetsTapInited[id] = false;
        _targetsListeners[id] = new RawTable();
        _targetsStateStyle[id] = new RawTable();
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
                setState(id, HOVER);
                dispatch(id, ROLL_IN, action);
            }
        } else {
            if (_targetsState[id].isIn()) {
                setState(id, OUT);
                dispatch(id, ROLL_OUT, action);
            }
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(id, pointerX, pointerY)) {
            if (action.pressed) {
                _targetsTapInited[id] = true;
                setState(id, DOWN);
                dispatch(id, PRESS, action);
            
            } else if (action.released) {
                if (_targetsTapInited[id]) {
                    _targetsTapInited[id] = false;
                    dispatch(id, TAP, action);
                }

                setState(id, HOVER);
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

        setState(id, pick(id, pointerX, pointerY) ? HOVER : OUT);
        dispatch(id, ACTIVATE);
    }

    public function deactivate(id:Hash):Void {
        if (_targetsState[id] == DEACTIVATED)
            return;

        setState(id, DEACTIVATED);
        dispatch(id, DEACTIVATE);
    }

    public inline function getState(id:Hash):TargetState {
        return _targetsState[id];
    }

    public function style(ids:OneOrMany<Hash>, states:OneOrMany<TargetState>, style:TStyle):Void {
        var ids = ids.toArray();
        var states = states.toArray();
        for (id in ids) {
            if (_targetsID.indexOf(id) == -1)
                initTarget(id);

            for (state in states) {
                _targetsStateStyle[id][state] = style;
                if (_targetsState[id] == state)
                    applyStyle(id, style);
            }
        }
    }

    function setState(id:Hash, state:TargetState):Void {
        if (_targetsState[id] == state)
            return;

        _targetsState[id] = state;
        if (_targetsStateStyle[id][state] != null)
            applyStyle(id, _targetsStateStyle[id][state]);
    }

}