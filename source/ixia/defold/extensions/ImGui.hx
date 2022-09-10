package ixia.defold.extensions;

@:native("imgui")
extern class ImGui {

    public static function demo():Void;

    public static function font_add_ttf_data(ttf_data:String, ttf_data_size:Int, font_size:Int, font_pixels:Int):Int;

    ///// MENU BAR

    public static function begin_main_menu_bar():Bool;
    public static function end_main_menu_bar():Void;

    public static function begin_menu(label:String, ?enabled:Bool):Bool;
    public static function end_menu():Void;

    public static function menu_item(label:String, ?shortcut:String, ?selected:String, ?enabled:Bool):Bool;

    ///// WINDOW

    public static function begin_window(title:String, ?open:Bool, ?flags:Int = 0):BeginWindowResult;
    public static function end_window():Void;

    ///// COMBO

    public static function begin_combo(label:String, preview:String):Bool;
    public static function end_combo():Bool;

    ///// COMPONENTS

    public static function text(text:String):Void;
    public static function button(text:String):Bool;

    ///// TABLE

    public static function begin_table(id:String, column:Int, ?flags:Int):Bool;
    public static function end_table():Void;
    public static function table_headers_row():Void;
    public static function table_setup_column(label:String, ?flags:Int, ?init_width_or_weight:Int):Void;
    public static function table_next_row():Void;
    public static function table_next_column():Void;
    
}


@:native("imgui")
extern enum abstract WindowFlag(Int) from Int to Int {
    
    @:native("WINDOWFLAGS_NONE")                var NONE;
    @:native("WINDOWFLAGS_ALWAYSAUTORESIZE")    var ALWAYSAUTORESIZE;
    @:native("WINDOWFLAGS_NOCOLLAPSE")          var NOCOLLAPSE;

}

@:multiReturn extern class BeginWindowResult {

    var result:Bool;
    var isopen:Bool;

}