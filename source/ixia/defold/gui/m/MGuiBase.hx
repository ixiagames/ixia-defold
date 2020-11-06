package ixia.defold.gui.m;

import defold.Timer;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.HashOrString;
import defold.types.Message;
import defold.types.Url;
import defold.types.Vector3;
import haxe.ds.Either;
import haxe.extern.EitherType;
import ixia.defold.gui.m.TargetEvent;
import ixia.defold.gui.m.TargetEventListener.TargetEventListeners;
import ixia.defold.gui.m.TargetState;
import ixia.ds.OneOfTwo;
import ixia.ds.OneOrMany;
import ixia.lua.RawTable;

using Defold;
using Math;
using ixia.math.Math;

class MGuiBase<TTarget, TStyle> {

    public var touchActionID(default, null):Hash;
    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;

    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();
    var _targetsID:Array<Hash> = [];

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
    var _targetsStepValue:RawTable<Hash, Float> = new RawTable();
    var _targetsStepIndex:RawTable<Hash, Int> = new RawTable();
    
    var _userdata:RawTable<Hash, Dynamic> = new RawTable();
    var _dataListeners:RawTable<Hash, Array<DataListener>> = new RawTable();
    var _messagesListeners:RawTable<Hash, Array<Dynamic->Void>> = new RawTable();
    var _actionsListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();
    var _pressesListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();
    var _releasesListeners:RawTable<Hash, Array<InputActionListener>> = new RawTable();

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

    function initTarget(id:Hash):Void {
        if (_targetsID.indexOf(id) > -1)
            return;

        _targetsID.push(id);
        _targetsTapInited[id] = false;
        _targetsListeners[id] = new RawTable();
        setState(id, pointerPick(id) ? HOVERED : UNTOUCHED);
    }

