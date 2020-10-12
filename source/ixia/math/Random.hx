package ixia.math;

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
    public static inline function shuffle<T>(array:Array<T>):Void {
        var randomIndex:Int;
        var value:T;
        for (i in 0...array.length) {
            randomIndex = int0(array.length);
            value = array[i];
            array[i] = array[randomIndex];
            array[randomIndex] = value;
        }
    }

}