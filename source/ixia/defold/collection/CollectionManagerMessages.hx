package ixia.defold.collection;

import defold.types.Message;
import defold.types.Url;

class CollectionManagerMessages {
    
    public static final LOAD_COLLECTION = new Message<{ proxyUrl:Url, ?async:Bool }>("LOAD_COLLECTION");
    public static final UNLOAD_COLLECTION = new Message<{ proxyUrl:Url }>("UNLOAD_COLLECTION");
    public static final ENABLE_COLLECTION = new Message<{ proxyUrl:Url }>("ENABLE_COLLECTION");
    public static final DISABLE_COLLECTION = new Message<{ proxyUrl:Url }>("DISABLE_COLLECTION");

}