package ixia.defold;

import defold.Timer;

class TimerRunner {
    
    public var duration(default, null):Float;
    public var time(default, null):Float = 0;
    public var percent(default, null):Float = 0;
    public var handle(default, null):TimerHandle;
    public var onUpdate:TimerRunner->Void;
    public var onComplete:TimerRunner->Void;

    public function new(duration:Float = 0, ?onUpdate:TimerRunner->Void, ?onComplete:TimerRunner->Void) {
        this.duration = duration;
        this.onUpdate = onUpdate;
        this.onComplete = onComplete;
    }

    public function start(?duration:Float, ?onUpdate:TimerRunner->Void, ?onComplete:TimerRunner->Void):Void {
        if (duration != null) this.duration = duration;
        if (onUpdate != null) this.onUpdate = onUpdate;
        if (onComplete != null) this.onComplete = onComplete;
        stop();
        resume();
    }

    public function resume():Void {
        if (duration == 0) {
            percent = 1;
            if (onUpdate != null)
                onUpdate(this);
            return;
        }

        handle = Timer.delay(0, true, (_, handle, delta) -> {
            time += delta;
            if (time < duration)
                percent = time / duration
            else {
                Timer.cancel(handle);
                handle = null;
                time = duration;
                percent = 1;
                if (onComplete != null)
                    onComplete(this);
            }
            if (onUpdate != null)
                onUpdate(this);
        });
    }

    public inline function pause():Void {
        cancelTimer();
    }

    public function stop():Void {
        cancelTimer();
        time = 0;
        percent = 0;
    }

    function cancelTimer():Void {
        if (handle != null) {
            Timer.cancel(handle);
            handle = null;
        }
    }

}