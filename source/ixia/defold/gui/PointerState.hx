package ixia.defold.gui;

enum abstract PointerState(Int) to Int {
    
    var PRESSED;
    var JUST_PRESSED;
    var RELEASED;
    var JUST_RELEASED;

    public inline function isPressed():Bool {
        return this == PRESSED || this == JUST_PRESSED;
    }

    public inline function justChanged():Bool {
        return this == JUST_PRESSED || this == JUST_RELEASED;
    }

}