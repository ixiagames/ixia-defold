package ixia.defold.gui.m;

enum abstract TargetState(Int) to Int {
    
    var UNTOUCHED;
    var HOVERED;
    var PRESSED;
    var DRAGGED;
    var SLEEPING;
    
    public var awake(get, never):Bool;
    inline function get_awake() return this != SLEEPING;

    public var dragged(get, never):Bool;
    inline function get_dragged() return this == DRAGGED;

    public var touched(get, never):Bool;
    inline function get_touched() return this == HOVERED || this == PRESSED;

}