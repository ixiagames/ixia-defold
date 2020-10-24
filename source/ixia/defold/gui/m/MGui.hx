package ixia.defold.gui.m;

import defold.types.Hash;
import defold.types.HashOrString;
import ixia.ds.OneOrMany;
using defold.Gui;

class MGui extends MGuiBase<GuiNode, NodeStyle> {

    override function idToTarget(id:HashOrString):GuiNode {
        return id.get_node();
    }

    override function pick(id:Hash, x:Float, y:Float):Bool {
        return Gui.pick_node(id.get_node(), x, y);
    }

    override function applyStyle(ids:OneOrMany<HashOrString>, style:NodeStyle) {
        for (id in ids.toArray()) {
            var node = id.get_node();
            if (style.flipbook != null)
                node.play_flipbook(style.flipbook);
        }
    }
    
}