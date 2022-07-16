package ixia.utils.ds;

class StructTools {
    
    public static inline function isAnon(value:Dynamic):Bool {
        return Reflect.isObject(value) && Type.getClass(value) == null;
    }

    /**
     * Only guaranteed to work on anonymous structures.
     */
    public static function deepCopy<T>(value:T):T {
        if (Std.isOfType(value, String))
            return value;

        if (Std.isOfType(value, Array))
            return cast [ for (v in (cast value:Array<Dynamic>)) deepCopy(v) ];

        if (Reflect.isObject(value)) {
            var out = {};
            for (field in Reflect.fields(value))
                Reflect.setField(out, field, deepCopy(Reflect.field(value, field)));
            return cast out;
        }

        return value;
    }

}