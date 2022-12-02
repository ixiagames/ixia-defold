package ixia.defold.gui;

enum abstract TargetState #if debug (String) to String #else (Int) to Int #end {
    
    var UNTOUCHED;
    var HOVERED;
    var PRESSED;
    var DRAGGED;
    var SLEEPING;

    @:from public static function fromString(s:String):TargetState {
        return switch (s.toLowerCase()) {
            case "untouched":   UNTOUCHED;
            case "hovered":     HOVERED;
            case "pressed":     PRESSED;
            case "dragged":     DRAGGED;
            case "sleeping":    SLEEPING;
            case _:
                Error.error('Invalid string $s.');
                null; 
        }
    }

    @:to public function toString():String {
        return switch (cast this) {
            case UNTOUCHED: "untouched";
            case HOVERED:   "hovered";
            case PRESSED:   "pressed";
            case DRAGGED:   "dragged";
            case SLEEPING:  "sleeping";
        }
    }
    
    public var awake(get, never):Bool;
    inline function get_awake() return this != SLEEPING;

    public var dragged(get, never):Bool;
    inline function get_dragged() return this == DRAGGED;

    public var touched(get, never):Bool;
    inline function get_touched() return this == HOVERED || this == PRESSED;

}