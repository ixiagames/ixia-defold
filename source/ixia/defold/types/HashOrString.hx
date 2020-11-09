package ixia.defold.types;

import defold.types.Hash;

abstract HashOrString(defold.types.HashOrString) from defold.types.HashOrString to defold.types.HashOrString {

    @:from public inline static function fromString(s:String):HashOrString {
        return Defold.hash(s);
    }

    @:to public inline function toHash():Hash {
        return this;
    }

}