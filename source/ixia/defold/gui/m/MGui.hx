package ixia.defold.gui.m;

import defold.types.Hash;
using defold.Gui;

class MGui extends MGuiBase<GuiNode, {}> {

    override function idToTarget(id:Hash):GuiNode {
        return id.get_node();
    }

    override function pick(id:Hash, x:Float, y:Float):Bool {
        return Gui.pick_node(id.get_node(), x, y);
    }
    
}