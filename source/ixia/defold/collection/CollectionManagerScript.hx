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

    public var collections(default, null):Array<Collection>;
    var _waitingToLoad:Collection;
    
    override function init(self:CollectionManagerScriptData) {
        super.init(self);

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

    override function on_message<TMessage>(self:CollectionManagerScriptData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        super.on_message(self, message_id, message, sender);
        
        switch (message_id) {
            case CollectionManagerMessages.LOAD_COLLECTION:
                #if debug
                trace("Request to load: " + message.proxyUrl.fragment);
                #end
                for (collection in collections) {
                    if (collection.proxyUrl == message.proxyUrl && collection.loaded)
                        return;
                }

                if (self.singleCollection) {
                    for (collection in collections) {
                        if (collection.loaded)
                            Msg.post(collection.proxyUrl, CollectionproxyMessages.unload);
                    }
                }

                Msg.post(message.proxyUrl, message.async != null && message.async? CollectionproxyMessages.async_load : CollectionproxyMessages.load);

            case CollectionManagerMessages.UNLOAD_COLLECTION:
                #if debug
                trace("Request to unload: " + message.proxyUrl.fragment);
                #end
                Msg.post(message.proxyUrl, CollectionproxyMessages.unload);

            case CollectionManagerMessages.ENABLE_COLLECTION:
                #if debug
                trace("Request to enable: " + message.proxyUrl.fragment);
                #end
                Msg.post(message.proxyUrl, CollectionproxyMessages.enable);

            case CollectionManagerMessages.DISABLE_COLLECTION:
                #if debug
                trace("Request to disable: " + message.proxyUrl.fragment);
                #end
                Msg.post(message.proxyUrl, CollectionproxyMessages.disable);

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