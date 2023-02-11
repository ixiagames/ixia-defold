package ixia.defold.utils;

import defold.Gui;
import defold.Http;
import defold.Image;

class Loader {

    public static function loadGuiTexture(url:String, ?textureId:String, callback:(?textureId:String, ?error:String)->Void):Void {
        if (textureId == null)
            textureId = url;
        Http.request(url, "GET", (_, id, res) -> {
            if (res.status == 302 || res.status == 301) {
                loadGuiTexture(res.headers["location"], textureId, callback);

            } else if (res.status == 200 || res.status == 304) {
                var image = Image.load(res.response);
                if (image == null) {
                    Error.error('Unable to load $url.');
                    return;
                }
                var result = Gui.new_texture(textureId, image.width, image.height, image.type, image.buffer);
                if (result.success)
                    callback(textureId);
                else
                    callback(null, 'Gui.new_texute error code ${result.code}.');

            } else
                callback(null, 'Unable to get image: ${res.response}.');
        });
    }
    
}