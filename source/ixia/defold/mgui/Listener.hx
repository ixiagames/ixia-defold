package ixia.defold.mgui;

import defold.support.ScriptOnInputAction;

typedef Listener<T> = (target:T, event:Event, ?action:ScriptOnInputAction)->Void;