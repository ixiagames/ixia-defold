package ixia.defold.extensions.imgui;

@:native("imgui")
extern class ImGui {

    public static function demo():Void;

    public static function font_add_ttf_data(ttf_data:String, ttf_data_size:Int, font_size:Int, font_pixels:Int):Int;
    
}