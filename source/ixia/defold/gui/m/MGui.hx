package ixia.defold.gui.m;

import defold.types.Vector3;
import ixia.defold.types.Hash;

using defold.Gui;

class MGui extends MGuiBase<ExtGuiNode, NodeStyle> {

    public function new(?touchActionID:Hash, ?acquiresInputFocus:Bool = true, ?renderOrder:Int) {
        super(touchActionID, acquiresInputFocus);
        
        if (renderOrder != null)
            Gui.set_render_order(renderOrder);
    }

    override function idToTarget(id:Hash):ExtGuiNode {
        return Gui.get_node(id);
    }

    override function isAwake(id:Hash):Bool {
        return !super.isAwake(id) ? false : Gui.get_node(id).is_enabled();
    }

    override function pick(id:Hash, x:Float, y:Float):Bool {
        return Gui.pick_node(Gui.get_node(id), x, y);
    }

    override function getPos(id:Hash):Vector3 {
        return Gui.get_node(id).get_position();
    }

    override function setPos(id:Hash, pos:Vector3) {
        Gui.get_node(id).set_position(pos);
    }

    override function applyStateStyle(id:Hash, style:NodeStyle) {
        if (style == null)
            return;
        
        var node = Gui.get_node(id);
        if (style.enabled != null)
            node.set_enabled(style.enabled);

        if (style.flipbook != null)
            node.play_flipbook(style.flipbook);

        if (style.animations != null) {
            for (prop => configs in style.animations) {
                node.animate(
                    prop,
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
                applyStateStyle(id, style);
        }
    }

    public function setGroupEnabled(group:Hash, enabled:Bool):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                Gui.get_node(id).set_enabled(enabled);
        }
    }
    
}