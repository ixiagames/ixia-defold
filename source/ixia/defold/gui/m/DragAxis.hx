package ixia.defold.gui.m;

enum abstract DragAxis(Int) to Int {
    
    var X;
    var Y;
    var XY;

    public var horizontal(get, never):Bool;
    inline function get_horizontal() return this == X || this == XY;

    public var vertical(get, never):Bool;
    inline function get_vertical() return this == Y || this == XY;

}