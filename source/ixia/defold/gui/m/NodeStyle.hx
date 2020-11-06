package ixia.defold.gui.m;

import defold.Go.GoAnimatedProperty;
import defold.Gui;
import defold.types.Hash;
import defold.types.HashOrString;
import defold.types.Vector3;
import defold.types.Vector4;
import haxe.extern.EitherType;

using Defold;

typedef NodeStyle = {

    ?enabled:Bool,
    ?flipbook:HashOrString,
    ?animations:Map<String, NodeAnimationConfigs>,
    ?nodes:NodeStyleMap

}

@:forward
abstract NodeStyleMap(Map<Hash, NodeStyle>) from Map<Hash, NodeStyle> {

    @:from static inline function fromStringMap(map:Map<String, NodeStyle>):NodeStyleMap {
        return [ for (key => style in map) key.hash() => style ];
    }
    
}

typedef NodeAnimationConfigs = {

    to:GoAnimatedProperty,
    duration:Float,
    ?delay:Float,
    ?easing:EitherType<GuiEasing,EitherType<Vector3,Vector4>>,
    ?playback:GuiPlayback,
    ?onComplete:Dynamic->GuiNode->Void

}