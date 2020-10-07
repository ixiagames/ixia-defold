package ixia.mgui;

import Defold.hash;
import defold.Msg;
import defold.support.ScriptOnInputAction;
import defold.types.Hash;
import defold.types.Message;
import haxe.PosInfos;
import ixia.mgui.Event.EventData;
import lua.Lua;

@:access(ixia.mgui.GuiTarget)
class MGui {

    public static function error(message:String, ?posInfos:PosInfos) {
        Lua.error(posInfos.fileName + ':' + posInfos.lineNumber + ": " + message);
    }

    //

    public var actionIDs(default, null):ActionIDs;
    public var pointerState(default, null):PointerGlobalState;
    var _listenerSelections:Array<{ selector:Selector, events:Array<Event>, listener:EventData->Void }> = [];
    var _targets:Array<GuiTarget> = [];
    
    public function new(acquiresInput:Bool = true, ?actionRemap:Map<InputAction, String>) {
        if (acquiresInput)
            Msg.post('.', new Message<Void>("acquire_input_focus"));
        
        if (actionRemap == null)
            actionIDs = new ActionIDs();
        else
            actionIDs = new ActionIDs(actionRemap.exists(TOUCH) ? actionRemap[TOUCH] : TOUCH);
    }

    public function add(id:String, node:Bool = true):GuiTarget {
        return GuiTarget.create(this, id, node);
    }

    public function remove(target:GuiTarget):Void {
        if (_targets.remove(target))
            GuiTarget.put(target);
    }

    public function removeAll():Void {
        for (target in _targets)
            GuiTarget.put(target);
        _targets = [];
    }

    public function clear():Void {
        _listenerSelections = [];
        removeAll();
    }

    public function listen(selector:Selector, events:Array<Event>, listener:EventData->Void):Void {
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

    public function mute(?selector:Selector, ?events:Array<Event>, ?listener:EventData->Void):Void {
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
            for (target in _targets)
                target.handleTouchMoveInput(action, scriptData);

        } else if (actionID == actionIDs.touch) {
            if (action.pressed)
                pointerState = JUST_PRESSED;
            else if (action.released)
                pointerState = JUST_PRESSED;

            for (target in _targets)
                target.handleTouchInput(action, scriptData);

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