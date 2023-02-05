package ixia.defold.extensions;

@:luaRequire("defsave.defsave")
extern class DefSave {

    public static var appname:String;
    public static var verbose:Bool;
    
    public static function load(file:String):Void;
    public static function get(file:String, key:String):Dynamic;
    public static function set(file:String, key:String, value:Dynamic):Void;
    public static function save(file:String):Void;
    public static function save_all(force:Bool = false):Void;
    public static function update(delta:Float):Void;

}