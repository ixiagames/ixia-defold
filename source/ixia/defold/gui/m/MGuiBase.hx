package ixia.defold.gui.m;

import defold.Msg;
import defold.Timer;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Message;
import defold.types.Url;
import defold.types.Vector3;
import haxe.PosInfos;
import haxe.ds.Either;
import haxe.extern.EitherType;
import ixia.defold.gui.m.TargetEvent;
import ixia.defold.gui.m.TargetEventListener.TargetEventListeners;
import ixia.defold.gui.m.TargetState;
import ixia.defold.types.Hash;
import ixia.defold.types.Hashes;
import ixia.ds.OneOfTwo;
import ixia.lua.RawTable;

using Defold;
using Math;
using ixia.math.Math;

class MGuiBase<TTarget, TStyle> {

    public var touchActionId(default, null):Hash;
    public var pointerMoveActionId(default, null):Hash;
    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;

    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();
    var _targetsId:Array<Hash> = [];

    var _targetsTapInited:RawTable<Hash, Bool> = new RawTable();
    var _targetsState:RawTable<Hash, TargetState> = new RawTable();
    var _targetsStateStyle:RawTable<Hash, TargetStyle<TStyle>> = new RawTable();
    var _targetsListeners:RawTable<Hash, RawTable<TargetEvent, Array<TargetEventListener>>> = new RawTable();
    
    var _targetsStartPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsHeldPos:RawTable<Hash, Vector3> = new RawTable();
    var _targetsTrackLength:RawTable<Hash, Float> = new RawTable();
    var _targetsDirection:RawTable<Hash, DragDirection> = new RawTable();

    var _targetsMin:RawTable<Hash, Float> = new RawTable();
    var _targetsMax:RawTable<Hash, Float> = new RawTable();
    var _targetsValue:RawTable<Hash, Float> = new RawTable();
    var _targetsStepValue:RawTable<Hash, Float> = new RawTable();
    var _targetsNumSteps:RawTable<Hash, Int> = new RawTable();
    var _targetsPercent:RawTable<Hash, Float> = new RawTable();
    
    var _userdata:RawTable<Hash, Dynamic> = new RawTable();
    var _dataListeners:RawTable<Hash, Array<DataListener>> = new RawTable();
    var _messagesListeners:RawTable<Hash, Array<Dynamic->Void>> = new RawTable();
    var _inputsListeners:Array<InputActionListener>;
    var _actionsListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();
    var _pressesListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();
    var _releasesListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();

    public function new(?touchActionId:Hash, ?pointerMoveActionId:Hash, ?acquiresInputFocus:Bool = true) {
        this.pointerMoveActionId = pointerMoveActionId != null ? pointerMoveActionId : "pointer_move".hash();
        this.touchActionId = touchActionId != null ? touchActionId : "touch".hash();

        if (acquiresInputFocus)
            acquireInputFocus();
    }

    // Override these.
    public function applyStateStyle(id:Hash, style:TStyle):Void {}
    function idToTarget(id:Hash):TTarget return null;
    function pick(id:Hash, x:Float, y:Float):Bool return false;
    function getPos(id:Hash):Vector3 return null;
    function setPos(id:Hash, pos:Vector3):Void {}

    //

    /**
     * Remove a target from the interaction list.
     * Remove its listeners & styles but leave other data (like min, max, percent...).
     */
    public function removeInteraction(id:Hash):Void {
        if (_targetsId.remove(id)) {
            _targetsTapInited[id] = null;
            _targetsListeners[id] = null;
            _targetsStateStyle[id] = null;
            _targetsState[id] = null;
        }
    }

    function initTarget(id:Hash):Void {
        if (exists(id))
            return;

        _targetsId.push(id);
        _targetsTapInited[id] = false;
        _targetsListeners[id] = new RawTable();
        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
    }

    public inline function exists(id:Hash):Bool {
        return _targetsId.indexOf(id) > -1;
    }

    public function config(ids:Hashes, style:TargetStyle<TStyle>, listeners:TargetEventListeners):MGuiBase<TTarget, TStyle> {
        this.style(ids, style);
        sub(ids, listeners);
        return this;
    }

    public function sub(ids:Hashes, listeners:TargetEventListeners):MGuiBase<TTarget, TStyle> {
        for (id in ids) {
            initTarget(id);

            for (field in Reflect.fields(listeners)) {
                var listener = Reflect.field(listeners, field);
                if (listener == null)
                    continue;

                var event = TargetEvent.fromString(field);
                if (_targetsListeners[id][event] == null)
                    _targetsListeners[id][event] = [];
                else {
                    var addedIndex = _targetsListeners[id][event].indexOf(listener);
                    if (addedIndex > -1)
                        _targetsListeners[id][event].splice(addedIndex, 1);
                }
                _targetsListeners[id][event].push(listener);
            }
        }
        return this;
    }

