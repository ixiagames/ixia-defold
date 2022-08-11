package ixia.defold.collection;

import defold.types.Url;
import ixia.defold.collection.CollectionDownloader.DownloadOptions;
import ixia.defold.collection.CollectionManagerScript.CollectionManagerScriptData;

@:access(ixia.defold.collection.CollectionDownloader)
class Collection<T:CollectionManagerScriptData> {

    public var manager(default, null):CollectionManagerScript<T>;
    public var proxyUrl(default, null):Url;
    public var enabled(default, set):Bool;
    public var loaded(default, null):Bool;
    public var downloader(default, null):CollectionDownloader<T>;
    public var userData:Dynamic;
    public var onLoaded:Collection<T>->Void;
    public var onUnloaded:Collection<T>->Void;

    function new(manager:CollectionManagerScript<T>, proxyUrl:Url) {
        this.manager = manager;
        this.proxyUrl = proxyUrl;
    }

    public function load(?async:Bool = false, ?callback:Collection<T>->Void):Void {
        if (callback != null)
            onLoaded = callback;
        manager.post_loadCollection(proxyUrl, async);
    }

    public function unload(?callback:Collection<T>->Void):Void {
        if (callback != null)
            onUnloaded = callback;
        manager.post_unloadCollection(proxyUrl);
    }

    public function download(options:DownloadOptions<T>):Void {
        downloader = new CollectionDownloader(this, options);
        downloader.download();
    }

    function set_enabled(value) {
        if (value)
            manager.post_enableCollection(proxyUrl);
        else
            manager.post_disableCollection(proxyUrl);
        return enabled = value;
    }
    
}