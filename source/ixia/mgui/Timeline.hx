package ixia.mgui;

import haxe.ds.ReadOnlyArray;

@:access(ixia.mgui.TimelineTarget)
class Timeline<T:TimelineTarget> {

    public var time(default, null):Float = 0;
    public var timeScale #if debug (default, set) #end :Float = 1;
    public var targets(get, never):ReadOnlyArray<T>;
    var _targets:Array<T> = [];
    
    public function new() {}
    
    public function forward(delta:Float, ?onProgress:T->Void):Timeline<T> {
        #if debug
        if (delta < 0)
            Error.error('delta cannot be negative. Got: $delta');
        #end
        
        time += delta * timeScale;
        for (target in targets) {
            if (target.startTime <= time && target.progress < 1) {
                target.time = time - target.startTime;
                if (target.time < target.duration) {
                    target.progress = target.time / target.duration;
                    if (onProgress != null)
                        onProgress(target);
                } else {
                    target.progress = 1;
                    target.time = target.duration;
                    if (onProgress != null)
                        onProgress(target);
                }
            }
        }
        return this;
    }

    public function reset():Void {
        time = 0;
        for (target in _targets)
            target.time = target.progress = 0;
    }

    inline function get_targets():ReadOnlyArray<T> {
        return _targets;
    }

    #if debug
    inline function set_timeScale(value:Float):Float {
        if (value < 0)
            Error.error('timeScale cannot be negative. Got: $value');
        return timeScale = value;
    }
    #end

}

class TimelineTarget {

    public var timeline(default, null):Timeline<TimelineTarget>;
    public var duration(get, set):Float; var _duration:Float;
    public var startTime(get, set):Float; var _startTime:Float;
    public var time(default, null):Float = 0;
    public var progress(default, null):Float = 0;
    
    public function new(timeline:Timeline<TimelineTarget>, startTime:Float, duration:Float) {
        #if debug
        if (startTime < 0)
            Error.error('startTime cannot be smaller than 0. Got: $startTime');
        if (duration <= 0)
            Error.error('duration has to be positive. Got: $duration');
        #end

        this.timeline = timeline;
        @:privateAccess timeline._targets.push(this);

        _startTime = startTime;
        _duration = duration;
    }

    inline function get_duration() return _duration;
    function set_duration(value:Float):Float {
        #if debug
        if (duration <= 0)
            Error.error('duration has to be positive. Got: $duration');
        #end

        progress = Math.min(time / value, 1);
        return _duration = value;
    }

    inline function get_startTime() return _startTime;
    function set_startTime(value:Float):Float {
        #if debug
        if (startTime < 0)
            Error.error('startTime cannot be smaller than 0. Got: $startTime');
        #end

        time = timeline.time > value ? timeline.time - value : 0;
        progress = Math.min(time / _duration, 1);
        return _startTime = value;
    }

}