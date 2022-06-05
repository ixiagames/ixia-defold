package ixia.defold.collection;

import defold.Http;
import defold.Resource;
import ixia.defold.collection.Collection;

using lua.PairTools;
using lua.Table;

typedef DownloadOptions = {

    path:String,
    /* Default to 3. */
    ?maxSimulResources:Int,
    /* Default to NONE. */
    ?autoLoad:AutoLoadMode,
    /* Default to false. */
    ?autoEnable:Bool,
    ?onProgress:CollectionDownloader->Void,
    ?onError:String->Void

}

enum abstract AutoLoadMode(Int) {
    
    var NONE;
    var SYNC;
    var ASYNC;

}

class CollectionDownloader {

    public var collection(default, null):Collection;
    public var path(default, null):String;
    public var maxSimulResources(default, null):Int;
    public var autoLoad(default, null):AutoLoadMode;
    public var autoEnable(default, null):Bool;
    public var onProgress:CollectionDownloader->Void; // whatever passed to this function would becomes null 
    public var onError:String->Void;

    public var allResources(default, null):Array<String>;
    public var pendingResources(default, never):Array<String> = [];
    public var downloadedResources(default, never):Array<String> = [];
    public var resourceManifest(default, null):ResourceManifestReference;
    public var progress(get, never):Float;
    
    function new(collection:Collection, options:DownloadOptions) {
        this.collection = collection;
        path = options.path;
        maxSimulResources = options.maxSimulResources != null ? options.maxSimulResources : 3;
        autoLoad = options.autoLoad != null ? options.autoLoad : NONE;
        autoEnable = options.autoEnable != null ? options.autoEnable : false;
        onProgress = options.onProgress;
        onError = options.onError;

        // When this was writtten, defold.Collectionproxy lacks the proper metadata for it to work.
        var table:Table<Int, String> = untyped __lua__("_G.collectionproxy.missing_resources({0})", collection.proxyUrl);
        allResources = [ for (entry in table.ipairsIterator()) entry.value ];
        resourceManifest = resourceManifest != null ? resourceManifest : Resource.get_current_manifest();
    }
    
    function download():Void {
        if (allResources.length == 0) {
            onCollecionDownloaded();
            if (onProgress != null)
                onProgress(this);
        } else {
            for (i in 0...cast Math.min(maxSimulResources, pendingResources.length))
                downloadResource(pendingResources[i]);
        }
    }

    function downloadResource(id:String):Void {
        Http.request(path + id, "GET", (_, _, response) -> {
            if (response.status == 200 || response.status == 304) {
                Resource.store_resource(resourceManifest, response.response, id, (_, hexdigest, success) -> {
                    if (success)
                        ownResourceDownloaded(id);    
                    else if (onError != null)
                        onError('Failed to store: $hexdigest');
                });
            } else if (onError != null)
                onError('Failed to download: $id');
        });
    }

    function ownResourceDownloaded(id:String):Void {
        pendingResources.remove(id);
        downloadedResources.push(id);
        if (pendingResources.length > 0)
            downloadResource(pendingResources[0]);
        else
            onCollecionDownloaded();
        if (onProgress != null)
            onProgress(this);
    }

    function onCollecionDownloaded():Void {
        if (autoLoad != NONE) {
            collection.load(autoLoad == ASYNC, _ -> {
                if (autoEnable)
                    collection.enabled = true;
            });
        }
    }

    inline function get_progress():Float {
        if (pendingResources.length == 0)
            return 0;
        return 1 - (pendingResources.length / allResources.length);
    }

}