    public function sub(ids:OneOrMany<HashOrString>, listeners:TargetEventListeners):MGuiBase<TTarget, TStyle> {
        for (id in ids.toArray()) {
            initTarget(id);

            for (field in Reflect.fields(listeners)) {
                var event = TargetEvent.fromString(field);
                var listener = Reflect.field(listeners, field);

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

    public function subGroup(group:HashOrString, listeners:TargetEventListeners):MGuiBase<TTarget, TStyle> {
        if (_groups[group] != null)
            sub(_groups[group], listeners);
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

    public function subAction(actionID:HashOrString, ?pressed:Null<Bool> = true, listener:InputActionListener):MGuiBase<TTarget, TStyle> {
        var listeners = pressed == null ? _actionsListeners : (pressed ? _pressesListeners : _releasesListeners);
        if (listeners[actionID] == null)
            listeners[actionID] = [];
        else {
            var addedIndex = listeners[actionID].indexOf(listener);
            if (addedIndex > -1)
                listeners[actionID].splice(addedIndex, 1);
        }
        listeners[actionID].push(listener);
        return this;
    }

    public function subData(dataIDs:OneOrMany<HashOrString>, listener:DataListener):MGuiBase<TTarget, TStyle> {
        for (id in dataIDs.toArray()) {
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

    public function set(dataID:HashOrString, data:Dynamic):MGuiBase<TTarget, TStyle> {
        if (_userdata[dataID] == data)
            return this;

        _userdata[dataID] = data;
        if (_dataListeners[dataID] != null) {
            for (listener in _dataListeners[dataID])
                listener.call(data, dataID);
        }
        return this;
    }

    public inline function get<T>(dataID:HashOrString):T {
        return _userdata[dataID];
    }

    public function slider(
        id:HashOrString, length:Float, ?direction:DragDirection = LEFT_RIGHT,
        ?min:Float, ?max:Float, ?step:Float,
        ?thumbStyle:TargetStyle<TStyle>, ?listeners:TargetEventListeners
    ):MGuiBase<TTarget, TStyle> {
        initTarget(id);
        _targetsTrackLength[id] = length;
        _targetsDirection[id] = direction;
        _targetsStartPos[id] = getPos(id);
        if (min != null) _targetsMin[id] = min;
        if (max != null) _targetsMax[id] = max;
        if (step != null) _targetsStepValue[id] = step;
        if (thumbStyle != null) style(id, thumbStyle);
        if (listeners != null) sub(id, listeners);
        return this;
    }

    public function input(actionID:Hash, action:ScriptOnInputAction, ?scriptData:Dynamic):Void {
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
        
        if (_actionsListeners[actionID] != null) {
            for (listener in _actionsListeners[actionID])
                listener.call(actionID, action);
        }
        if (action.pressed) {
            if (_pressesListeners[actionID] != null) {
                for (listener in _pressesListeners[actionID])
                    listener.call(actionID, action);
            }
        } else if (action.released) {
            if (_releasesListeners[actionID] != null) {
                for (listener in _releasesListeners[actionID])
                    listener.call(actionID, action);
            }
        }
    }

    function handleTargetPointerMove(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (_targetsState[id].dragged) {
            updateDrag(id);
            dispatch(id, DRAG, action);

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
        //var ty = pointerY - heldPos.y;
        if (start != null && trackLength != null && _targetsMin[id] != null && _targetsMax[id] != null && _targetsStepValue[id] != null) {
            var percent = switch (_targetsDirection[id]) {
                case LEFT_RIGHT: (tx - start.x) / trackLength;
                case RIGHT_LEFT: (start.x - tx) / trackLength;
            }
            var maxDistance = _targetsMax[id] - _targetsMin[id];
            var distance = _targetsMin[id] + maxDistance * percent;
            var steps = distance / _targetsStepValue[id];
            var downSteps = steps.floor();
            var upSteps = steps.ceil();
            _targetsStepIndex[id] = Math.abs(downSteps - steps) < Math.abs(upSteps - steps) ? downSteps : upSteps;
            steps = _targetsStepIndex[id];
            percent = (steps * _targetsStepValue[id]) / maxDistance;
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

    public function message<T>(messageID:Message<T>, ?message:T, ?sender:Url):Void {
        if (_messagesListeners[cast messageID] != null) {
            for (listener in _messagesListeners[cast messageID])
                listener(message);
        }
    }

    public function dispatch(id:HashOrString, event:TargetEvent, ?action:ScriptOnInputAction):Void {
        if (_targetsListeners[id][event] == null)
            return;

        for (listener in _targetsListeners[id][event])
            listener.call(id, event, action);
    }

    public inline function getState(id:HashOrString):TargetState {
        return _targetsState[id];
    }

    function setState(id:HashOrString, state:TargetState):Void {
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
        dispatch(id, SLEEP);
    }

    public function sleepGroup(group:HashOrString):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                sleep(id);
        }
    }

    public inline function isAwake(id:HashOrString):Bool {
        return _targetsState[id] != null && _targetsState[id] != SLEEPING;
    }

    public function sliderPercent(id:HashOrString):Float {
        if (_targetsDirection[id] == null || _targetsStartPos[id] == null || _targetsTrackLength[id] == null)
            return 0;

        return switch (_targetsDirection[id]) {
            case LEFT_RIGHT:
                (getPos(id).x - _targetsStartPos[id].x) / _targetsTrackLength[id];
            case RIGHT_LEFT:
                (_targetsStartPos[id].x - getPos(id).x) / _targetsTrackLength[id];
        }
    }

    public function sliderValue(id:HashOrString):Float {
        return sliderPercent(id).between(_targetsMin[id], _targetsMax[id]);
    }

    public function sliderValueInt(id:HashOrString):Int {
        return Std.int(sliderPercent(id).between(_targetsMin[id], _targetsMax[id]));
    }

    public inline function min(id:HashOrString):Float {
        return _targetsMin[id];
    }

    public inline function setMin(id:HashOrString, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsMin[id] = value;
        return this;
    }

    public inline function max(id:HashOrString):Float {
        return _targetsMax[id];
    }

    public inline function setMax(id:HashOrString, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsMax[id] = value;
        return this;
    }

    public inline function stepValue(id:HashOrString):Float {
        return _targetsStepValue[id];
    }

    public inline function stepIndex(id:HashOrString):Int {
        return _targetsStepIndex[id];
    }
    
    public inline function setStepValue(id:HashOrString, value:Float):MGuiBase<TTarget, TStyle> {
        _targetsStepValue[id] = value;
        return this;
    }

    public function setMinMaxStep(id:HashOrString, min:Float, max:Float, step:Float):MGuiBase<TTarget, TStyle> {
        _targetsMin[id] = min;
        _targetsMax[id] = max;
        _targetsStepValue[id] = step;
        return this;
    }

    public inline function pointerPick(id:HashOrString):Bool {
        return pick(id, pointerX, pointerY);
    }

}

@:forward
abstract UserDataMap(Map<Hash, Dynamic>) from Map<Hash, Dynamic> {

    @:from static inline function fromStringMap(map:Map<String, Dynamic>):UserDataMap {
        return [ for (key => style in map) key.hash() => style ];
    }
    
}

abstract TimerHandle(defold.Timer.TimerHandle) from defold.Timer.TimerHandle to defold.Timer.TimerHandle {
    
    public inline function cancel():Void {
        Timer.cancel(this);
    }

}