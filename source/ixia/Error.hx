package ixia;

#if hxdefold
typedef Error = ixia.defold.Error;
#else
class Error {
    
    public inline static function error(message:String):Void {
        throw message;
    }

}
#end