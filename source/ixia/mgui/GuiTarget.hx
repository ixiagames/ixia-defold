package ixia.mgui;

import defold.support.ScriptOnInputAction;
import ixia.mgui.Event;
using defold.Gui;

@:access(ixia.mgui.EventData)
class GuiTarget {
    
    public var mgui(default, null):MGui;
    public var id(default, null):String;
    public var node(default, null):GuiNode;
    public var pointerState(default, null):PointerTargetState = OUT;
    var _listeners:Map<Event, Array<EventData->Void>> = [];
    var _tap_inited:Bool = false;
    
    private function new() {}

    function handleTouchMove(action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(action.x, action.y)) {
            if (!pointerState.isIn()) {
                pointerState = HOVER;
                dispatch(newEvent(ROLL_IN, action, scriptData));
            }
        } else {
            if (pointerState.isIn()) {
                pointerState = OUT;
                dispatch(newEvent(ROLL_OUT, action, scriptData));
            }
        }
    }

    function handleTouchPress(action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(action.x, action.y)) {
            if (action.pressed) {
                _tap_inited = true;
                pointerState = DOWN;
                dispatch(newEvent(PRESS, action, scriptData));

            } else if (action.released) {
                if (_tap_inited) {
                    _tap_inited = false;
                    dispatch(newEvent(CLICK, action, scriptData));
                }

                pointerState = HOVER;
                dispatch(newEvent(RELEASE, action, scriptData));
            }
        }
    }

    public function listen(event:Event, listener:(data:EventData)->Void):Bool {
        if (!_listeners.exists(event))
            _listeners[event] = [ listener ];
        else {
            if (_listeners[event].indexOf(listener) > -1)
                return false;
            _listeners[event].push(listener);
        }
        return true;
    }

    public function mute(event:Event, listener:(data:EventData)->Void):Bool {
        if (!_listeners.exists(event))
            return false;
        return _listeners[event].remove(listener);
    }

    public function dispatch(data:EventData):Dynamic {
        if (_listeners.exists(data.event)) {
            for (listener in _listeners[data.event])
                listener(data);
        }
        var result = data.get(RESULT);
        data.put();
        return result;
    }

    //

    inline function newEvent(event:Event, ?action:ScriptOnInputAction, ?scriptData:Dynamic):EventData {
        return new EventData(this, event, action, scriptData);
    }

    public inline function pick(x:Float, y:Float):Bool {
        return node.pick_node(x, y);
    }

}