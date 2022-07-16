package ixia.utils.ds;

class ArrayTools {
    
    public static inline function shuffle<T>(array:Array<T>):Void {
        Random.shuffle(array);
    }

    public static inline function getRandonElements<T>(array:Array<T>, n:Int):Array<T> {
        return Random.pickElements(array, n);
    }

    public static function hasDuplicated<T>(array:Array<T>):Bool {
        for (i in 0...array.length) {
            if (i != array.lastIndexOf(array[i]))
                return true;
        }
        return false;
    }

    public static inline function getUnique<T>(array:Array<T>):Array<T> {
        var result:Array<T> = [];
        for (value in array) {
            if (result.indexOf(value) == -1)
                result.push(value);
        }
        return result;
    }

}