package ixia.utils.lua;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

class RawTableBuilder {
    
    public static function build(propKeyTypePath:Expr):Array<Field> {
        var fields = Context.getBuildFields();
        var funcAccess = [ AInline ];
        for (prop in extractProps(propKeyTypePath)) {
            fields.push({
                name: prop.name,
                access: prop.access,
                kind: FProp("get", prop.settable ? "set" : "never", prop.type),
                pos: Context.currentPos()
            });
            fields.push({
                name: "get_" + prop.name,
                access: funcAccess,
                kind: FFun({
                    args: [],
                    ret: prop.type,
                    expr: macro return this[${prop.key}]
                }),
                pos: Context.currentPos()
            });
            if (prop.settable) {
                fields.push({
                    name: "set_" + prop.name,
                    access: funcAccess,
                    kind: FFun({
                        args: [ { name: "value", type: prop.type } ],
                        ret: prop.type,
                        expr: macro return this[${prop.key}] = value
                    }),
                    pos: Context.currentPos()
                });
            }
        }
        return fields;
    }

    public static function extractProps(typePath:Expr):Array<PropInfos> {
        var typePathString = typePath.toString();
        return switch (Context.getType(typePathString).follow()) {
            case TAbstract(_.get() => abstractType, params): [
                for (field in abstractType.impl.get().statics.get()) {
                    var fieldName = field.name;
                    var propEntries = field.meta.extract("prop");
                    if (propEntries.length > 1)
                        throw new Error('Has more than one @prop on $typePathString.$fieldName.', field.pos);
                    if (propEntries.length > 0) {
                        var propMeta = propEntries[0];
                        var params = propMeta.params;
                        {
                            name: snakeToCamel(fieldName),
                            key: macro $typePath.$fieldName,
                            type: params[0] == null ? macro :Dynamic : Context.getType(params[0].toString()).toComplexType(),
                            access: [ params[1] == null || params[0].getValue() ? APublic : APrivate ],
                            settable: params[2] != null && params[1].getValue()
                        }
                    }
                }
            ];
            case _: null;
        }
    }

    static function snakeToCamel(s:String):String {
        var parts = s.toLowerCase().split('_');
        s = parts[0];
        for (i in 1...parts.length)
            s += parts[i].charAt(0).toUpperCase() + parts[i].substr(1);
        return s;
    }

}

typedef PropInfos = {

    name:String,
    key:Expr,
    type:ComplexType,
    access:Array<Access>,
    settable:Bool

}
#end