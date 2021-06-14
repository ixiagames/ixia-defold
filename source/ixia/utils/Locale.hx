package ixia.utils;

import haxe.Resource;
#if use_template
import haxe.Template;
import haxe.ds.Either;
import ixia.ds.OneOfTwo;
#end

using StringTools;
using ixia.math.Math;

class Locale {

    static inline var KEY_NOT_FOUND = "KEY_NOT_FOUND";
    #if use_template
    static inline var CONTEXT_REQUIRED = "CONTEXT_REQUIRED";
    #end
    
    public static var getTSVString:String->String = (id) -> return Resource.getString(id);
    #if debug
    static var _parsingId:String;
    #end

    static function getRows(tsv:String):Array<String> {
        var rows = tsv.replace('\r\n', '\n').replace('\r', '\n').split('\n');
        var i = rows.length;
        var s:String;
        while (i-- > 0) {
            s = rows[i].trim();
            if (s.length == 0 || s.startsWith('#'))
                rows.splice(i, 1);
            else {
                rows[i] = rows[i]
                    .replace("\\\\", "@~?%$")
                    .replace("\\n", '\n')
                    .replace("\\t", '\t')
                    .replace("@~?%$", "\\\\");
            }
        }
        return rows;
    }

    static function getCols(row:String):Array<String> {
        var cols = row.split('\t');
        #if debug
        if (cols.length != 2)
            Error.error('$_parsingId - Invalid number of cols (${cols.length}) in record: $row');
        #end
        return cols;
    }

    //

    public var id(default, null):String;
    public var missingKeyAction(default, null):MissingKeyAction;
    public var currencyRate(default, null):Float;

    #if use_template
    var map:Map<String, OneOfTwo<String, Template>> = [];
    #else
    var map:Map<String, String> = [];
    #end
    
    public function new(id:String, missingKeyAction:MissingKeyAction, currencyRate:Float = 1) {
        this.id = id;
        this.missingKeyAction = missingKeyAction;
        this.currencyRate = currencyRate;
        parse(id, []);
    }

    function parse(id:String, overwritableKeys:Array<String>):Void {
        #if debug
        _parsingId = id;
        #end
        
        var tsv = getTSVString(id);
        
        #if debug
        if (tsv == null)
            Error.error('Cannot found TSV string for $id.');
        #end

        var baseId:String = null;
        var emptyValueKeys = new Array<String>();
        var cols:Array<String>;
        #if debug
        var foundRecordKeys = new Array<String>();
        #end

        for (row in getRows(tsv)) {
            cols = getCols(row);
            
            if (baseId == null) {
                #if debug
                if (!cols[0].startsWith('base:'))
                    Error.error('$_parsingId - The first record needs to indice a base template (eg: "base:en-us" or "base:none"). Got: ${cols[0]}');
                #end

                baseId = cols[0].split(':')[1];
                continue;
            }

            #if debug
            if (foundRecordKeys.indexOf(cols[0]) > -1)
                Error.error('$_parsingId - Duplicated record key: ${cols[0]}');
            foundRecordKeys.push(cols[0]);
            #end

            if (!map.exists(cols[0]) || overwritableKeys.indexOf(cols[0]) > -1) {
                if (cols[1].length == 0) {
                    cols[1] = cols[0];
                    emptyValueKeys.push(cols[0]);
                }

                map[cols[0]] = 
                #if use_template
                    cols[1].indexOf("::") < 0 ? Left(cols[1]) : Right(new Template(cols[1]));
                #else
                    cols[1];
                #end
            }
        }

        #if debug
        if (baseId == null)
            Error.error('$_parsingId - No record found.');
        #end

        if (baseId != 'none' && baseId != id)
            parse(baseId, emptyValueKeys);
    }

    public function tr(key:String, ?context:Dynamic):String {
        var text = map[key];
        if (text == null) {
            var number = Std.parseFloat(key);
            if (!Math.isNaN(number))
                return key;
            
            switch (missingKeyAction) {
                case ERROR:
                    Error.error('Key not found: "$key"');
                    return KEY_NOT_FOUND;
                
                case WARNING:
                    trace('Key not found: "$key"');
                    return KEY_NOT_FOUND;

                case USE_KEY_AS_TEXT:
                    text = key;
            }
        }

        if (context == null) {
            #if use_template
            switch (text) {
                case Left(s):
                    return s;
                
                case Right(_):
                    #if debug
                    Error.error('context required for key: "$key"');
                    #end
                    return CONTEXT_REQUIRED + ': $key';
            }
            #end
            return text;
        }

        #if use_template
        switch (text) {
            case Left(s):
                #if debug
                Error.error('Unused context for key: "$key"');
                #end
                return s; 

            case Right(template):
                return template.execute(context);
        }
        #else
        for (field in Reflect.fields(context))
            text = text.replace('::$field::', Std.string(Reflect.field(context, field)));
        return text;
        #end
    }

    public var currencyEnabled:Bool = true;

    public inline function currencyToBase(amount:Float):Int {
        return Math.round(currencyRate * amount);
    }

    public inline function baseToCurrency(amount:Int):Float {
        return (amount / currencyRate).toFixed(2);
    }

    public function baseToCurrencyText(amount:Int):String {
        var amount = amount / currencyRate;
        var text = amount.separateThousands(2);
        var dotIndex = text.indexOf('.');
        if (dotIndex == -1)
            text += ".00";
        else if (text.substr(dotIndex).length < 3)
            text += '0';
        return tr("$::amount::", { amount: text });
    }

    public function baseToAmount(amount:Int):Float {
        #if debug
        if ((cast amount:Dynamic) == null)
            Error.error("null value");
        if (Math.isNaN(amount))
            Error.error("NaN value");
        #end
        if (currencyEnabled)
            return baseToCurrency(amount);
        return amount;
    }

    public function baseToAmountText(amount:Int):String {
        #if debug
        if ((cast amount:Dynamic) == null)
            Error.error("null value");
        if (Math.isNaN(amount))
            Error.error("NaN value");
        #end
        if (currencyEnabled)
            return baseToCurrencyText(amount);
        return amount.separateThousands();
    }

}

enum abstract MissingKeyAction(Int) {
    
    var ERROR;
    var WARNING;
    var USE_KEY_AS_TEXT;

}