package ixia.defold.collection;

import defold.Http;
import defold.Resource;
import ixia.defold.collection.Collection;
import ixia.defold.collection.CollectionManagerScript.CollectionManagerScriptData;

using lua.PairTools;
using lua.Table;

typedef DownloadOptions<T:CollectionManagerScriptData> = {

    path:String,
    /* Default to 3. */
    ?maxSimulResources:Int,
    /* Default to NONE. */
    ?onProgress:CollectionDownloader<T>->Void,
    ?onError:String->Void

}

class CollectionDownloader<T:CollectionManagerScriptData> {

    public var collection(default, null):Collection<T>;
    public var path(default, null):String;
    public var maxSimulResources(default, null):Int;
    public var onProgress:CollectionDownloader<T>->Void; // whatever passed to this function would becomes null 
    public var onError:String->Void;

    public var allResources(default, null):Array<String>;
    public var pendingResources(default, null):Array<String>;
    public var downloadedResources(default, never):Array<String> = [];
    public var resourceManifest(default, null):ResourceManifestReference;
    public var progress(get, never):Float;
    public var downloaded(default, null):Bool = false;
    
    function new(collection:Collection<T>, options:DownloadOptions<T>) {
        this.collection = collection;
        path = options.path;
        maxSimulResources = options.maxSimulResources != null ? options.maxSimulResources : 3;
        onProgress = options.onProgress;
        onError = options.onError;

        // When this was writtten, defold.Collectionproxy lacks the proper metadata for it to work.
        var table:Table<Int, String> = untyped __lua__("_G.collectionproxy.missing_resources({0})", collection.proxyUrl);
        allResources = [ for (entry in table.ipairsIterator()) entry.value ];
        resourceManifest = Resource.get_current_manifest();
    }
    
    function download():Void {
        #if debug
        print("Missing resources: " + allResources.length);
        #end
        
        pendingResources = allResources.copy();
        if (pendingResources.length == 0) {
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
                    else if (onError != null) {
                        #if debug
                        trace('Failed to store: $id');
                        #end
                        onError('Failed to store: $id');
                    }
                });
            } else {
                #if debug
                trace('Failed to download: $id');
                #end
                if (onError != null)
                    onError('Failed to download: $id');
            }
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
        if (downloaded)
            return;
        
        downloaded = true;
        @:privateAccess collection.state = UNLOADED;

        #if debug
        print("Downloaded");
        #end
    }

    inline function get_progress():Float {
        if (pendingResources.length == 0)
            return 0;
        return 1 - (pendingResources.length / allResources.length);
    }

    
    #if debug
    inline function print(s:String):Void {
        trace('${collection.proxyUrl.fragment} - $s');
    }
    #end

}