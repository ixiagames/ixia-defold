package ixia.defold.types;

import defold.types.Vector4;
import defold.Vmath;

@:forward(x, y)
abstract Rectangle(Vector4) {

    public inline function new(x:Float, y:Float, w:Float, h:Float) {
        this = Vmath.vector4(x, y, w, h);
    }

    public inline function set(x:Float, y:Float, w:Float, h:Float):Void {
        setXY(x, y);
        setWH(w, h);
    }

    public inline function setXY(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;
    }

    public inline function setWH(w:Float, h:Float):Void {
        this.z = w;
        this.w = h;
    }

    public var w(get, never):Float;
    inline function get_w() return this.z;

    public var h(get, never):Float;
    inline function get_h() return this.w;
    
}