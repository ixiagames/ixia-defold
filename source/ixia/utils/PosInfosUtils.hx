package ixia.utils;

class PosInfosUtils {
    
    public inline static function toString(posInfos:haxe.PosInfos):String {
        return posInfos.fileName + ':' + posInfos.lineNumber;
    }

    public inline static function toStringWithMessage(posInfos:haxe.PosInfos, message:String):String {
        return posInfos.fileName + ':' + posInfos.lineNumber + ": " + message;
    }

}