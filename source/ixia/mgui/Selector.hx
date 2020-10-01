package ixia.mgui;

import haxe.ds.Either;
using StringTools;

abstract Selector(Either<String, (target:GuiTarget)->Bool>) from Either<String, (target:GuiTarget)->Bool> {
    
    @:from public static function fromString(s:String):Selector {
        return Left(s);
    }

    @:from public static function fromFunc(f:(target:GuiTarget)->Bool):Selector {
        return Right(f);
    }

    public static function matchID(id:String, s:String):Bool {
        return switch (s.charAt(0)) {
            case PREFIX:    id.startsWith(s.substr(1));
            case SUFFIX:    id.endsWith(s.substr(1));
            case HAS:       id.indexOf(s.substr(1)) > -1;
            case _:         id == s;
        }
    }

    public function match(target:GuiTarget):Bool {
        return switch (this) {
            case Left(s):
                for (s in s.split(',')) {
                    if (!matchID(target.id, s.trim()))
                        return false;
                }
                return true;
            
            case Right(f):
                f(target);
        }
    }

    public function select(from:Array<GuiTarget>):Array<GuiTarget> {
        return [ for (target in from) if (match(target)) target ];
    }

}

enum abstract SubStringMatchType(String) to String {

    var PREFIX = '>';
    var SUFFIX = '<';
    var HAS = ':';

}