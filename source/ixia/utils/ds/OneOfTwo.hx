package ixia.utils.ds;

import haxe.ds.Either;

@:forward
abstract OneOfTwo<A, B>(Either<A, B>) from Either<A, B> to Either<A, B> {
    
    @:from inline static function fromA<A, B>(a:A):OneOfTwo<A, B> {
        return Left(a);
    }

    @:from inline static function fromB<A, B>(b:B):OneOfTwo<A, B> {
        return Right(b);  
    }

    @:to public inline function toA():Null<A> {
        return switch(this) {
            case Left(a): a; 
            case _: null;
        }
    }

    @:to public inline function toB():Null<B> {
        return switch(this) {
            case Right(b): b;
            case _: null;
        }
    }
    
}