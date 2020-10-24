package ixia.defold.gui.m;

import defold.types.Hash;
import defold.types.HashOrString;
using Defold;

typedef NodeStyle = {

    ?enabled:Bool,
    ?flipbook:HashOrString,
    ?nodes:NodeStyleMap

}

@:forward
abstract NodeStyleMap(Map<Hash, NodeStyle>) from Map<Hash, NodeStyle> {

    @:from static inline function fromStringMap(map:Map<String, NodeStyle>):NodeStyleMap {
        return [ for (key => style in map) key.hash() => style ];
    }
    
}