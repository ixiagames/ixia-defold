package ixia.defold.types;

import defold.types.HashOrString;

abstract Hash(defold.types.Hash) from defold.types.Hash to defold.types.Hash {

    @:from public static inline function fromString(s:String):Hash {
        return Defold.hash(s);
    }

    @:to public inline function toHashOrString():HashOrString {
        return this;
    }

}