    public function unsub(ids:Hashes, listeners:TargetEventListeners):Void {
        for (id in ids) {
            if (_targetsListeners[id] == null)
                continue;

            for (field in Reflect.fields(listeners)) {
                var listener = Reflect.field(listeners, field);
                if (listener == null)
                    continue;

                var event = TargetEvent.fromString(field);
                if (_targetsListeners[id][event] == null)
                    continue;

                _targetsListeners[id][event].remove(listener);
            }
        }
    }

    public function subGroup(group:Hash, listeners:TargetEventListeners):MGuiBase<TTarget, TStyle> {
        if (_groups[group] != null)
            sub(cast _groups[group], listeners);
        return this;
    }

    public function subMes<T>(message:Message<T>, listener:EitherType<Void->Void, T->Void>):MGuiBase<TTarget, TStyle> {
        if (_messagesListeners[cast message] == null)
            _messagesListeners[cast message] = [];
        else {
            var addedIndex = _messagesListeners[cast message].indexOf(listener);
            if (addedIndex > -1)
                _messagesListeners[cast message].splice(addedIndex, 1);
        }
        _messagesListeners[cast message].push(listener);
        return this;
    }

    public function subInputs(listener:InputActionListener):MGuiBase<TTarget, TStyle> {
        if (_inputsListeners == null)
            _inputsListeners = [];
        else {
            var addedIndex = _inputsListeners.indexOf(listener);
            if (addedIndex > -1)
                _inputsListeners.splice(addedIndex, 1);
        }
        _inputsListeners.push(listener);
        return this;
    }

    public function subAction(actionId:Hash, ?pressed:Bool, listener:InputActionListener):MGuiBase<TTarget, TStyle> {
        var listeners = pressed == null ? _actionsListeners : (pressed ? _pressesListeners : _releasesListeners);
        if (listeners[actionId] == null)
            listeners[actionId] = [];
        else {
            var addedIndex = listeners[actionId].indexOf(listener);
            if (addedIndex > -1)
                listeners[actionId].splice(addedIndex, 1);
        }
        listeners[actionId].push(listener);
        return this;
    }

    public function unsubAction(actionId:Hash, ?pressed:Bool, listener:InputActionListener):Bool {
        var listeners = pressed == null ? _actionsListeners : (pressed ? _pressesListeners : _releasesListeners);
        if (listeners[actionId] == null)
            return false;
        return listeners[actionId].remove(listener);
    }
    
    public function subData(dataIds:Hashes, listener:DataListener):MGuiBase<TTarget, TStyle> {
        for (id in dataIds) {
            if (_dataListeners[id] == null)
                _dataListeners[id] = [];
            else {
                var addedIndex = _dataListeners[id].indexOf(listener);
                if (addedIndex > -1)
                    _dataListeners[id].splice(addedIndex, 1);
            }
            _dataListeners[id].push(listener);
        }
        return this;
    }

    public function style(ids:Hashes, style:TargetStyle<TStyle>):MGuiBase<TTarget, TStyle> {
        for (id in ids) {
            initTarget(id);

            _targetsStateStyle[id] = style;
            applyStateStyle(id, Reflect.field(style, _targetsState[id].toString()));
        }

        return this;
    }

    public function styleGroup(group:Hash, style:TargetStyle<TStyle>):MGuiBase<TTarget, TStyle> {
        if (_groups[group] != null)
            this.style(cast _groups[group], style);
        return this;
    }

    public function group(groups:Hashes, ids:Hashes):MGuiBase<TTarget, TStyle> {
        for (groupId in groups) {
            if (_groups[groupId] == null)
                _groups[groupId] = [];
            
            for (id in ids) {
                if (_groups[groupId].indexOf(id) == -1)
                    _groups[groupId].push(id);
            }
        }

        return this;
    }

