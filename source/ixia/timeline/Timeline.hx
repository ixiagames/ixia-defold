package ixia.timeline;

import haxe.ds.ReadOnlyArray;

@:access(ixia.timeline.TimelineTarget)
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