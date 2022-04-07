package ixia.defold;

import haxe.PosInfos;
import lua.Lua;

using ixia.utils.PosInfosUtils;

class Error {
    
    public static inline function error(message:String, ?posInfos:PosInfos) {
        Lua.error(posInfos.toStringWithMessage(message));
    }

}