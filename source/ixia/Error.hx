package ixia;

import haxe.PosInfos;
import lua.Lua;

class Error {
    
    public static function error(message:String, ?posInfos:PosInfos) {
        Lua.error(posInfos.fileName + ':' + posInfos.lineNumber + ": " + message);
    }

}