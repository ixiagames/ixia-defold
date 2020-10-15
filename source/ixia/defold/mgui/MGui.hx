package ixia.defold.mgui;

import Defold.hash;
import defold.Gui;
import defold.Msg;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Message;

@:access(ixia.defold.mgui.GuiTarget)
class MGui {

    static final _guiTargetPool:Array<GuiTarget> = [];

    public static function acquireInputFocus():Void {
        Msg.post('.', new Message<Void>("acquire_input_focus"));
    }

    //

    public var actionIDs(default, null):ActionIDs;
    public var pointerState(default, null):PointerState;
    var _listenerSelections:Array<{ selector:Selector, events:Array<EventType>, listener:EventData->Void }> = [];
    var _targets:Array<GuiTarget> = [];
    
    public function new(acquiresInputFocus:Bool = true, ?actionRemap:Map<InputAction, String>) {
        if (acquiresInputFocus)
            acquireInputFocus();
        
        if (actionRemap == null)
            actionIDs = new ActionIDs();
        else
            actionIDs = new ActionIDs(actionRemap.exists(TOUCH) ? actionRemap[TOUCH] : TOUCH);
    }

    public function add(id:String, node:Bool = true):GuiTarget {
        var target = _guiTargetPool.length > 0 ? _guiTargetPool.pop() : new GuiTarget();
        target.mgui = this;
        target.id = id;
        if (node)
            target.node = Gui.get_node(id);

        for (selection in _listenerSelections) {
            if (selection.selector.match(target))
                for (event in selection.events)
                    target.listen(event, selection.listener);
        }

        _targets.push(target);
        target.dispatch(target.newEvent(CREATE));
        return target;
    }

    public function remove(target:GuiTarget):Bool {
        if (target.dispatch(target.newEvent(REMOVE)))
            return false;

        if (!_targets.remove(target))
            return false;

        put(target);
        return true;
    }

    public function removeAll():Void {
        for (target in _targets)
            put(target);
        _targets = [];
    }

    function put(target:GuiTarget):Void {
        target.mgui = null;
        target.id = null;
        target.node = null;
        target.pointerState = null;
        target._listeners.clear();
        _guiTargetPool.push(target);
    }

    public function clear():Void {
        _listenerSelections = [];
        removeAll();
    }

    public function listen(selector:Selector, events:Array<EventType>, listener:EventData->Void):Void {
        _listenerSelections.push({
            selector: selector,
            events: events.copy(),
            listener: listener
        });
        for (target in _targets) {
            if (selector.match(target)) {
                for (event in events)
                    target.listen(event, listener);
            }
        }
    }

    public function mute(?selector:Selector, ?events:Array<EventType>, ?listener:EventData->Void):Void {
        var i = _listenerSelections.length;
        while (i-- > 0) {
            var selection = _listenerSelections[i];
            if (selector != null && selector != selection.selector)
                continue;
            if (listener != null && listener != selection.listener)
                continue;
            if (events != null) {
                if (events.length != selection.events.length)
                    continue;
                for (event in events)
                    if (selection.events.indexOf(event) == -1)
                        continue;
            }

            _listenerSelections.splice(i, 1);
            for (target in _targets) {
                if (selection.selector.match(target)) {
                    for (event in selection.events)
                        target.mute(event, selection.listener);
                }
            }
        }
    }

    public function handleInput(actionID:Hash, action:ScriptOnInputAction, scriptData:Dynamic):Bool {
        if (actionID == null) {
            for (target in _targets) {
                if (target.enabled)
                    target.handleTouchMove(action, scriptData);
            }

        } else if (actionID == actionIDs.touch) {
            if (action.pressed)
                pointerState = JUST_PRESSED;
            else if (action.released)
                pointerState = JUST_PRESSED;

            for (target in _targets) {
                if (target.enabled)
                    target.handleTouchPress(action, scriptData);
            }

            if (action.pressed)
                pointerState = PRESSED;
            else if (action.released)
                pointerState = RELEASED;
        }

        return false;
    }

}

class ActionIDs {
    
    public var touch(default, null):Hash;

    public inline function new(touch:String = TOUCH) {
        this.touch = hash(touch);
    }

}

enum abstract InputAction(String) from String to String {

    var TOUCH = "touch";
    
}