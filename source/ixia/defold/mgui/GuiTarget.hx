package ixia.defold.mgui;

import defold.support.ScriptOnInputAction;
using defold.Gui;

@:access(ixia.defold.mgui.EventData)
class GuiTarget {
    
    public var mgui(default, null):MGui;
    public var id(default, null):String;
    public var node(default, set):GuiNode;
    public var enabled(default, set):Bool = true;
    public var pointerState(default, null):TargetPointerState = OUT;
    var _listeners:Map<EventType, Array<EventData->Void>> = [];
    var _tapInited:Bool = false;
    
    private function new() {}

    function handleTouchMove(action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (node.pick_node(action.x, action.y)) {
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
        if (node.pick_node(action.x, action.y)) {
            if (action.pressed) {
                _tapInited = true;
                pointerState = DOWN;
                dispatch(newEvent(PRESS, action, scriptData));

            } else if (action.released) {
                if (_tapInited) {
                    _tapInited = false;
                    dispatch(newEvent(CLICK, action, scriptData));
                }

                pointerState = HOVER;
                dispatch(newEvent(RELEASE, action, scriptData));
            }
        }
    }

    public function listen(event:EventType, listener:(data:EventData)->Void):Bool {
        if (!_listeners.exists(event))
            _listeners[event] = [ listener ];
        else {
            if (_listeners[event].indexOf(listener) > -1)
                return false;
            _listeners[event].push(listener);
        }
        return true;
    }

    public function mute(event:EventType, listener:(data:EventData)->Void):Bool {
        if (!_listeners.exists(event))
            return false;
        return _listeners[event].remove(listener);
    }

    public function dispatch(data:EventData):Dynamic {
        if (_listeners.exists(data.type)) {
            for (listener in _listeners[data.type])
                listener(data);
        }
        var result = data.get(RESULT);
        data.put();
        return result;
    }

    inline function newEvent(type:EventType, ?action:ScriptOnInputAction, ?scriptData:Dynamic):EventData {
        return new EventData(this, type, action, scriptData);
    }

    function set_node(value:GuiNode):GuiNode {
        var event = newEvent(NODE);
        event.set(PRV_NODE, node);
        node = value;
        dispatch(event);
        return node;
    }
    
    function set_enabled(value:Bool):Bool {
        if (enabled == value)
            return enabled;

        enabled = value;
        if (enabled) {
            pointerState = node.pick_node(mgui.pointer.x, mgui.pointer.y) ? HOVER : OUT;
            dispatch(newEvent(ENABLE));

        } else {
            pointerState = DISABLED;
            dispatch(newEvent(DISABLE));
        }
        
        return enabled;
    }

}