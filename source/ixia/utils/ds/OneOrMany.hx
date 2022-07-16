package ixia.utils.ds;

import haxe.ds.Either;

@:forward
abstract OneOrMany<T>(Either<T, Array<T>>) from Either<T, Array<T>> to Either<T, Array<T>> {

    @:from inline static function fromOne<T>(one:T):OneOrMany<T> {
        return Left(one);
    }

    @:from inline static function fromMany<T>(many:Array<T>):OneOrMany<T> {
        return Right(many);  
    }

    @:to inline function toOne():Null<T> {
        return switch(this) {
            case Left(one): one; 
            case _: null;
        }
    }

    @:to inline function toMany():Null<Array<T>> {
        return switch(this) {
            case Right(many): many;
            case _: null;
        }
    }

    public function toArray():Array<T> {
        return switch(this) {
            case Left(one): [ one ];
            case Right(many): many;
        }
    }

}