    public function timer(
        duration:Float,
        ?onUpdate:OneOfTwo<
            (handle:TimerHandle, progress:Float)->Void,
            (handle:TimerHandle, elapsedTime:Float, duration:Float)->Void
        >,
        ?onComplete:()->Void
    ):Void {
        if (onUpdate != null) {
            var elapsedTime = 0.;
            switch (onUpdate) {
                case Left(onUpdate): 
                    Timer.delay(0, true, (_, handle, delta) -> {
                        elapsedTime += delta;
                        if (elapsedTime < duration)
                            onUpdate(handle, elapsedTime / duration);
                        else {
                            Timer.cancel(handle);
                            onUpdate(handle, 1);
                            if (onComplete != null)
                                onComplete();
                        }
                    });
                    
                case Right(onUpdate):
                    Timer.delay(0, true, (_, handle, delta) -> {
                        elapsedTime += delta;
                        if (elapsedTime < duration)
                            onUpdate(handle, elapsedTime, duration);
                        else {
                            Timer.cancel(handle);
                            onUpdate(handle, duration, duration);
                            if (onComplete != null)
                                onComplete();
                        }
                    });
            }
        } else if (onComplete != null) {
            Timer.delay(duration, false, cast onComplete);
        }
    }

    public function map(dataMap:UserDataMap):MGuiBase<TTarget, TStyle> {
        for (id => data in dataMap)
            _userdata[id] = data;
        return this;
    }

    public function set(dataId:Hash, data:Dynamic):MGuiBase<TTarget, TStyle> {
        if (_userdata[dataId] == data)
            return this;

        _userdata[dataId] = data;
        if (_dataListeners[dataId] != null) {
            for (listener in _dataListeners[dataId])
                listener.call(data, dataId);
        }
        return this;
    }

    public inline function get<T>(dataId:Hash):T {
        return _userdata[dataId];
    }

    public function slider(
        id:Hash, length:Float, ?direction:DragDirection = LEFT_RIGHT,
        ?min:Float, ?max:Float, ?step:Float,
        ?thumbStyle:TargetStyle<TStyle>, ?listeners:TargetEventListeners
    ):MGuiBase<TTarget, TStyle> {
        initTarget(id);
        _targetsTrackLength[id] = length;
        _targetsDirection[id] = direction;
        _targetsStartPos[id] = getPos(id);
        _targetsPercent[id] = 0;
        if (min != null) {
            _targetsValue[id] = min;
            _targetsMin[id] = min;
            // Will cause error if use '_targetsMin[id] = _targetsValue[id] = min'.
        }
        if (max != null) _targetsMax[id] = max;
        if (step != null) _targetsStepValue[id] = step;
        if (thumbStyle != null) style(id, thumbStyle);
        if (listeners != null) sub(id, listeners);
        dispatch(id, VALUE);
        return this;
    }

    public inline function input(actionId:Hash, action:ScriptOnInputAction, ?scriptData:Dynamic):Void {
        inputXY(actionId, action, action.x, action.y, scriptData);
    }

    public function inputXY(actionId:Hash, action:ScriptOnInputAction, x:Float, y:Float, ?scriptData:Dynamic):Void {
        if (actionId == null) {
            pointerX = x;
            pointerY = y;

            for (id in _targetsId) {
                if (isAwake(id))
                    handleTargetPointerMove(id, action, scriptData);
            }

        } else if (actionId == touchActionId) {
            pointerX = x;
            pointerY = y;
            
            if (action.pressed)
                pointerState = JUST_PRESSED;
            else if (action.released)
                pointerState = JUST_PRESSED;

            for (id in _targetsId) {
                if (isAwake(id))
                    handleTargetPressOrRelease(id, action, scriptData);
            }

            if (action.pressed)
                pointerState = PRESSED;
            else if (action.released)
                pointerState = RELEASED;
        }

        //
        
        if (actionId == null)
            actionId = pointerMoveActionId;
        if (_inputsListeners != null) {
            for (listener in _inputsListeners)
                listener.call(actionId, action);
        }
        if (_actionsListeners[actionId] != null) {
            for (listener in _actionsListeners[actionId])
                listener.call(actionId, action);
        }
        if (action.pressed) {
            if (_pressesListeners[actionId] != null) {
                for (listener in _pressesListeners[actionId])
                    listener.call(actionId, action);
            }
        } else if (action.released) {
            if (_releasesListeners[actionId] != null) {
                for (listener in _releasesListeners[actionId])
                    listener.call(actionId, action);
            }
        }
    }

