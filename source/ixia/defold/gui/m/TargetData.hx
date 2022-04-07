package ixia.defold.gui.m;

import defold.types.Vector3;
import ixia.defold.types.Hash;
import ixia.lua.RawTable;

class TargetData<TTarget, TStyle> {
    
    public var id(default, null):Hash;
    public var mgui(default, null):MGuiBase<TTarget, TStyle>;

    public var tapInited:Bool;
    public var state(default, set):TargetState;
    public var stateStyle:TargetStyle<TStyle>;
    public var listeners:RawTable<TargetEvent, Array<TargetEventListener>>;

    public var heldPos:Vector3;
    public var sliderStartPos:Vector3;
    public var sliderTrackLength:Float;
    public var sliderDirection:DragDirection;
    public var sliderMin:Float;
    public var sliderMax:Float;
    public var sliderValue:Float;
    public var sliderStepValue:Float;
    public var sliderNumSteps:Int;
    public var sliderPercent:Float;

    public function new(mgui:MGuiBase<TTarget, TStyle>, id:Hash) {
        this.mgui = mgui;
        this.id = id;
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

    inline function set_state(value) {
        if (value == state)
            return state;

        state = value;
        mgui.applyStateStyle(id, getStateStyle());
        return state;
    }

}