package ixia.defold.extensions;

@:native("imgui")
extern class ImGui {

    public static function demo():Void;

    public static function font_add_ttf_data(ttf_data:String, ttf_data_size:Int, font_size:Int, font_pixels:Int):Int;

    ///// MENU BAR

    public static function begin_main_menu_bar():Bool;
    public static function end_main_menu_bar():Void;

    public static function begin_menu_bar():Bool;
    public static function end_menu_bar():Void;

    public static function begin_menu(label:String, ?enabled:Bool):Bool;
    public static function end_menu():Void;

    public static function menu_item(label:String, ?shortcut:String, ?selected:String, ?enabled:Bool):Bool;

    ///// WINDOW

    public static function begin_window(title:String, ?open:Bool, ?flags:WindowFlag = 0):WindowResult;
    public static function end_window():Void;

    public static function begin_child(title:String, ?width:Int, ?height:Int):Bool;
    public static function end_child():Void;

    ///// COMBO

    public static function begin_popup_context_item(id:String, ?flags:PopupFlag):Bool;
    public static function begin_popup(id:String, ?flags:PopupFlag):Bool;
    public static function open_popup(?id:String, ?flags:PopupFlag):Void;
    public static function end_popup():Void;
    
    public static function begin_combo(label:String, preview:String):Bool;
    public static function end_combo():Bool;

    ///// COMPONENTS

    public static function text(text:String):Void;
    /**
        If width or height is inputed, the other will be required.
    **/
    public static function button(text:String, ?width:Int, ?height:Int):Bool;
    public static function selectable(text:String, selected:Bool, ?flags:SelectableFlag):Bool;
    public static function checkbox(text:String, checked:Bool):CheckboxResult;
    public static function input_int(label:String, value:Int = 0):InputResult<Int>;
    public static function input_text(label:String, text:String, flags:Int):InputResult<String>;

    ///// TABLE

    public static function begin_table(id:String, column:Int, ?flags:TableFlag):Bool;
    public static function end_table():Void;
    public static function table_headers_row():Void;
    public static function table_setup_column(label:String, ?flags:ColumnFlag, ?init_width_or_weight:Int):Void;
    public static function table_next_row():Void;
    public static function table_next_column():Void;

    ///// TAB BAR

    public static function begin_tab_bar(id:String):Bool;
    public static function end_tab_bar():Void;
    public static function begin_tab_item(label:String, ?open:Bool, ?flags:Int):TabItemResult;
    public static function end_tab_item():Void;

    ///// LAYOUT

    public static function same_line(?offset:Int):Void;

    ///// STYLE

    public static function push_style_color(color:ImGuiCol, red:Float, green:Float, blue:Float, alpha:Float):Void;
    public static function pop_style_color(count:Int):Void;

    ///// INPUT

    public static function is_item_clicked(button:MouseButton):Bool;

    ///// NAVIGATION

    public static function set_scroll_here_y(center_y_ratio:Float):Void;
    
}

@:native("imgui")
extern enum abstract WindowFlag(Int) from Int to Int {
    
    @:native("WINDOWFLAGS_NONE")                var NONE;
    @:native("WINDOWFLAGS_ALWAYSAUTORESIZE")    var ALWAYS_AUTO_RESIZE;
    @:native("WINDOWFLAGS_NOCOLLAPSE")          var NO_COLLAPSE;
    @:native("WINDOWFLAGS_MENUBAR")             var MENU_BAR;

}

@:native("imgui")
extern enum abstract ImGuiCol(Int) from Int to Int {
    
    @:native("ImGuiCol_Button")         var BUTTON;
    @:native("ImGuiCol_ButtonHovered")  var BUTTON_HOVERED;
    @:native("ImGuiCol_ButtonActive")   var BUTTON_ACTIVE;
    @:native("ImGuiCol_TableRowBg")     var TABLE_ROW_BG;
    @:native("ImGuiCol_TableRowBgAlt")  var TABLE_ROW_BG_ALT;

}

@:native("imgui")
extern enum abstract TableFlag(Int) from Int to Int {
    
    @:native("TABLE_BORDERSINNER")      var BORDERS_INNER;
    @:native("TABLE_BORDERS")           var BORDERS;
    @:native("TABLE_CONTEXTMENUINBODY") var CONTEXT_MENU_IN_BODY;
    @:native("TABLE_ROWBG")             var ROW_BG;

}

@:native("imgui")
extern enum abstract ColumnFlag(Int) from Int to Int {
    
    @:native("TABLECOLUMN_NONE")                    var NONE;
    @:native("TABLECOLUMN_DEFAULTHIDE")             var DEFAULT_HIDE;
    @:native("TABLECOLUMN_DEFAULTSORT")             var DEFAULT_SORT;
    @:native("TABLECOLUMN_WIDTHSTRETCH")            var WIDTH_STRETCH;
    @:native("TABLECOLUMN_WIDTHFIXED")              var WIDTH_FIXED;
    @:native("TABLECOLUMN_NORESIZE")                var NO_RESIZE;
    @:native("TABLECOLUMN_NOREORDER")               var NO_REORDER;
    @:native("TABLECOLUMN_NOHIDE")                  var NO_HIDE;
    @:native("TABLECOLUMN_NOCLIP")                  var NO_CLIP;
    @:native("TABLECOLUMN_NOSORT")                  var NO_SORT;
    @:native("TABLECOLUMN_NOSORTASCENDING")         var NO_SORT_ASCENDING;
    @:native("TABLECOLUMN_NOSORTDESCENDING")        var NO_SORT_DESCENDING;
    @:native("TABLECOLUMN_NOHEADERWIDTH")           var NO_HEADER_WIDTH;
    @:native("TABLECOLUMN_PREFERSORTASCENDING")     var PREFER_SORT_ASCENDING;
    @:native("TABLECOLUMN_PREFERSORTDESCENDING")    var PREFER_SORT_DESCENDING;
    @:native("TABLECOLUMN_INDENTENABLE")            var INDENT_ENABLE;
    @:native("TABLECOLUMN_INDENTDISABLE")           var INDENT_DISABLE;

}

@:native("imgui")
extern enum abstract PopupFlag(Int) from Int to Int {
    
    @:native("POPUPFLAGS_MOUSEBUTTONRIGHT") var MOUSE_BUTTON_RIGHT;

}

@:native("imgui")
extern enum abstract SelectableFlag(Int) from Int to Int {
    
    @:native("SELECTABLE_SPAN_ALL_COLUMNS") var SPAN_ALL_COLUMNS;

}

@:native("imgui")
extern enum abstract MouseButton(Int) {
    
    @:native("MOUSEBUTTON_LEFT")    var LEFT;
    @:native("MOUSEBUTTON_RIGHT")   var RIGHT;
    @:native("MOUSEBUTTON_MIDDLE")  var MIDDLE;

}

@:multiReturn extern class WindowResult {

    var open:Bool;
    var result:Bool;

}

@:multiReturn extern class CheckboxResult {

    var changed:Bool;
    var checked:Bool;

}

@:multiReturn extern class InputResult<T> {

    var changed:Bool;
    var value:T;

}

@:multiReturn extern class TabItemResult {

    var open:Bool;
    var result:Bool;

}



