package ixia.mgui;

enum abstract EventType(Int) to Int {
    
    var CREATE;
    var REMOVE;
    var ENABLE;
    var DISABLE;
    var CLICK;
    var PRESS;
    var RELEASE;
    var ROLL_OUT;
    var ROLL_IN;

}