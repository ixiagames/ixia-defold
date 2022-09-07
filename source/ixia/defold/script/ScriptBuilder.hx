package ixia.defold.script;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class ScriptBuilder {

    macro static public function build():Array<Field> {
        var fields = Context.getBuildFields();

        var remoteMethods = new Array<String>();
        for (field in fields) {
            for (meta in field.meta) {
                if (meta.name == "post") {
                    switch (field.kind) {
                        case FFun(fieldFunc):
                            var args = fieldFunc.args.copy();
                            args.push({
                                name: "callback",
                                opt: true,
                                type: macro :Dynamic->Void
                            });
                            var argNames = [ for (arg in fieldFunc.args) arg.name ];
                            fields.push({
                                name: 'post_${field.name}',
                                doc: null,
                                meta: [],
                                access: [ APublic ],
                                kind: FFun({
                                    args: args,
                                    ret: macro :Void,
                                    expr: macro postCall($v{field.name}, [ ${for (argName in $v{argNames}) macro cast $i{argName}} ], $i{"callback"}),
                                    params: fieldFunc.params
                                }),
                                pos: Context.currentPos()
                            });
                            remoteMethods.push(field.name);

                        case _:
                    }
                }
            }
        }
        
        for (field in fields) {
            if (field.name == "init") {
                switch (field.kind) {
                    case FFun(f):
                        switch (f.expr.expr) {
                            case EBlock(exprs):
                                for (methodName in remoteMethods)
                                    exprs.push(macro _remoteMethods[$v{methodName}] = $i{methodName});
                            case _:
                        }
                    case _:
                }
                break;
            }
        }
        
        return fields;
    }

}
#end