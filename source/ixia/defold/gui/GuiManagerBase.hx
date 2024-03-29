package ixia.defold.gui;

import defold.Msg;
import defold.Sys;
import defold.Timer;
import defold.Vmath;
import defold.support.ScriptOnInputAction;
import defold.types.Message;
import defold.types.Url;
import defold.types.Vector3;
import haxe.PosInfos;
import haxe.ds.Either;
import ixia.defold.gui.TargetEvent;
import ixia.defold.gui.TargetEventListener.TargetEventListeners;
import ixia.defold.types.Hash;
import ixia.defold.types.Hashes;
import ixia.utils.ds.OneOfTwo;
import ixia.utils.lua.RawTable;

using Defold;
using Math;

@:access(ixia.defold.gui.Target)
class GuiManagerBase<TTarget, TStyle> {

    public var touchActionId(default, null):Hash;
    public var pointerX(default, null):Float = 0;
    public var pointerY(default, null):Float = 0;
    public var pointerState(default, null):PointerState = RELEASED;
    public var defaultButtonMode:Bool;
    public var systemInfo(default, null):SysSysInfo;

    public final targets = new Map<Hash, Target<TTarget, TStyle>>();
    public final inputListeners = new Array<InputActionListener>();
    public final messageListeners = new Array<(guiData:Dynamic, messageId:Message<Dynamic>, message:Dynamic, sender:Url)->Void>();

    var _groups:RawTable<Hash, Array<Hash>> = new RawTable();

    public function new(?touchActionId:Hash, ?pointerMoveActionId:Hash, ?acquiresInputFocus:Bool = true, ?defaultButtonMode:Bool = true) {
        this.touchActionId = touchActionId != null ? touchActionId : "touch".hash();
        this.defaultButtonMode = defaultButtonMode;

        if (acquiresInputFocus)
            acquireInputFocus();

        systemInfo = Sys.get_sys_info();
    }

    // Override these.
    public function applyStateStyle(target:TTarget, style:TStyle):Void {}
    function idToTarget(id:Hash):TTarget return null;
    function pick(id:Hash, x:Float, y:Float):Bool return false;
    function getPos(id:Hash):Vector3 return null;
    function setPos(id:Hash, pos:Vector3):Void {}

    //

    /**
     * Remove a target from the interaction list.
     * Remove its listeners & styles but leave other data (like min, max, percent...).
     */
    public function removeInteraction(id:Hash):Bool {
        return targets.remove(id);
    }

    function initTarget(id:Hash):Target<TTarget, TStyle> {
        if (targets.exists(id))
            return targets[id];

        targets[id] = new Target(this, id);
        targets[id].state = pointerPick(id) ? HOVERED : UNTOUCHED;
        return targets[id];
    }

    public function config(ids:Hashes, style:TargetStyle<TStyle>, listeners:TargetEventListeners):GuiManagerBase<TTarget, TStyle> {
        this.style(ids, style);
        sub(ids, listeners);
        return this;
    }

    public function sub(ids:Hashes, listeners:TargetEventListeners):GuiManagerBase<TTarget, TStyle> {
        var target:Target<TTarget, TStyle>;
        for (id in ids) {
            target = initTarget(id);

            for (field in Reflect.fields(listeners)) {
                var listener = Reflect.field(listeners, field);
                if (listener == null)
                    continue;

                var event = TargetEvent.fromString(field);
                if (target.listeners[event] == null)
                    target.listeners[event] = [];
                else {
                    var addedIndex = target.listeners[event].indexOf(listener);
                    if (addedIndex > -1)
                        target.listeners[event].splice(addedIndex, 1);
                }
                target.listeners[event].push(listener);
            }
        }
        return this;
    }

    public function unsub(ids:Hashes, listeners:TargetEventListeners):Void {
        var target:Target<TTarget, TStyle>;
        for (id in ids) {
            target = targets[id];
            if (target == null)
                continue;

            for (field in Reflect.fields(listeners)) {
                var listener = Reflect.field(listeners, field);
                if (listener == null)
                    continue;

                var event = TargetEvent.fromString(field);
                if (target.listeners[event] == null)
                    continue;

                target.listeners[event].remove(listener);
            }
        }
    }

