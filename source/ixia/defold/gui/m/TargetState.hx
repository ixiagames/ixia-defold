package ixia.defold.gui.m;

enum abstract TargetState(Int) to Int {
    
    var UNTOUCHED;
    var HOVERED;
    var PRESSED;
    var DRAGGED;
    var SLEEPING;

    public var dragged(get, never):Bool;
    inline function get_dragged() return this == DRAGGED;

    public inline function isIn():Bool {
        return this == HOVERED || this == PRESSED;
    }

    public inline function isAwake():Bool {
        return this != SLEEPING;
    }

}