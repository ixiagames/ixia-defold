package ixia.defold.gui.m;

import ixia.defold.gui.m.TargetState;

enum Event {
    
    WAKE;
    TAP;
    STATE(?state:TargetState);

}