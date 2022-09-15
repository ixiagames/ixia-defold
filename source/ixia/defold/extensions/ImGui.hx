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

    public static function begin_popup_context_item(id:String, ?flags:Int):Bool;
    public static function open_popup(?id:String, ?flags:Int):Void;
    public static function end_popup():Void;
    
    public static function begin_combo(label:String, preview:String):Bool;
    public static function end_combo():Bool;

    ///// COMPONENTS

    public static function text(text:String):Void;
    /**
        If width or height is inputed, the other will be required.
    **/
    public static function button(text:String, ?width:Int, ?height:Int):Bool;
    public static function selectable(text:String, selected:Bool, ?flags:Int):Bool;
    public static function checkbox(text:String, checked:Bool):CheckboxResult;
    public static function input_int(label:String, value:Int = 0):InputIntResult;

    ///// TABLE

    public static function begin_table(id:String, column:Int, ?flags:Int):Bool;
    public static function end_table():Void;
    public static function table_headers_row():Void;
    public static function table_setup_column(label:String, ?flags:Int, ?init_width_or_weight:Int):Void;
    public static function table_next_row():Void;
    public static function table_next_column():Void;

    ///// LAYOUT

    public static function same_line(?offset:Int):Void;

    ///// STYLE

    public static function push_style_color(color:ImGuiCol, red:Float, green:Float, blue:Float, alpha:Float):Void;
    public static function pop_style_color(count:Int):Void;
    
}

@:native("imgui")
extern enum abstract WindowFlag(Int) from Int to Int {
    
    @:native("WINDOWFLAGS_NONE")                var NONE;
    @:native("WINDOWFLAGS_ALWAYSAUTORESIZE")    var ALWAYSAUTORESIZE;
    @:native("WINDOWFLAGS_NOCOLLAPSE")          var NOCOLLAPSE;

}

@:native("imgui")
extern enum abstract ImGuiCol(Int) from Int to Int {
    
    @:native("ImGuiCol_Button")         var BUTTON;
    @:native("ImGuiCol_ButtonHovered")  var BUTTON_HOVERED;
    @:native("ImGuiCol_ButtonActive")   var BUTTON_ACTIVE;

}

@:native("imgui")
extern enum abstract TableFlag(Int) from Int to Int {
    
    @:native("TABLE_BORDERSINNER")      var BORDERSINNER;
    @:native("TABLE_BORDERS")           var BORDERS;
    @:native("TABLE_CONTEXTMENUINBODY") var CONTEXTMENUINBODY;

}

@:native("imgui")
extern enum abstract PopupFlag(Int) from Int to Int {
    
    @:native("POPUPFLAGS_MOUSEBUTTONRIGHT") var MOUSEBUTTONRIGHT;

}

@:multiReturn extern class BeginWindowResult {

    var result:Bool;
    var isopen:Bool;

}

@:multiReturn extern class CheckboxResult {

    var changed:Bool;
    var checked:Bool;

}

@:multiReturn extern class InputIntResult {

    var changed:Bool;
    var value:Int;

}


