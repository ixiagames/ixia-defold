package ixia.defold.types;

import defold.types.Vector4;
import defold.Vmath;

@:forward(x, y)
abstract Rectangle(Vector4) from Vector4 to Vector4 {

    public inline function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
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

    public var w(get, set):Float;
    inline function get_w() return this.z;
    inline function set_w(value) return this.z = value;

    public var h(get, set):Float;
    inline function get_h() return this.w;
    inline function set_h(value) return this.w = value;
    
}