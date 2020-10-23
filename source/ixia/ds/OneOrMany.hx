package ixia.ds;

@:forward
abstract OneOrMany<T>(OneOfTwo<T, Array<T>>) from OneOfTwo<T, Array<T>> to OneOfTwo<T, Array<T>> {}