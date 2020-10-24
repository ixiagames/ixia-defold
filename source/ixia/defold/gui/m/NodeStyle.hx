package ixia.defold.gui.m;

import defold.types.HashOrString;

typedef NodeStyle = {

    ?enabled:Bool,
    ?flipbook:HashOrString,
    ?nodes:Map<HashOrString, NodeStyle>

}