    function handleTargetPointerMove(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (_targetsState[id].dragged) {
            updateDrag(id);
            dispatch(id, DRAG, action);
            if (isSlider(id)) {
                setPercent(id, switch (_targetsDirection[id]) {
                    case LEFT_RIGHT:
                        (getPos(id).x - _targetsStartPos[id].x) / _targetsTrackLength[id];
                    case RIGHT_LEFT:
                        (_targetsStartPos[id].x - getPos(id).x) / _targetsTrackLength[id];
                });
            }
        
        } else if (pointerPick(id)) {
            if (!_targetsState[id].touched) {
                setState(id, HOVERED);
                dispatch(id, ENTER, action);
            }
        } else {
            if (_targetsState[id].touched) {
                setState(id, UNTOUCHED);
                dispatch(id, LEAVE, action);
            }
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (action.pressed) {
            if (pointerPick(id)) {
                _targetsTapInited[id] = true;

                setState(id, PRESSED);
                dispatch(id, PRESS, action);

                if (_targetsDirection[id] != null) {
                    startDrag(id);
                    dispatch(id, DRAG, action);
                }
            }
        } else if (action.released) {
            var releaseDispatched = false;

            if (pointerPick(id)) {
                if (_targetsTapInited[id]) {
                    _targetsTapInited[id] = false;
                    dispatch(id, TAP, action);
                }
                
                if (isAwake(id)) {
                    setState(id, HOVERED);
                    dispatch(id, RELEASE, action);
                    releaseDispatched = true;
                }
            }

            if (_targetsState[id].dragged) {
                setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
                if (!releaseDispatched)
                    dispatch(id, RELEASE, action);
            }
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
        updateDrag(id);
    }

    function updateDrag(id:Hash):Void {
        var start = _targetsStartPos[id];
        var trackLength = _targetsTrackLength[id];
        var heldPos = _targetsHeldPos[id];
        var tx = pointerX - heldPos.x;
        if (start != null && trackLength != null && _targetsMin[id] != null && _targetsMax[id] != null && _targetsStepValue[id] != null) {
            var percent = switch (_targetsDirection[id]) {
                case LEFT_RIGHT: (tx - start.x) / trackLength;
                case RIGHT_LEFT: (start.x - tx) / trackLength;
            }
            var maxValueDistance = _targetsMax[id] - _targetsMin[id];
            var numSteps = (maxValueDistance * percent) / _targetsStepValue[id];
            var downSteps = numSteps.floor();
            var upSteps = numSteps.ceil();
            _targetsNumSteps[id] = Math.abs(downSteps - numSteps) < Math.abs(upSteps - numSteps) ? downSteps : upSteps;
            numSteps = _targetsNumSteps[id];
            percent = (numSteps * _targetsStepValue[id]) / maxValueDistance;
            switch (_targetsDirection[id]) {
                case LEFT_RIGHT: tx = start.x + trackLength * percent;
                case RIGHT_LEFT: tx = start.x - trackLength * percent;
            }
        }

        var pos = getPos(id);
        switch (_targetsDirection[id]) {
            case LEFT_RIGHT: 
                if (start != null) {
                    if (tx < start.x)
                        tx = start.x;
                    else if (trackLength != null && tx > start.x + trackLength)
                        tx = start.x + trackLength;
                }
                pos.x = tx;
                
            case RIGHT_LEFT:
                if (start != null) {
                    if (tx > start.x)
                        tx = start.x;
                    else if (trackLength != null && tx < start.x - trackLength)
                        tx = start.x - trackLength;
                }
                pos.x = tx;
        }

        setPos(id, pos);
    }

    public function message<T>(messageId:Message<T>, ?message:T, ?sender:Url):Void {
        if (_messagesListeners[cast messageId] != null) {
            for (listener in _messagesListeners[cast messageId])
                listener(message);
        }
    }

    public function dispatch(id:Hash, event:TargetEvent, ?action:ScriptOnInputAction):Void {
        if (_targetsListeners[id] == null) {
            Error.error(id + " wasn't subscripted with any event listener");
            return;
        }

        if (_targetsListeners[id][event] == null)
            return;

        for (listener in _targetsListeners[id][event])
            listener.call(id, event, action);
    }

    public inline function getState(id:Hash):TargetState {
        return _targetsState[id];
    }

    public function setState(id:Hash, state:TargetState):Void {
        if (_targetsState[id] == state)
            return;

        _targetsState[id] = state;
        applyStateStyle(id, getStateStyle(id));
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

    public function wake(id:Hash):Void {
        initTarget(id);
        
        if (_targetsState[id] != SLEEPING)
            return;

        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
        dispatch(id, WAKE);
    }

    public function wakeGroup(group:Hash):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                wake(id);
        }
    }

    public function sleep(id:Hash):Void {
        if (_targetsState[id] == SLEEPING)
            return;

        setState(id, SLEEPING);
        dispatch(id, SLEEP);
    }

    public function sleepGroup(group:Hash):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                sleep(id);
        }
    }

    public function isAwake(id:Hash, ?posInfos:PosInfos):Bool {
        return _targetsState[id] != null && _targetsState[id] != SLEEPING;
    }

    public inline function isSlider(id:Hash):Bool {
        return _targetsDirection[id] != null && _targetsStartPos[id] != null && _targetsTrackLength[id] != null;
    }

    public inline function percent(id:Hash):Float {
        return _targetsPercent[id];
    }

    public function setPercent(id:Hash, percent:Float):Void {
        var min = _targetsMin[id];
        if (min == null)
            Error.error('$id does not have a minimum value.');

        var max = _targetsMax[id];
        if (max == null)
            Error.error('$id does not have a maximum value.');

        if (percent < 0) percent = 0;
        else if (percent > 1) percent = 1;

        var value = percent.between(min, max);
        var step = _targetsStepValue[id];
        if (step != null) {
            var stepIndex = value / step;
            if (stepIndex - stepIndex.floor() > 0) {
                _targetsNumSteps[id] = stepIndex.round();
                value = step * _targetsNumSteps[id];
                percent = (value - min) / (max - min);
                if (percent > 1) {
                    percent = 1;
                    value = max;
                }
            }
        }
        
        _targetsValue[id] = value;
        _targetsPercent[id] = percent;
        
        if (isSlider(id)) {
            var pos = getPos(id);
            switch (_targetsDirection[id]) {
                case LEFT_RIGHT:
                    pos.x = _targetsStartPos[id].x + percent * _targetsTrackLength[id];
                case RIGHT_LEFT:
                    pos.x = _targetsStartPos[id].x + _targetsTrackLength[id] * (1 - percent);
            }
            setPos(id, pos);
        }

        dispatch(id, VALUE);
    }

    public function value(id:Hash):Float {
        return _targetsValue[id];
    }

    public function setValue(id:Hash, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsValue[id] = value;
        updatePercent(id);
        return this;
    }

    public inline function min(id:Hash):Float {
        return _targetsMin[id];
    }

    public function setMin(id:Hash, min:Float):MGuiBase<TTarget, TStyle> {
        _targetsMin[id] = min;
        updatePercent(id);
        return this;
    }

    public inline function max(id:Hash):Float {
        return _targetsMax[id];
    }

    public function setMax(id:Hash, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsMax[id] = value;
        updatePercent(id);
        return this;
    }

    public inline function stepValue(id:Hash):Float {
        return _targetsStepValue[id];
    }
    
    public inline function setStepValue(id:Hash, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsStepValue[id] = value;
        updatePercent(id);
        return this;
    }

    public inline function stepIndex(id:Hash):Int {
        return _targetsNumSteps[id];
    }

    public inline function setStepIndex(id:Hash, index:Int):MGuiBase<TTarget, TStyle> {
        if (_targetsStepValue[id] == null)
            Error.error('$id does not have a step value.');
        _targetsValue[id] = _targetsStepValue[id] * index;
        updatePercent(id);
        return this;
    }

    public function setMinMaxStep(id:Hash, min:Float, max:Float, step:Float):MGuiBase<TTarget, TStyle> {
        _targetsMin[id] = min;
        _targetsMax[id] = max;
        _targetsStepValue[id] = step;
        if (_targetsValue[id] == null || _targetsValue[id] <= min)
            setPercent(id, 0);
        else if (_targetsValue[id] >= max)
            setPercent(id, 1);
        else
            setPercent(id, (_targetsValue[id] - min) / (max - min));
        return this;
    }

    inline function updatePercent(id:Hash):Void {
        setPercent(id, (_targetsValue[id] - _targetsMin[id]) / (_targetsMax[id] - _targetsMin[id]));
    }

    public inline function pointerPick(id:Hash):Bool {
        return pick(id, pointerX, pointerY);
    }

    public inline function acquireInputFocus():Void {
        Msg.post('.', new Message<Void>("acquire_input_focus"));
    }

}

@:forward
abstract UserDataMap(Map<Hash, Dynamic>) from Map<Hash, Dynamic> {

    @:from static inline function fromStringMap(map:Map<String, Dynamic>):UserDataMap {
        return cast [ for (key => style in map) key.hash() => style ];
    }
    
}

abstract TimerHandle(defold.Timer.TimerHandle) from defold.Timer.TimerHandle to defold.Timer.TimerHandle {
    
    public inline function cancel():Void {
        Timer.cancel(this);
    }

}