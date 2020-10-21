package ixia.defold.types;

import defold.Vmath;
import defold.types.Vector4;
using defold.Sys;
using lua.Lua;

abstract Rgba(Vector4) from Vector4 to Vector4 {

    public static function fromConfigClearColor():Rgba {
        var rs = "Render.clear_color_red".get_config();
        var gs = "Render.clear_color_green".get_config();
        var bs = "Render.clear_color_blue".get_config();
        var as = "Render.clear_color_alpha".get_config();
        return new Rgba(
            rs != null ? rs.tonumber() : 0,
            gs != null ? gs.tonumber() : 0,
            bs != null ? bs.tonumber() : 0,
            as != null ? as.tonumber() : 1
        );
    }

    public inline function new(r:Float, g:Float, b:Float, a:Float) {
        this = Vmath.vector4(r, g, b, a);
    }

    public var r(get, never):Float;
    inline function get_r() return this.x;

    public var g(get, never):Float;
    inline function get_g() return this.y;

    public var b(get, never):Float;
    inline function get_b() return this.z;

    public var w(get, never):Float;
    inline function get_w() return this.w;
    
}