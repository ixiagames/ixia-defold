package ixia.defold.gui.m;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import ixia.defold.gui.m.Event;

abstract EventListener(Dynamic)
from Void->Void to Void->Void
from Hash->Void to Hash->Void
from Hash->Event->Void to Hash->Event->Void
from Hash->Event->ScriptOnInputAction->Void to Hash->Event->ScriptOnInputAction->Void {

    public inline function call(targetID:Hash, event:Event, action:ScriptOnInputAction) {
        this(targetID, event, action);
    }

}