package ixia.defold.gui;

enum abstract DragDirection(Int) to Int {
    
    var LEFT_RIGHT;
    var RIGHT_LEFT;
    //var UP_DOWN;
    //var DOWN_UP;
    //var OMNI;

    public var horizontal(get, never):Bool;
    inline function get_horizontal() return this == LEFT_RIGHT || this == RIGHT_LEFT; //|| this == OMNI;

    //public var vertical(get, never):Bool;
    //inline function get_vertical() return this == DOWN_UP || this == UP_DOWN || this == OMNI;

}