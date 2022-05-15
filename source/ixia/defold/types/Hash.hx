package ixia.defold.types;

import defold.types.HashOrString;
import defold.types.Message;

abstract Hash(defold.types.Hash) from defold.types.Hash to defold.types.Hash {

    @:from public static inline function fromString(string:String):Hash {
        return Defold.hash(string);
    }

    @:from public static inline function fromMessage(message:Message<Dynamic>):Hash {
        return cast message;
    }

    @:to public inline function toHashOrString():HashOrString {
        return this;
    }

}