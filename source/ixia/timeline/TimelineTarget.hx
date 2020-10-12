package ixia.timeline;

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