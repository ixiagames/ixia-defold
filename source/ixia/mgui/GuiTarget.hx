package ixia.mgui;

import defold.support.ScriptOnInputAction;
import ixia.mgui.Event;
using defold.Gui;

@:access(ixia.mgui.EventData)
class GuiTarget {

    static var _pool:Array<GuiTarget> = [];

    static function create(mgui:MGui, id:String, node:Bool):GuiTarget {
        var target = _pool.length > 0 ? _pool.pop() : new GuiTarget();
        target.id = id;
        if (node)
            target.node = Gui.get_node(id);
        else
            target.dispatch(target.newEvent(REQUEST_NODE));
        target.dispatch(target.newEvent(CREATE));
        return target;
    }

    static function put(target:GuiTarget):Void {
        if (target.dispatch(target.newEvent(REMOVE)))
            return;

        if (@:privateAccess !target.mgui._targets.remove(target))
            return;

        target.mgui = null;
        target.id = null;
        target.node = null;
        target.pointerState = null;
        target._listeners.clear();
        _pool.push(target);
    }

    //

    public var mgui(default, null):MGui;
    public var id(default, null):String;
    public var node(default, null):GuiNode;
    public var pointerState(default, null):PointerTargetState;
    var _listeners:Map<Event, Array<EventData->Void>>;
    
    private function new() {}

    function handleTouchMoveInput(action:ScriptOnInputAction, scriptData:Dynamic):Void {
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

    function handleTouchInput(action:ScriptOnInputAction, scriptData:Dynamic):Void {
        if (pick(action.x, action.y)) {
            if (action.pressed) {
                pointerState = DOWN;
                if (mgui.pointerState == JUST_PRESSED)
                    dispatch(newEvent(JUST_PRESS, action, scriptData));
                dispatch(newEvent(PRESS, action, scriptData));

            } else if (action.released) {
                pointerState = HOVER;
                if (mgui.pointerState == JUST_RELEASED)
                    dispatch(newEvent(JUST_RELEASE, action, scriptData));
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