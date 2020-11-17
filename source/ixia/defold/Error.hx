package ixia.defold;

import haxe.PosInfos;
import lua.Lua;

class Error {
    
    public static inline function error(message:String, ?posInfos:PosInfos) {
        Lua.error(posInfos.fileName + ':' + posInfos.lineNumber + ": " + message);
    }

}