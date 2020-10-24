package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;

@:allow(ixia.defold.gui.m.MGuiBase)
class EventData<TTarget> {
    
    public var id(default, null):Hash;
    public var target(default, null):TTarget;
    public var event(default, null):Event;
    public var action(default, null):ScriptOnInputAction;

    private function new() {}

    function clear():Void {
        id = null;
        target = null;
        event = null;
        action = null;
    }

}