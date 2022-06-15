package ixia.defold.collection;

import defold.types.Url;
import ixia.defold.collection.CollectionDownloader.DownloadOptions;

@:access(ixia.defold.collection.CollectionDownloader)
class Collection {

    public var manager(default, null):CollectionManagerScript;
    public var proxyUrl(default, null):Url;
    public var enabled(default, set):Bool;
    public var loaded(default, null):Bool;
    public var downloader(default, null):CollectionDownloader;
    public var userData:Dynamic;
    public var onLoaded:Collection->Void;
    public var onUnloaded:Collection->Void;

    function new(manager:CollectionManagerScript, proxyUrl:Url) {
        this.manager = manager;
        this.proxyUrl = proxyUrl;
    }

    public function load(async:Bool = false, ?callback:Collection->Void):Void {
        if (callback != null)
            onLoaded = callback;
        manager.post(CollectionManagerMessages.LOAD_COLLECTION, { proxyUrl: proxyUrl, async: async });
    }

    public function unload(?callback:Collection->Void):Void {
        if (callback != null)
            onUnloaded = callback;
        manager.post(CollectionManagerMessages.UNLOAD_COLLECTION, { proxyUrl: proxyUrl });
    }

    public function download(options:DownloadOptions):Void {
        downloader = new CollectionDownloader(this, options);
        downloader.download();
    }

    function set_enabled(value) {
        manager.post(
            value ?
                CollectionManagerMessages.ENABLE_COLLECTION :
                CollectionManagerMessages.DISABLE_COLLECTION,
            { proxyUrl: proxyUrl }
        );
        return enabled = value;
    }
    
}