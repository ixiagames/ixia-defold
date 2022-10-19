package ixia.defold.collection;

import defold.types.Url;
import ixia.defold.collection.CollectionDownloader.DownloadOptions;
import ixia.defold.collection.CollectionManagerScript.CollectionManagerScriptData;

@:access(ixia.defold.collection.CollectionDownloader)
class Collection<T:CollectionManagerScriptData> {

    public var name(default, null):String;
    public var manager(default, null):CollectionManagerScript<T>;
    public var proxyUrl(default, null):Url;
    public var enabled(default, set):Bool;
    public var state(default, null):CollectionState = UNLOADED;
    public var downloader(default, null):CollectionDownloader<T>;
    public var onLoaded:Collection<T>->Void;
    public var onUnloaded:Collection<T>->Void;

    public function new(manager:CollectionManagerScript<T>, name:String, proxyUrl:Url) {
        this.name = name;
        this.manager = manager;
        this.proxyUrl = proxyUrl;
        manager.collections[name] = this;
    }

    public function load(?async:Bool = false, ?callback:Collection<T>->Void):Void {
        state = LOADING;
        if (callback != null)
            onLoaded = callback;
        manager.post_loadCollection(proxyUrl, async);
    }

    public function unload(?callback:Collection<T>->Void):Void {
        state = UNLOADING;
        if (callback != null)
            onUnloaded = callback;
        manager.post_unloadCollection(proxyUrl);
    }

    public function download(options:DownloadOptions<T>):Void {
        downloader = new CollectionDownloader(this, options);
        downloader.download();
    }

    function set_enabled(value) {
        if (value) {
            manager.post_enableCollection(proxyUrl);
            state = ENABLED;
        } else {
            manager.post_disableCollection(proxyUrl);
            state = DISABLED;
        }
        return enabled = value;
    }
    
}

enum abstract CollectionState(#if debug String #else Int #end) to #if debug String #else Int #end {

    var UNLOADED;
    var LOADING;
    var UNLOADING;

    // Both DISABLED & ENABLED mean the collection was loaded.
    var DISABLED;
    var ENABLED;

    public var loaded(get, never):Bool;
    inline function get_loaded() return this == DISABLED || this == ENABLED; 
    
}