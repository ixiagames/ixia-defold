package ixia.defold.gui;

import defold.types.HashOrString;
import defold.types.Vector3;
import ixia.defold.types.Hash;
import ixia.defold.types.Rgba;
import lua.Table;

using defold.Gui;

@:forward
@:using(defold.Gui)
abstract ExtGuiNode(GuiNode) from GuiNode to GuiNode {

    public static inline function getNode(id:HashOrString):ExtGuiNode {
        return id.get_node();
    }

    //

    public var id(get, set):Hash;
    inline function get_id() return this.get_id();
    inline function set_id(value) {
        this.set_id(value);
        return value;
    }

    //

    public var enabled(get, set):Bool;
    inline function get_enabled() return this.is_enabled();
    inline function set_enabled(value) {
        this.set_enabled(value);
        return value;
    }

    //

    public var parent(get, never):ExtGuiNode;
    inline function get_parent() return this.get_parent();

    //

    public var size(get, set):Vector3;
    inline function get_size() return this.get_size();
    inline function set_size(value) {
        this.set_size(value);
        return value;
    }

    public var width(get, set):Float;
    inline function get_width() return this.get_size().x;
    inline function set_width(value) {
        // Would using this.animate("size.x", value, EASING_LINEAR, 0) better?
        var size = this.get_size();
        size.x = value;
        this.set_size(size);
        return value;
    }

    public var height(get, set):Float;
    inline function get_height() return this.get_size().y;
    inline function set_height(value) {
        // Would using this.animate("size.x", value, EASING_LINEAR, 0) better?
        var size = this.get_size();
        size.y = value;
        this.set_size(size);
        return value;
    }

    public var size_mode(get, set):GuiSizeMode;
    inline function get_size_mode() return this.get_size_mode();
    inline function set_size_mode(value) {
        this.set_size_mode(value);
        return value;
    }

    //

    public var position(get, set):Vector3;
    inline function get_position() return this.get_position();
    inline function set_position(value) {
        this.set_position(value);
        return value;
    }

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

    //

    public var scale(get, set):Vector3;
    inline function get_scale() return this.get_scale();
    inline function set_scale(value) {
        this.set_scale(value);
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

    //

    public var rotation(get, set):Vector3;
    inline function get_rotation() return this.get_rotation();
    inline function set_rotation(value) {
        this.set_rotation(value);
        return value;
    }

    public var rotation_x(get, set):Float;
    inline function get_rotation_x() return this.get_rotation().x;
    inline function set_rotation_x(value) {
        var rotation = this.get_rotation();
        rotation.x = value;
        this.set_rotation(rotation);
        return value;
    }

    public var rotation_y(get, set):Float;
    inline function get_rotation_y() return this.get_rotation().y;
    inline function set_rotation_y(value) {
        var rotation = this.get_rotation();
        rotation.y = value;
        this.set_rotation(rotation);
        return value;
    }

    public var rotation_z(get, set):Float;
    inline function get_rotation_z() return this.get_rotation().z;
    inline function set_rotation_z(value) {
        var rotation = this.get_rotation();
        rotation.z = value;
        this.set_rotation(rotation);
        return value;
    }

    //

    public var color(get, set):Rgba;
    inline function get_color() return this.get_color();
    inline function set_color(value:Rgba) {
        this.set_color(value);
        return value;
    }

    public var red(get, set):Float;
    inline function get_red() return this.get_color().x;
    inline function set_red(value) {
        var color = this.get_color();
        color.x = value;
        this.set_color(color);
        return value;
    }

    public var green(get, set):Float;
    inline function get_green() return this.get_color().y;
    inline function set_green(value) {
        var color = this.get_color();
        color.y = value;
        this.set_color(color);
        return value;
    }

    public var blue(get, set):Float;
    inline function get_blue() return this.get_color().z;
    inline function set_blue(value) {
        var color = this.get_color();
        color.z = value;
        this.set_color(color);
        return value;
    }

    public var alpha(get, set):Float;
    inline function get_alpha() return this.get_color().w;
    inline function set_alpha(value) {
        var color = this.get_color();
        color.w = value;
        this.set_color(color);
        return value;
    }

    //

    public var text(get, set):String;
    inline function get_text() return this.get_text();
    inline function set_text(value) {
        this.set_text(value);
        return value;
    }

    //

    public var pivot(get, set):GuiPivot;
    inline function get_pivot() return this.get_pivot();
    inline function set_pivot(value) {
        this.set_pivot(value);
        return value;
    }

    //

    public inline function clone():ExtGuiNode {
        return this.clone();
    }

    public inline function cloneTree():Table<Hash, ExtGuiNode> {
        return this.clone_tree();
    }

}