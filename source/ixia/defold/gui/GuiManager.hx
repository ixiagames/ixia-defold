package ixia.defold.gui;

import defold.Go.GoAnimatedProperty;
import defold.Gui;
import defold.types.HashOrString;
import defold.types.Vector3;
import defold.types.Vector4;
import haxe.PosInfos;
import haxe.extern.EitherType;
import ixia.defold.types.Hash;
import ixia.defold.types.Rgba;

using Defold;
using ixia.defold.gui.ExtGuiNode;

class GuiManager extends GuiManagerBase<ExtGuiNode, NodeStyle> {

    public function new(?touchActionId:Hash, ?acquiresInputFocus:Bool = true, ?renderOrder:Int) {
        super(touchActionId, acquiresInputFocus);
        
        if (renderOrder != null)
            Gui.set_render_order(renderOrder);
    }

    override function idToTarget(id:Hash):ExtGuiNode {
        return id.getNode();
    }

    override function isAwake(id:Hash, ?posInfos:PosInfos):Bool {
        if (!super.isAwake(id))
            return false;

        try {
            var node = targets[id].target;
            if (!node.enabled)
                return false;
    
            var parent = node.parent;
            while (parent != null) {
                if (!parent.enabled)
                    return false;
                parent = parent.parent;
            }
        } catch (error) {
            Error.error(error.message + ' ($id)', posInfos);
        }
        
        return true;
    }

    override function pick(id:Hash, x:Float, y:Float):Bool {
        return Gui.pick_node(targets[id].target, x, y);
    }

    override function getPos(id:Hash):Vector3 {
        return targets[id].target.position;
    }

    override function setPos(id:Hash, pos:Vector3) {
        targets[id].target.position = pos;
    }

    override function applyStateStyle(node:ExtGuiNode, style:NodeStyle) {
        if (style == null)
            return;
        
        if (style.enabled != null)
            node.enabled = style.enabled;

        if (style.color != null)
            node.color = style.color;

        if (style.alpha != null) {
            var color = node.color;
            color.a = style.alpha;
            node.color = color;
        }

        if (style.flipbook != null)
            node.play_flipbook(style.flipbook);

        if (style.texture != null)
            node.texture = style.texture;

        if (style.animations != null) {
            for (prop => configs in style.animations) {
                node.animate(
                    cast prop,
                    configs.to,
                    configs.easing != null ? configs.easing : GuiEasing.EASING_LINEAR,
                    configs.duration,
                    configs.delay != null ? configs.delay : 0,
                    configs.onComplete,
                    configs.playback
                );
            }
        }

        if (style.nodes != null) {
            for (id => style in style.nodes)
                applyStateStyle(id.getNode(), style);
        }
    }

    public function setGroupEnabled(group:Hash, enabled:Bool):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                targets[id].target.enabled = enabled;
        }
    }
    
}

typedef NodeStyle = {

    ?enabled:Bool,
    ?color:Rgba,
    ?alpha:Float,
    ?flipbook:HashOrString,
    ?texture:HashOrString,
    ?animations:Map<String, NodeAnimationConfigs>,
    ?nodes:NodeStyleMap

}

@:forward
abstract NodeStyleMap(Map<Hash, NodeStyle>) from Map<Hash, NodeStyle> {

    @:from static inline function fromStringMap(map:Map<String, NodeStyle>):NodeStyleMap {
        return cast [ for (key => style in map) key.hash() => style ];
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