package ixia;

#if lua
typedef Error = ixia.lua.Error;
#else
class Error {
    
    public inline static function error(message:String):Void {
        throw message;
    }

}
#end