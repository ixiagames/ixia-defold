package ixia.defold.utils;

import defold.Gui;
import defold.Http;
import defold.Image;

class Loader {

    public static function loadImage(url:String, callback:(?image:ImageLoadResult, ?error:String)->Void):Void {
        Http.request(url, "GET", (_, id, res) -> {
            if (res.status == 302 || res.status == 301) {
                loadImage(res.headers["location"], callback);

            } else if (res.status == 200 || res.status == 304) {
                var image = Image.load(res.response);
                if (image != null)
                    callback(image);
                else
                    callback(null, 'Unable to load $url.');
            } else
                callback(null, 'Unable to get image: ${res.response}.');
        });
    }

    public static function loadGuiTexture(url:String, ?textureId:String, callback:(?textureId:String, ?error:String)->Void):Void {
        if (textureId == null)
            textureId = url;
        loadImage(url, (?image, ?error) -> {
            if (error != null)
                callback(textureId, error);
            else {
                var result = Gui.new_texture(textureId, image.width, image.height, image.type, image.buffer);
                if (result.success)
                    callback(textureId);
                else
                    callback(textureId, 'Gui.new_texute error code ${result.code}.');
            }
        });
    }
    
}