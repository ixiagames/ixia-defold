package ixia.utils.math;

// Copied & modified from https://github.com/HaxeFlixel/flixel/blob/bc11b6f875544f7d83877c9714379f021a36a120/flixel/tweens/FlxEase.hx

/*
    The MIT License (MIT)
    Copyright (c) 2009 Adam 'Atomic' Saltsman
    Copyright (c) 2012 Matt Tuttle
    Copyright (c) 2013 HaxeFlixel Team

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

class Ease {

    static final PI2 = Math.PI / 2;
    static final EL = 2 * Math.PI / .45;
    static final B1 = 1 / 2.75;
    static final B2 = 2 / 2.75;
    static final B3 = 1.5 / 2.75;
    static final B4 = 2.5 / 2.75;
    static final B5 = 2.25 / 2.75;
    static final B6 = 2.625 / 2.75;

    //
    
    public static inline function quadIn(t:Float):Float {
        return t * t;
    }
 
    public static inline function quadOut(t:Float):Float {
        return -t * (t - 2);
    }
 
    public static inline function quadInOut(t:Float):Float {
        return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
    }

    //
 
    public static inline function cubeIn(t:Float):Float {
        return t * t * t;
    }
 
    public static inline function cubeOut(t:Float):Float {
        return 1 + (--t) * t * t;
    }
 
    public static inline function cubeInOut(t:Float):Float {
        return t <= .5 ? t * t * t * 4 : 1 + (--t) * t * t * 4;
    }

    //
 
    public static inline function quartIn(t:Float):Float {
        return t * t * t * t;
    }
 
    public static inline function quartOut(t:Float):Float {
        return 1 - (t -= 1) * t * t * t;
    }
 
    public static inline function quartInOut(t:Float):Float {
        return t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
    }
 
    //

    public static inline function quintIn(t:Float):Float {
        return t * t * t * t * t;
    }
 
    public static inline function quintOut(t:Float):Float {
        return (t = t - 1) * t * t * t * t + 1;
    }
 
    public static inline function quintInOut(t:Float):Float {
        return ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
    }
 
    //

    public static inline function smoothStepIn(t:Float):Float {
        return 2 * smoothStepInOut(t / 2);
    }
    
    public static inline function smoothStepOut(t:Float):Float {
        return 2 * smoothStepInOut(t / 2 + 0.5) - 1;
    }
    
    public static inline function smoothStepInOut(t:Float):Float {
        return t * t * (t * -2 + 3);
    }

    //

    public static inline function smootherStepIn(t:Float):Float {
        return 2 * smootherStepInOut(t / 2);
    }
    
    public static inline function smootherStepOut(t:Float):Float {
        return 2 * smootherStepInOut(t / 2 + 0.5) - 1;
    }

    public static inline function smootherStepInOut(t:Float):Float {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    //
 
    public static inline function sineIn(t:Float):Float {
        return -Math.cos(PI2 * t) + 1;
    }
 
    public static inline function sineOut(t:Float):Float {
        return Math.sin(PI2 * t);
    }
 
    public static inline function sineInOut(t:Float):Float {
        return -Math.cos(Math.PI * t) / 2 + .5;
    }

    //
 
    public static function bounceIn(t:Float):Float {
        t = 1 - t;
        if (t < B1)
            return 1 - 7.5625 * t * t;
        if (t < B2)
            return 1 - (7.5625 * (t - B3) * (t - B3) + .75);
        if (t < B4)
            return 1 - (7.5625 * (t - B5) * (t - B5) + .9375);
        return 1 - (7.5625 * (t - B6) * (t - B6) + .984375);
    }
 
    public static function bounceOut(t:Float):Float {
        if (t < B1)
            return 7.5625 * t * t;
        if (t < B2)
            return 7.5625 * (t - B3) * (t - B3) + .75;
        if (t < B4)
            return 7.5625 * (t - B5) * (t - B5) + .9375;
        return 7.5625 * (t - B6) * (t - B6) + .984375;
    }
 
    public static function bounceInOut(t:Float):Float {
        if (t < .5) {
            t = 1 - t * 2;
            if (t < B1)
                return (1 - 7.5625 * t * t) / 2;
            if (t < B2)
                return (1 - (7.5625 * (t - B3) * (t - B3) + .75)) / 2;
            if (t < B4)
                return (1 - (7.5625 * (t - B5) * (t - B5) + .9375)) / 2;
            return (1 - (7.5625 * (t - B6) * (t - B6) + .984375)) / 2;
        }

        t = t * 2 - 1;
        if (t < B1)
            return (7.5625 * t * t) / 2 + .5;
        if (t < B2)
            return (7.5625 * (t - B3) * (t - B3) + .75) / 2 + .5;
        if (t < B4)
            return (7.5625 * (t - B5) * (t - B5) + .9375) / 2 + .5;
        return (7.5625 * (t - B6) * (t - B6) + .984375) / 2 + .5;
    }

    //
 
    public static inline function circIn(t:Float):Float {
        return -(Math.sqrt(1 - t * t) - 1);
    }
 
    public static inline function circOut(t:Float):Float {
        return Math.sqrt(1 - (t - 1) * (t - 1));
    }
 
    public static inline function circInOut(t:Float):Float {
        return t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
    }

    //
 
    public static inline function expoIn(t:Float):Float {
        return Math.pow(2, 10 * (t - 1));
    }
 
    public static inline function expoOut(t:Float):Float {
        return -Math.pow(2, -10 * t) + 1;
    }
 
    public static inline function expoInOut(t:Float):Float {
        return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
    }

    //
 
    public static inline function backIn(t:Float):Float {
        return t * t * (2.70158 * t - 1.70158);
    }
 
    public static inline function backOut(t:Float):Float {
        return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
    }
 
    public static function backInOut(t:Float):Float {
        t *= 2;
        if (t < 1)
            return t * t * (2.70158 * t - 1.70158) / 2;
        t--;
        return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
    }

    //
 
    public static inline function elasticIn(t:Float, amplitude:Float = 1, period:Float = 0.4):Float {
        return -(amplitude * Math.pow(2,
            10 * (t -= 1)) * Math.sin((t - (period / (2 * Math.PI) * Math.asin(1 / amplitude))) * (2 * Math.PI) / period));
    }
 
    public static inline function elasticOut(t:Float, amplitude:Float = 1, period:Float = 0.4):Float {
        return (amplitude * Math.pow(2,
            -10 * t) * Math.sin((t - (period / (2 * Math.PI) * Math.asin(1 / amplitude))) * (2 * Math.PI) / period)
            + 1);
    }
 
    public static function elasticInOut(t:Float, amplitude:Float = 1, period:Float = 0.4):Float {
        if (t < 0.5)
            return -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (period / 4)) * (2 * Math.PI) / period));
        return Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (period / 4)) * (2 * Math.PI) / period) * 0.5 + 1;
    }

}