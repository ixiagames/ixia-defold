package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Vector3;
import ixia.defold.types.Hash;
import ixia.lua.RawTable;

using Math;
using ixia.math.Math;

@:access(ixia.defold.gui.m.MGuiBase)
class Target<TTarget, TStyle> {
    
    public var id(default, null):Hash;
    public var mgui(default, null):MGuiBase<TTarget, TStyle>;
    
    public var state(default, set):TargetState;
    public var stateStyle(default, null):TargetStyle<TStyle>;
    public var listeners(default, null):RawTable<TargetEvent, Array<TargetEventListener>>;

    public var heldPos(default, null):Vector3;
    public var sliderStartPos(default, null):Vector3;
    public var sliderTrackLength(default, null):Float;
    public var sliderDirection(default, null):DragDirection;
    public var sliderMin(default, null):Float;
    public var sliderMax(default, null):Float;
    public var sliderValue(default, null):Float;
    public var sliderStepValue(default, null):Float;
    public var sliderNumSteps(default, null):Int;
    public var sliderPercent(default, null):Float;

    var _tapInited:Bool;

    public function new(mgui:MGuiBase<TTarget, TStyle>, id:Hash) {
        this.mgui = mgui;
        this.id = id;
        _tapInited = false;
        listeners = new RawTable();
        state = mgui.pointerPick(id) ? HOVERED : UNTOUCHED;
    }

    public inline function sleep():Void {
        state = SLEEPING;
    }

    public function wake():Void {
        if (state != SLEEPING)
            return;

        state = mgui.pointerPick(id) ? HOVERED : UNTOUCHED;
        dispatch(WAKE);
    }

    public function dispatch(event:TargetEvent, ?action:ScriptOnInputAction):Void {
        if (listeners == null || listeners[event] == null)
            return;

        for (listener in listeners[event])
            listener.call(id, event, action);
    }

    public function getStateStyle():TStyle {
        if (stateStyle == null)
            return null;

        return switch (state) {
            case UNTOUCHED: stateStyle.untouched;
            case HOVERED:   stateStyle.hovered;
            case PRESSED:   stateStyle.pressed;
            case DRAGGED:   stateStyle.dragged;
            case SLEEPING:  stateStyle.sleeping;
        }
    }

    public inline function isSlider():Bool {
        return sliderDirection != null && sliderStartPos != null && sliderTrackLength != null;
    }

    public function setSliderPercent(percent:Float):Void {
        if (sliderMin == null)
            Error.error('$id does not have a minimum value.');

        if (sliderMax == null)
            Error.error('$id does not have a maximum value.');

        if (percent < 0) percent = 0;
        else if (percent > 1) percent = 1;

        var value = percent.between(sliderMin, sliderMax);
        if (sliderStepValue != null) {
            var stepIndex = value / sliderStepValue;
            if (stepIndex - stepIndex.floor() > 0) {
                sliderNumSteps = stepIndex.round();
                value = sliderStepValue * sliderNumSteps;
                percent = (value - sliderMin) / (sliderMax - sliderMin);
                if (percent > 1) {
                    percent = 1;
                    value = sliderMax;
                }
            }
        }
        
        sliderValue = value;
        sliderPercent = percent;
        
        if (isSlider()) {
            var pos = mgui.getPos(id);
            switch (sliderDirection) {
                case LEFT_RIGHT:
                    pos.x = sliderStartPos.x + percent * sliderTrackLength;
                case RIGHT_LEFT:
                    pos.x = sliderStartPos.x + sliderTrackLength * (1 - percent);
            }
            mgui.setPos(id, pos);
        }

        dispatch(VALUE);
    }

    function onPress(action:ScriptOnInputAction):Void {
        _tapInited = true;
        state = PRESSED;
        dispatch(PRESS, action);
        if (sliderDirection != null) {
            mgui.startDrag(id);
            dispatch(DRAG, action);
        }
    }

    function onRelease(action:ScriptOnInputAction):Void {
        state = mgui.pointerPick(id) ? HOVERED : UNTOUCHED;
        if (_tapInited) {
            _tapInited = false;
            dispatch(TAP, action);
        }
        dispatch(RELEASE, action);   
    }

    function set_state(value) {
        if (value == state)
            return state;

        state = value;
        mgui.applyStateStyle(id, getStateStyle());
        if (state == SLEEPING)
            dispatch(SLEEP);

        return state;
    }

}