package ixia.mgui;

import haxe.ds.ReadOnlyArray;

@:access(ixia.mgui.SubTimeline)
class Timeline<T> {

    public var time(default, null):Float;
    public var timeScale:Float = 1;
    public var children(get, never):ReadOnlyArray<SubTimeline<T>>;
    var _children:Array<SubTimeline<T>> = [];
    
    public function new() {}

    public function add(id:T, startTime:Float, duration:Float):Void {
        _children.push(new SubTimeline<T>(id, startTime, duration));
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
    public var duration(default, set):Float;
    public var startTime(default, set):Float;
    public var time(default, null):Float = 0;
    public var progress(default, null):Float = 0;
    
    public inline function new(id:T, startTime:Float, duration:Float) {
        this.id = id;
        this.startTime = startTime;
        this.duration = duration;
    }

    function set_duration(value:Float):Float {
        progress = Math.max(time / value, 1);
        return duration = value;
    }

    function set_startTime(value:Float):Float {
        time += startTime - value;
        if (time < 0)
            time = 0;
        progress = Math.max(time / duration, 1);
        return startTime = value;
    }

}