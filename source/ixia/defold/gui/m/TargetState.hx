package ixia.defold.gui.m;

enum abstract TargetState(Int) to Int {
    
    var UNTOUCHED;
    var HOVERED;
    var PRESSED;
    var SLEEPING;

    public inline function isIn():Bool {
        return this == HOVERED || this == PRESSED;
    }

    public inline function isAwake():Bool {
        return this != SLEEPING;
    }

}