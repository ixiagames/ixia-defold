package ixia.defold.gui.m;

import defold.types.Hash;

abstract DataListener(Dynamic)
from Void->Void to Void->Void
from (data:Dynamic)->Void to (data:Dynamic)->Void
from (data:Dynamic, id:Hash)->Void to (data:Dynamic, id:Hash)->Void {

    public inline function call(data:Dynamic, id:Hash):Void {
        this(data, id);
    }

}