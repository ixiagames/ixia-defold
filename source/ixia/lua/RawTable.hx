package ixia.lua;

abstract RawTable<TKey, TValue>(Dynamic) {
    
    static var _pool(default, never):Array<AnyRawTable> = [];

    public inline function new() {
        this = _pool.length > 0 ? _pool.pop() : untyped __lua__("{}");
    }

    @:op([]) public inline function set(key:TKey, value:TValue):TValue {
        return untyped __lua__("{0}[{1}] = {2}", this, key, value);
    }

    @:op([]) public inline function get(key:TKey):TValue {
        return untyped __lua__("{0}[{1}]", this, key);
    }

    public inline function put():Void {
        untyped __lua__("for i = 0, #{0} do {0}[i] = nil end", this);
        _pool.push(this);
    }

}

typedef DynamicRawTable = RawTable<Dynamic, Dynamic>;
typedef AnyRawTable = RawTable<Any, Any>;