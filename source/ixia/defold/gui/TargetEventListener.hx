package ixia.defold.gui;

import defold.support.ScriptOnInputAction;
import defold.types.Hash;

abstract TargetEventListener(Dynamic)
from Void->Void to Void->Void
from Hash->Void to Hash->Void
from Hash->TargetEvent->Void to Hash->TargetEvent->Void
from Hash->TargetEvent->ScriptOnInputAction->Void to Hash->TargetEvent->ScriptOnInputAction->Void {

    public inline function call(targetId:Hash, event:TargetEvent, action:ScriptOnInputAction) {
        this(targetId, event, action);
    }

}

typedef TargetEventListeners = {

    ?leave:TargetEventListener,
    ?enter:TargetEventListener,
    ?press:TargetEventListener,
    ?release:TargetEventListener,
    ?tap:TargetEventListener,
    ?drag:TargetEventListener,
    ?value:TargetEventListener,
    ?wake:TargetEventListener,
    ?sleep:TargetEventListener

}