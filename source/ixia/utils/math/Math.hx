package ixia.utils.math;

@:forwardStatics
abstract Math(std.Math) {

    public static function toFixed(value:Float, precision:Int = 2):Float {
        return Math.round(value * Math.pow(10, precision) ) / Math.pow(10, precision);
    }
    
    public static inline function nearest(v:Float, a:Float, b:Float):Float {
        return Math.abs(a - v) < Math.abs(b - v) ? a : b;
    }
    
    public static inline function between(percent:Float, min:Float, max:Float):Float {
        return min + (max - min) * percent;
    }

    public static inline function normalize(value:Float, min:Float, max:Float):Float {
        return value <= min ? 0 : Math.min((value - min) / (max - min), 1);
    }

    public static inline function getDistance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }
    
    /** In radians. **/
    public static inline function getAngle(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        return Math.atan2(x2 - x1, y2 - y1);
    }

    public static inline function toDeg(rad:Float):Float {
        return rad * (180 / Math.PI);
    }
    
    public static inline function toRad(deg:Float):Float {
        return deg * Math.PI / 180;
    }

    /** Keep the degree value between 0 & < 360. **/
    public static inline function normalizeDeg(angle:Float):Float {
        return angle < 0 || angle > 360 ? (360 - (-angle % 360)) % 360 : (angle == 360 ? 0 : angle);
    }
    
    public static function separateThousands(number:Float, ?precision:Int, ?separator:String = ','):String {
        var negative = number < 0;
        var abs = Math.abs(number);
        var flooredAbs = Math.floor(abs); 
        var decimal = abs - flooredAbs;
        var string = Std.string(flooredAbs);
        var formatedString = '';
        for (i in 1...string.length + 1) {
			formatedString = string.charAt(string.length - i) + formatedString;
			if (i % 3 == 0 && i < string.length)
				formatedString = separator + formatedString;
		}
        if (negative)
			formatedString = '-' + formatedString;
        if (decimal > 0) {
            string = Std.string(precision == null ? decimal : toFixed(decimal, precision));
            formatedString += string.substr(1);
        }
        return formatedString;
    }

    public static inline function calSpacing(fitSize:Float, elementSize:Float, elementsCount:Int):Float {
        return elementsCount == 1 ? fitSize - elementSize : (fitSize - elementSize * elementsCount) / (elementsCount - 1);
    }

}