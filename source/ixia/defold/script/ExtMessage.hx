package ixia.defold.script;

import defold.Msg;
import defold.types.Hash;
import defold.types.HashOrStringOrUrl;
import defold.types.Message;
import defold.types.Url;

abstract ExtMessage<T>(Message<T>) from Message<T> to Message<T> {

    static var _map:Map<Hash, Array<Url>>;

    public function new(id:String) {
        this = new Message(id);
    }

    /**
        Post to a specific receiver. 
    **/
    public inline function post(receiver:HashOrStringOrUrl, ?message:T):Void {
        Msg.post(receiver, this, message);
    }

    /**
        Post to all subscribers. 
    **/
    public inline function dispatch(?message:T):Void {
        if (_map == null) {
            Error.error("No subscriber.");
            return;
        }
        
        var urls = _map[cast this];
        if (urls == null) {
            Error.error("No subscriber.");
            return;
        }

        for (url in urls)
            post(url, message);
    }

    public function subscribe():Void {
        if (_map == null) {
            _map = [ (cast this) => [ Msg.url() ] ];
            return;
        }

        var urls = _map[cast this];
        if (urls == null) {
            _map[cast this] = [ Msg.url() ];
            return;
        }

        var url = Msg.url();
        for (u in urls) {
            if (u.fragment == url.fragment && u.path == url.path && u.socket == url.socket)
                return;
        }

        urls.push(url);
    }
    
}