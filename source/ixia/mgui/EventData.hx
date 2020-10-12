package ixia.mgui;

import defold.support.ScriptOnInputAction;
import ixia.lua.RawTable;

enum abstract EventDataPropKey(Int) {
    
    @prop(ixia.mgui.GuiTarget)
    var TARGET;
    
    @prop(ixia.mgui.EventType)
    var TYPE;

    @prop(defold.support.ScriptOnInputAction)
    var ACTION;

    @prop
    var SCRIPT_DATA;

    @:prop(Bool, true, true)
    var CANCELLED;

    var RESULT;

}

@:build(ixia.lua.RawTableBuilder.build(EventDataPropKey))
abstract EventData(RawTable) to RawTable from RawTable {

    public inline function new(target:GuiTarget, type:EventType, ?action:ScriptOnInputAction, ?scriptData:Dynamic) {
        this = new RawTable();
        this[TYPE] = type;
        this[TARGET] = target;
        this[ACTION] = action;
        this[SCRIPT_DATA] = scriptData;
    }

    public function cancel():Void {
        if (type != REMOVE)
            Error.error("This event cannot be cancelled.");
        this[RESULT] = true;
    }
    
    inline function get(key:EventDataPropKey):Dynamic {
        return this[key];
    }

    inline function put():Void {
        this.put();
    }

}