package ixia.defold;

import defold.Timer;

class TimerRunner {
    
    public var duration(default, null):Float;
    public var time(default, null):Float = 0;
    public var percent(default, null):Float = 0;
    public var handle(default, null):TimerHandle;
    public var listener:TimerRunner->Void;

    public function new(duration:Float = 0, ?listener:TimerRunner->Void) {
        this.duration = duration;
        if (listener != null)
            this.listener = listener;
    }

    public function start(?duration:Float, ?listener:TimerRunner->Void):Void {
        if (duration != null)
            this.duration = duration;
        if (listener != null)
            this.listener = listener;
        stop();
        resume();
    }

    public function resume():Void {
        if (duration == 0) {
            percent = 1;
            listener(this);
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
            }
            listener(this);
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