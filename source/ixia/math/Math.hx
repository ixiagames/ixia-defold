package ixia.math;

@:forwardStatics
abstract Math(std.Math) {
    
    public static inline function nearest(v:Float, a:Float, b:Float):Float {
        return Math.abs(a - v) < Math.abs(b - v) ? a : b;
    }
    
    public static inline function between(percent:Float, min:Float, max:Float):Float {
        return min + (max - min) * percent;
    }

    public static inline function normalize(value:Float, min:Float, max:Float):Float {
        return value <= min ? 0 : Math.min((value - min) / (max - min), 1);
    }

}