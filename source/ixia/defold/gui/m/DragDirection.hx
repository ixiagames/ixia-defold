package ixia.defold.gui.m;

enum abstract DragDirection(Int) to Int {
    
    var X_RIGHT;
    var X_LEFT;
    //var Y_UP;
    //var Y_DOWN;
    //var XY;

    public var horizontal(get, never):Bool;
    inline function get_horizontal() return this == X_RIGHT || this == X_LEFT; //|| this == XY;

    //public var vertical(get, never):Bool;
    //inline function get_vertical() return this == Y_DOWN || this == Y_UP || this == XY;

}