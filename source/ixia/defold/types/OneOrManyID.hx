package ixia.defold.types;

import haxe.extern.EitherType;
import ixia.defold.types.HashOrString;

abstract OneOrManyID(EitherType<HashOrString, Array<HashOrString>>)
from EitherType<HashOrString, Array<HashOrString>>
to EitherType<HashOrString, Array<HashOrString>> {
    
    public inline function toArray():Array<HashOrString> {
        return Std.isOfType(this, Array) ? this : [ this ];
    }

}