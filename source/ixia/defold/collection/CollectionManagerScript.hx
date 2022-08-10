package ixia.defold.collection;

import defold.Collectionproxy.CollectionproxyMessages;
import defold.Msg;
import defold.types.Message;
import defold.types.Url;
import ixia.defold.scripts.ExtScript;

using ixia.defold.UrlTools;

typedef CollectionManagerScriptData = {

    @property(true) var singleCollection:Bool;

}

@:access(ixia.defold.collection.Collection)
class CollectionManagerScript extends ExtScript<CollectionManagerScriptData> {

    public var options(default, null):CollectionManagerScriptData;
    public var collections(default, null):Array<Collection>;
    var _waitingToLoad:Collection;
    
    override function init(options:CollectionManagerScriptData) {
        super.init(options);

        this.options = options;
        collections = [];
    }

    public function post<T>(messageId:Message<T>, message:T):Void {
        Msg.post(url, messageId, message);
    }

    public function add(proxyUrl:Url, ?userData:Dynamic):Collection {
        var collection = new Collection(this, proxyUrl);
        collections.push(collection);
        collection.userData = userData;
        return collection;
    }

    public function get(proxyUrl:Url):Collection {
        for (collection in collections) {
            if (collection.proxyUrl.compare(proxyUrl))
                return collection;
        }
        return null;
    }

    public function getLoaded():Array<Collection> {
        return [ for (collection in collections) if (collection.loaded) collection ];
    }

    public function getUnloaded():Array<Collection> {
        return [ for (collection in collections) if (!collection.loaded) collection ];
    }

    @post function loadCollection(proxyUrl:Url, async:Bool = false):Void {
        #if debug
        trace("Request to load: " + proxyUrl.fragment);
        #end
        for (collection in collections) {
            if (collection.proxyUrl == proxyUrl && collection.loaded)
                return;
        }

        if (options.singleCollection) {
            for (collection in collections) {
                if (collection.loaded)
                    Msg.post(collection.proxyUrl, CollectionproxyMessages.unload);
            }
        }

        Msg.post(proxyUrl, async? CollectionproxyMessages.async_load : CollectionproxyMessages.load);
    }

    @post function unloadCollection(proxyUrl:Url):Void {
        #if debug
        trace("Request to unload: " + proxyUrl.fragment);
        #end
        Msg.post(proxyUrl, CollectionproxyMessages.unload);
    }

    @post function enableCollection(proxyUrl:Url):Void {
        #if debug
            trace("Request to enable: " + proxyUrl.fragment);
            #end
            Msg.post(proxyUrl, CollectionproxyMessages.enable);
    }

    @post function disableCollection(proxyUrl:Url):Void {
        #if debug
        trace("Request to disable: " + proxyUrl.fragment);
        #end
        Msg.post(proxyUrl, CollectionproxyMessages.disable);
    }

    override function on_message<TMessage>(options:CollectionManagerScriptData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        super.on_message(options, message_id, message, sender);
        
        switch (message_id) {
            case CollectionproxyMessages.proxy_loaded:
                #if debug
                trace("Proxy loaded: " + sender.fragment);
                #end

                var collection = get(sender);
                collection.loaded = true;
                if (collection.onLoaded != null)
                    collection.onLoaded(collection);

            case CollectionproxyMessages.proxy_unloaded:
                #if debug
                trace("Proxy unloaded: " + sender.fragment);
                #end

                var collection = get(sender);
                collection.loaded = false;
                if (collection.onUnloaded != null)
                    collection.onUnloaded(collection);
        }
    }
    
}