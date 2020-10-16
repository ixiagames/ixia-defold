package ixia.defold.mgui;

enum abstract TargetPointerState(Int) to Int {
    
    var OUT;
    var HOVER;
    var DOWN;
    var DOWN_OUT;

    public inline function isIn():Bool {
        return this == HOVER || this == DOWN;
    }
    
    public inline function isDown():Bool {
        return this == DOWN || this == DOWN_OUT;
    }

}