package ixia.defold.gui.m;

import defold.types.Hash;
import defold.types.HashOrString;
import defold.types.Vector3;
using defold.Gui;

class MGui extends MGuiBase<GuiNode, NodeStyle> {

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

        if (style.nodes != null) {
            for (id => style in style.nodes)
                applyStateStyle(id, style);
        }
    }

    public function setGroupEnabled(group:HashOrString, enabled:Bool):Void {
        if (_groups[group] != null) {
            for (id in _groups[group])
                Gui.set_enabled(id.get_node(), enabled);
        }
    }
    
}