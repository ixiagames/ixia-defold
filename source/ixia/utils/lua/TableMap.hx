package ixia.utils.lua;

import lua.Lua;
import lua.Table;

using lua.PairTools;

abstract TableMap<K, V>(Table<K, V>) from Table<K, V> to Table<K, V> {
    
    public function new() {
        this = Table.create();
    }

    @:op([]) public inline function get(key:K):V {
        return this[untyped key];
    }

    @:op([]) public inline function set(k:K, v:V):V {
        return this[untyped k] = v;
    }

    public function copy():TableMap<K, V> {
        var table = new TableMap();
        for (entry in this.pairsIterator())
            table[entry.index] = entry.value;
        return table;
    }

    public inline function remove(key:K):Bool {
        if (this[untyped key] == null)
            return false;
        this[untyped key] = null;
        return true;
    }

    public function keyValueIterator():KeyValueIterator<K, V> {
        var p = Lua.pairs(this);
		var next = p.next;
		var i = p.index;
		return {
			next: () -> {
				var res = next(this, i);
				i = res.index;
				return { key: res.index, value: res.value };
			},
			hasNext: () -> {
				return Lua.next(this, i).value != null;
			}
		}
    }

}