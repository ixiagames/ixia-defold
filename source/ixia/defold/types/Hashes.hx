package ixia.defold.types;

import ixia.defold.types.Hash;
import defold.types.HashOrString;

@:transitive
@:forward
abstract Hashes(Array<Hash>) from Array<Hash> to Array<Hash> {

    @:from public static inline function fromHash(hash:Hash):Hashes {
        return [ hash ];
    }

    @:from public static inline function fromString(s:String):Hashes {
        return [ Defold.hash(s) ];
    }

    @:from public static inline function fromStrings(array:Array<String>):Hashes {
        return [ for (id in array) Defold.hash(id) ];
    }
    
    @:from public static inline function fromArray(array:Array<HashOrString>):Hashes {
        return cast [ for (id in array) Std.isOfType(id, String) ? Defold.hash(id) : id ];
    }

}