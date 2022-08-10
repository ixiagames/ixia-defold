package ixia.defold.scripts;

import defold.Msg;
import defold.support.GuiScript;
import defold.types.Message;
import defold.types.Url;
import haxe.Constraints.Function;

@:autoBuild(ixia.defold.scripts.ScriptBuilder.build())
class ExtGuiScript<T:{}> extends GuiScript<T> {

    static final CALL = new Message<{ method:String, args:Dynamic }>("CALL");

    //

    public var url(default, null):Url;
    final _remoteMethods:Map<String, Function> = [];
    final _remoteCallbacks:Map<String, Dynamic->Void> = [];

    override function init(self:T) {
        url = Msg.url();
    }

    function postCall(method:String, args:Array<String>, ?callback:Dynamic->Void):Void {
        if (callback != null)
            _remoteCallbacks[method] = callback;
        Msg.post(url, CALL, { method: method, args: args });
    }

    override function on_message<TMessage>(self:T, message_id:Message<TMessage>, message:TMessage, sender:Url) {
        switch (message_id) {
            case CALL:
                var result = Reflect.callMethod(null, _remoteMethods[message.method], message.args);
                var callback = _remoteCallbacks[message.method];
                if (callback != null) {
                    _remoteCallbacks.remove(message.method);
                    callback(result);
                }
        }
    }

    public inline function acquireInputFocus():Void {
        Msg.post('.', new Message<Void>("acquire_input_focus"));
    }
    
}