package ixia.defold;

import defold.types.Url;

class UrlTools {
    
    public static inline function compare(a:Url, b:Url):Bool {
        return a.socket == b.socket && a.path == b.path && a.fragment == b.fragment;
    }

}