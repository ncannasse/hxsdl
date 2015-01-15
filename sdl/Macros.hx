package sdl;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {

	public static function buildNativeWrapper() {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var headerClassCode = [];
		for( f in fields.copy() )
			switch( f.kind ) {
			case FVar(TPath( { pack : [], name : t }), _):
				fields.remove(f);
				headerClassCode.push(t + "* " + f.name);
			case FFun(fd):
				var code = haxe.macro.ExprTools.toString(fd.expr);
				var meta : MetadataEntry = { name : ":functionCode", params : [ { expr : EConst(CString(code)), pos : pos } ], pos : pos };
				if( f.name == "new" ) {
					// functionCode is not supported on new, let's create another function and forward the call
					var f2 : haxe.macro.Expr.Field = {
						name : "__new__",
						pos : f.pos,
						kind : FFun( {
							expr : { expr : EBlock([]), pos : pos },
							args : fd.args,
							ret : null,
						}),
						meta : [meta],
					};
					fields.push(f2);
					fd.expr.expr = ECall(macro __new__, [for( a in fd.args ) { expr : EConst(CIdent(a.name)), pos : pos } ]);
				} else {
					f.meta.push(meta);
					fd.expr.expr = EBlock([]);
				}
			default:
			}
		cl.meta.add(":headerClassCode", [ { expr : EConst(CString([for( l in headerClassCode ) l + ";\n"].join(""))), pos : pos } ], pos);
		cl.meta.add(":headerCode", [macro '#include <SDLSupport.h>'], pos);
		if( cl.name == "Sdl" ) cl.meta.add(":buildXml", [macro "<include name=\"${haxelib:hxsdl}/native.xml\"/>"], pos);
		return fields;
	}

}