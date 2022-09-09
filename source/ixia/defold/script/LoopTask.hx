package ixia.defold.script;

import defold.Timer;

abstract LoopTask(TimerHandle) to TimerHandle {

    public static function task(task:Void->Bool):LoopTask {
        return cast Timer.delay(0, true, (_, handle, _) -> {
            if (task())
                Timer.cancel(handle);
        });
    }

    public static function tasks(tasks:Array<Void->Bool>):LoopTask {
        return cast Timer.delay(0, true, (_, handle, _) -> {
            var i = tasks.length;
            while (--i >= 0) {
                if (tasks[i]()) {
                    tasks.splice(i, 1);
                    if (tasks.length == 0)
                        Timer.cancel(handle);
                }
            }
        });
    }

    public inline function cancel():Void {
        Timer.cancel(this);
    }
    
}