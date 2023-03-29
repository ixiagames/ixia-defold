package ixia.defold.extensions;

import haxe.Constraints.Function;
import haxe.extern.EitherType;
import lua.Table;

@:luaRequire("colyseus.client")
extern class Client {
    
    @:luaDotMethod public function new(endpoint:String);
    public function create(room_name:String, options:Dynamic, callback:(error:String, room:Room)->Void):Void;
    public function join_or_create(room_name:String, options:Dynamic, callback:(error:String, room:Room)->Void):Void;
    public function join_by_id(room_id:String, options:Dynamic, callback:(error:String, room:Room)->Void):Void;
    public function consume_seat_reservation(reservation:Dynamic, callback:(error:String, room:Room)->Void):Void;
    public function reconnect(roomId:String, sessionId:String, callback:(error:String, room:Room)->Void):Void;
    public function get_available_rooms(room_name:String, callback:(error:String, rooms:Table<Int, RoomInfoInLobby>)->Void):Void;

}

extern class Room {
    
    public var state(default, never):Dynamic;
    public var sessionId(default, never):String;
    public var id(default, never):String;
    public var name(default, never):String;
    public var connection(default, never):Dynamic;

    public function send(type:EitherType<String, Int>, ?message:Dynamic):Void;
    public function leave(consented:Bool):Void;

    public function on(event:RoomEvent, handler:Function):Void;
    public function on_message(type:EitherType<String, Int>, handler:(message:Dynamic)->Void):Void;
    public inline function on_state_change(handler:(state:Dynamic)->Void):Void on(STATE_CHANGE, handler);
    public inline function on_leave(handler:Void->Void):Void on(LEAVE, handler);
    public inline function on_error(handler:(code:Int, message:String)->Void):Void on(ERROR, handler);

}

enum abstract RoomEvent(String) {

    var STATE_CHANGE = "statechange";
    var LEAVE = "leave";
    var ERROR = "error";
    
}

extern class RoomInfoInLobby {

    public var name(default, never):String;
    public var roomId(default, never):String;
    public var processId(default, never):String; 
    public var clients(default, never):Int;
    public var maxClients(default, never):Int;
	public var metadata(default, never):Dynamic; 
	
	// The fields below may become lost when Defold processed the data (but still were sent by the server).
	public var createdAt(default, never):String;
    public var locked(default, never):Bool;
    public var unlisted(default, never):Bool;
    @:native("private") public var private_(default, never):Bool;

}