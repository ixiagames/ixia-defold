package ixia.defold.types;

import defold.types.Vector4;
import defold.Vmath;

@:forward(x, y)
abstract Rectangle(Vector4) {

    public inline function new(x:Float, y:Float, w:Float, h:Float) {
        this = Vmath.vector4(x, y, w, h);
    }

    public var w(get, never):Float;
    inline function get_w() return this.z;

    public var h(get, never):Float;
    inline function get_h() return this.w;
    
}