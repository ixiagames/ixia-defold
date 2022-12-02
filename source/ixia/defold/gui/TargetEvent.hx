package ixia.defold.gui;

enum abstract TargetEvent(Int) to Int {
    
    var LEAVE;
    var ENTER;
    var PRESS;
    var RELEASE;
    var TAP;
    var DRAG;
    var VALUE;
    var WAKE;
    var SLEEP;

    @:from public static function fromString(s:String):TargetEvent {
        return switch (s.toLowerCase()) {
            case "leave":   LEAVE;
            case "enter":   ENTER;
            case "press":   PRESS;
            case "release": RELEASE;
            case "tap":     TAP;
            case "drag":    DRAG;
            case "value":   VALUE;
            case "wake":    WAKE;
            case "sleep":   SLEEP;
            case _:
                Error.error('Invalid string $s.');
                null;
        }
    }

    @:to public function toString():String {
        return switch (cast this) {
            case LEAVE:     "leave";
            case ENTER:     "enter";
            case PRESS:     "press";
            case RELEASE:   "release";
            case TAP:       "tap";
            case DRAG:      "drag";
            case VALUE:     "value";
            case WAKE:      "wake";
            case SLEEP:     "sleep";
        }
    }

}