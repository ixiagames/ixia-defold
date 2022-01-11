package ixia.utils;

class Random {
    
    public static inline function bool():Bool {
        return Math.random() < 0.5;
    }

    /** Exclude max. **/
    public static inline function int(min:Int, max:Int):Int {
        return min + Math.floor(Math.random() * (max - min));
    }

    /** Exclude max. **/
    public static inline function int0(max:Int):Int {
        return Math.floor(Math.random() * max);
    }

    /** Exclude max. **/
    public static inline function float(min:Float, max:Float):Float{
		return min + (Math.random() * (max - min));
    }
    
    /** Exclude max. **/
    public static inline function float0(max:Float):Float {
        return Math.random() * max;
    }

    /** Shuffle an array in place. **/
    public static function shuffle<T>(array:Array<T>):Void {
        var randomIndex:Int;
        var value:T;
        for (i in 0...array.length) {
            randomIndex = int0(array.length);
            value = array[i];
            array[i] = array[randomIndex];
            array[randomIndex] = value;
        }
    }
    
    // Got this from https://stackoverflow.com/a/19270021.
    public static function pickElements<T>(array:Array<T>, n:Int):Array<T> {
        var result = new Array<T>();
        var length = array.length;
        if (n > length)
            throw ("More elements taken than available.");

        var taken = new Array();
        while (n-- > 0) {
            var x = Math.floor(Math.random() * length);
            result[n] = array[taken[x] != null ? taken[x] : x];
            taken[x] = taken[--length] != null ? taken[length] : length;
        }
        return result;
    }

    /** Pick a random element fromthe  array. **/
    public static inline function pick<T>(array:Array<T>):T {
        return array[int0(array.length)];
    }

    /** Pick a random index from the array. **/
    public static inline function pickIndex<T>(array:Array<T>):Int {
        return int0(array.length);
    }

}