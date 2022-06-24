package ixia;

import haxe.PosInfos;

using ixia.utils.PosInfosUtils;

class Error {
    
    public static function error(message:String, ?posInfos:PosInfos) {
        #if hxdefold
        lua.Lua.error(posInfos.toStringWithMessage(message));
        #else
        throw posInfos.toStringWithMessage(message);
        #end
    }

}