    public function subGroup(group:Hash, listeners:TargetEventListeners):GuiManagerBase<TTarget, TStyle> {
        if (_groups[group] != null)
            sub(cast _groups[group], listeners);
        return this;
    }

    public function style(ids:Hashes, style:TargetStyle<TStyle>):GuiManagerBase<TTarget, TStyle> {
        var target:Target<TTarget, TStyle>;
        for (id in ids) {
            target = initTarget(id);
            target.stateStyle = style;
            applyStateStyle(target.target, Reflect.field(style, target.state.toString()));
        }
        return this;
    }

    public function styleGroup(group:Hash, style:TargetStyle<TStyle>):GuiManagerBase<TTarget, TStyle> {
        if (_groups[group] != null)
            this.style(cast _groups[group], style);
        return this;
    }

    public function group(groups:Hashes, ids:Hashes):GuiManagerBase<TTarget, TStyle> {
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

    public inline function message<TMessage>(guiData:Dynamic, message_id:Message<TMessage>, message:TMessage, sender:Url):Void {
        for (listener in messageListeners)
            listener(guiData, message_id, message, sender);
    }

    public inline function input(actionId:Hash, action:ScriptOnInputAction, ?scriptData:Dynamic):Void {
        inputXY(actionId, action, action.x, action.y, scriptData);
    }

    public function inputXY(actionId:Hash, action:ScriptOnInputAction, x:Float, y:Float, ?scriptData:Dynamic):Void {
        if (actionId == null) {
            pointerX = x;
            pointerY = y;

            for (id in targets.keys()) {
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

            for (id in targets.keys()) {
                if (isAwake(id))
                    handleTargetPressOrRelease(id, action, scriptData);
            }

            if (action.pressed)
                pointerState = PRESSED;
            else if (action.released)
                pointerState = RELEASED;
        }

        //

        for (listener in inputListeners)
            listener.call(actionId, action);
    }

    function handleTargetPointerMove(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        var target = targets[id];
        if (target.state.dragged) {
            updateDrag(id);
            target.dispatch(DRAG, action);
            if (target.isSlider()) {
                target.sliderPercent = switch (target.sliderDirection) {
                    case LEFT_RIGHT:
                        (getPos(id).x - target.sliderStartPos.x) / target.sliderTrackLength;
                    case RIGHT_LEFT:
                        (target.sliderStartPos.x - getPos(id).x) / target.sliderTrackLength;
                };
            }
        
        } else if (pointerPick(id)) {
            if (!target.state.touched) {
                target.state = HOVERED;
                target.dispatch(ENTER, action);
            }
        } else {
            if (target.state.touched) {
                target.state = UNTOUCHED;
                target.dispatch(LEAVE, action);
            }
        }
    }

    function handleTargetPressOrRelease(id:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Void {
        var target = targets[id];
        if (action.pressed) {
            if (pointerPick(id))
                target.onPress(action);

        } else if (action.released) {
            if (target.state.dragged || target.state.touched)
                target.onRelease(action);
        }
    }

    function startDrag(id:Hash):Void {
        var target = targets[id];
        if (target.sliderStartPos == null)
            target.sliderStartPos = getPos(id);
        if (target.heldPos == null)
            target.heldPos = Vmath.vector3();

        var pos = getPos(id);
        target.heldPos.x = pointerX - pos.x;
        target.heldPos.y = pointerY - pos.y;

        target.state = DRAGGED;
        updateDrag(id);
    }

    function updateDrag(id:Hash):Void {
        var target = targets[id];
        var start = target.sliderStartPos;
        var trackLength = target.sliderTrackLength;
        var heldPos = target.heldPos;
        var tx = pointerX - heldPos.x;
        if (
            start != null && trackLength != null &&
            target.sliderMin != null && target.sliderMax != null &&
            target.sliderValue != null
        ) {
            var percent = switch (target.sliderDirection) {
                case LEFT_RIGHT: (tx - start.x) / trackLength;
                case RIGHT_LEFT: (start.x - tx) / trackLength;
            }
            var maxValueDistance = target.sliderMax - target.sliderMin;
            var numSteps = (maxValueDistance * percent) / target.sliderStepValue;
            var downSteps = numSteps.floor();
            var upSteps = numSteps.ceil();
            target.sliderNumSteps = Math.abs(downSteps - numSteps) < Math.abs(upSteps - numSteps) ? downSteps : upSteps;
            numSteps = target.sliderNumSteps;
            percent = (numSteps * target.sliderStepValue) / maxValueDistance;
            switch (target.sliderDirection) {
                case LEFT_RIGHT: tx = start.x + trackLength * percent;
                case RIGHT_LEFT: tx = start.x - trackLength * percent;
            }
        }

        var pos = getPos(id);
        switch (target.sliderDirection) {
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

    public function slider(
        id:Hash, length:Float, ?direction:DragDirection = LEFT_RIGHT,
        ?min:Float, ?max:Float, ?step:Float,
        ?thumbStyle:TargetStyle<TStyle>, ?listeners:TargetEventListeners
    ):GuiManagerBase<TTarget, TStyle> {
        var target = initTarget(id);
        target.sliderTrackLength = length;
        target.sliderDirection = direction;
        target.sliderStartPos = getPos(id);
        if (min != null)
            target.sliderValue = target.sliderMin = min;
        if (max != null)
            target.sliderMax = max;
        if (step != null)
            target.sliderStepValue = step;
        if (thumbStyle != null)
            style(id, thumbStyle);
        if (listeners != null)
            sub(id, listeners);
        target.sliderPercent = 0;
        return this;
    }

    public function wakeGroup(group:Hash):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                targets[id].wake();
        }
    }

    public function sleepGroup(group:Hash):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                targets[id].state = SLEEPING;
        }
    }

    public function isAwake(id:Hash, ?posInfos:PosInfos):Bool {
        return targets.exists(id) && targets[id].state != SLEEPING;
    }

    public function setValue(id:Hash, value:Float):GuiManagerBase<TTarget, TStyle> {
        targets[id].sliderValue = value;
        updatePercent(id);
        return this;
    }

    public function setMin(id:Hash, min:Float):GuiManagerBase<TTarget, TStyle> {
        targets[id].sliderMin = min;
        updatePercent(id);
        return this;
    }

    public function setMax(id:Hash, value:Float):GuiManagerBase<TTarget, TStyle> {
        targets[id].sliderMax = value;
        updatePercent(id);
        return this;
    }
    
    public inline function setStepValue(id:Hash, value:Float):GuiManagerBase<TTarget, TStyle> {
        targets[id].sliderStepValue = value;
        updatePercent(id);
        return this;
    }

    public inline function setStepIndex(id:Hash, index:Int):GuiManagerBase<TTarget, TStyle> {
        var target = targets[id];
        if (target.sliderStepValue == null)
            Error.error('$id does not have a step value.');
        target.sliderStepValue = target.sliderStepValue * index;
        updatePercent(id);
        return this;
    }

    public function setMinMaxStep(id:Hash, min:Float, max:Float, step:Float):GuiManagerBase<TTarget, TStyle> {
        var target = targets[id];
        target.sliderMin = min;
        target.sliderMax = max;
        target.sliderStepValue = step;
        if (target.sliderValue == null || target.sliderValue <= min)
            target.sliderPercent = 0;
        else if (target.sliderValue >= max)
            target.sliderPercent = 1;
        else
            target.sliderPercent = (target.sliderValue - min) / (max - min);
        return this;
    }

    inline function updatePercent(id:Hash):Void {
        var target = targets[id];
        target.sliderPercent = (target.sliderValue - target.sliderMin) / (target.sliderMax - target.sliderMin);
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