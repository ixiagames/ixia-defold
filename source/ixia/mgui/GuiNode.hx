package ixia.mgui;

import defold.Gui;

abstract GuiNode(defold.Gui.GuiNode) from defold.Gui.GuiNode to defold.Gui.GuiNode {

    public inline function pick(x:Float, y:Float):Bool {
        return Gui.pick_node(this, x, y);
    }
    
}