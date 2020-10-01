package ixia.mgui;

import defold.support.ScriptOnInputAction;
import ixia.mgui.utils.RawTable;

enum abstract Event(Int) to Int {
    
    var CREATE;
    var REMOVE;
    var REQUEST_NODE;
    var CLICK;
    var PRESS;
    var JUST_PRESS;
    var RELEASE;
    var JUST_RELEASE;
    var ROLL_OUT;
    var ROLL_IN;

    public inline function isPressing():Bool {
        return this == PRESS || this == JUST_PRESS;
    }

}

enum abstract EventDataPropKey(Int) {
    
    @prop(ixia.mgui.GuiTarget)
    var TARGET;
    
    @prop(ixia.mgui.Event)
    var EVENT;

    @prop(defold.support.ScriptOnInputAction)
    var ACTION;

    @prop
    var SCRIPT_DATA;

    @:prop(Bool, true, true)
    var CANCELLED;

    var RESULT;

}

@:build(ixia.mgui.utils.PropsBuilder.build(EventDataPropKey))
abstract EventData(RawTable) to RawTable from RawTable {

    public inline function new(target:GuiTarget, event:Event, ?action:ScriptOnInputAction, ?scriptData:Dynamic<{}>) {
        this = new RawTable();
        this[TARGET] = target;
        this[EVENT] = event;
        this[ACTION] = action;
        this[SCRIPT_DATA] = scriptData;
    }

    public function cancel():Void {
        if (event != REMOVE)
            MGui.error("This event cannot be cancelled.");
        this[RESULT] = true;
    }
    
    inline function get(event:EventDataPropKey):Dynamic {
        return this[event];
    }

    inline function put():Void {
        this.put();
    }

}