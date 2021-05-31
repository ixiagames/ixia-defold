package ixia.defold.extensions;

/**
 * https://github.com/AGulev/jstodef
 */
@:native("jstodef")
extern class JsToDef {

    /**
     * `listener` is a function with the next parameters:
     *  - `self` is the current script self.
     *  - `message_id` is a string that helps you to identify this message.
     *  - `message` is a custom value that might be one of the next types: table, number, boolean, string, nil.
    **/
    static function add_listener(listener:(self:Dynamic, message_id:String, message:Dynamic)->Void):Void;

}