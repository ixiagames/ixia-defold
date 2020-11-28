package ixia.defold.gui;

using defold.Gui;

@:using(defold.Gui)
abstract ExtGuiNode(GuiNode) from GuiNode to GuiNode {

    public var x(get, set):Float;
    inline function get_x() return this.get_position().x;
    inline function set_x(value) {
        // Would using this.animate("position.x", value, EASING_LINEAR, 0) better?
        var pos = this.get_position();
        pos.x = value;
        this.set_position(pos);
        return value;
    }

    public var y(get, set):Float;
    inline function get_y() return this.get_position().y;
    inline function set_y(value) {
        var pos = this.get_position();
        pos.y = value;
        this.set_position(pos);
        return value;
    }

    public var scale_x(get, set):Float;
    inline function get_scale_x() return this.get_scale().x;
    inline function set_scale_x(value) {
        var scale = this.get_scale();
        scale.x = value;
        this.set_scale(scale);
        return value;
    }

    public var scale_y(get, set):Float;
    inline function get_scale_y() return this.get_scale().y;
    inline function set_scale_y(value) {
        var scale = this.get_scale();
        scale.y = value;
        this.set_scale(scale);
        return value;
    }

}