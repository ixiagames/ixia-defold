package ixia.defold.gui.m;

import defold.Msg;
import defold.types.Hash;
import defold.types.HashOrString;
import defold.types.Message;
import defold.types.Vector3;

using defold.Gui;

class MGui extends MGuiBase<GuiNode, NodeStyle> {

    public function new(?touchActionID:HashOrString, ?acquiresInputFocus:Bool = true, ?renderOrder:Int) {
        super(touchActionID);
        
        if (acquiresInputFocus)
            acquireInputFocus();
        if (renderOrder != null)
            Gui.set_render_order(renderOrder);
    }

    override function idToTarget(id:Hash):GuiNode {
        return id.get_node();
    }

    override function pick(id:Hash, x:Float, y:Float):Bool {
        return Gui.pick_node(id.get_node(), x, y);
    }

    override function getPos(id:Hash):Vector3 {
        return id.get_node().get_position();
    }

    override function setPos(id:Hash, pos:Vector3) {
        id.get_node().set_position(pos);
    }

    override function applyStateStyle(id:HashOrString, style:NodeStyle) {
        if (style == null)
            return;

        var node = id.get_node();
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

    public function setGroupEnabled(group:HashOrString, enabled:Bool):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                id.get_node().set_enabled(enabled);
        }
    }

    public inline function acquireInputFocus():Void {
        Msg.post('.', new Message<Void>("acquire_input_focus"));
    }
    
}