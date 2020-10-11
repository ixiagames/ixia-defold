package ixia.mgui;

import haxe.ds.ReadOnlyArray;

@:access(ixia.mgui.SubTimeline)
class Timeline<T:Int> {

    public var time(default, null):Float;
    public var timeScale:Float = 1;
    public var children(get, never):ReadOnlyArray<SubTimeline<T>>;
    var _children:Array<SubTimeline<T>> = [];
    var _childrenMap:Map<T, SubTimeline<T>> = [];
    
    public function new() {}

    public function add(id:T, startTime:Float, duration:Float):Void {
        #if debug
        if (_childrenMap.exists(id))
            Error.error('$id already exists.');
        if (startTime < 0)
            Error.error('startTime cannot be smaller than 0. Got: $startTime');
        if (duration <= 0)
            Error.error('duration has to be positive. Got: $duration');
        #end

        var child = new SubTimeline<T>(id, startTime, duration);
        _children.push(child);
        _childrenMap[id] = child;
    }

    public inline function getChild(id:T):SubTimeline<T> {
        return _childrenMap[id];
    }

    public function forward(delta:Float, ?onProgress:SubTimeline<T>->Void, ?onComplete:SubTimeline<T>->Void):Timeline<T> {
        #if debug
        if (delta < 0)
            Error.error('delta cannot be negative. Got: $delta');
        #end
        
        time += delta * timeScale;
        for (child in children) {
            if (child.startTime >= time && child.progress < 1) {
                child.time = time - child.startTime;
                if (child.time < child.duration) {
                    child.progress = child.time / child.duration;
                    if (onProgress != null)
                        onProgress(child);
                } else {
                    child.progress = 1;
                    child.time = child.duration;
                    if (onComplete != null)
                        onComplete(child);
                }
            }
        }
        return this;
    }

    public function reset():Void {
        time = 0;
        for (child in _children)
            child.time = child.progress = 0;
    }

    inline function get_children():ReadOnlyArray<SubTimeline<T>> {
        return _children;
    }

}

class SubTimeline<T> {

    public var id(default, null):T;
    public var duration(get, set):Float; var _duration:Float;
    public var startTime(get, set):Float; var _startTime:Float;
    public var time(default, null):Float = 0;
    public var progress(default, null):Float = 0;
    
    public function new(id:T, startTime:Float, duration:Float) {
        this.id = id;
        _startTime = startTime;
        _duration = duration;
    }

    inline function get_duration() return _duration;
    function set_duration(value:Float):Float {
        progress = Math.max(time / value, 1);
        return _duration = value;
    }

    inline function get_startTime() return _startTime;
    function set_startTime(value:Float):Float {
        time += _startTime - value;
        if (time < 0)
            time = 0;
        progress = Math.max(time / _duration, 1);
        return _startTime = value;
    }

}