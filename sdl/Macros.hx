package sdl;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {

	static function mapCode( e : Expr ) {
		switch( e.expr ) {
		case EMeta( { name : "cpp" }, e):
			return macro untyped __cpp__($v { haxe.macro.ExprTools.toString(mapCpp(e)) } );
		default:
			return haxe.macro.ExprTools.map(e, mapCode);
		}
	}

	static function mapCpp( e : Expr ) {
		switch( e.expr ) {
		case EReturn(null):
			return macro return null();
		case EVars([v]) if( v.type != null ):
			return macro LOCAL($i { v.name }, $i { typeString(v.type) } );
		case EConst(CIdent(i = "endif")):
			return { expr : EConst(CIdent("#"+i)), pos : e.pos };
		case ECall({ expr : EConst(CIdent("ifdef")) },[{ expr : EConst(CIdent(i)) }]):
			return { expr : EConst(CIdent("#ifdef "+i)), pos : e.pos };
		default:
			return haxe.macro.ExprTools.map(e, mapCpp);
		}
	}

	static function typeString( t : ComplexType ) {
		switch( t ) {
		case TPath( { name : "PTR", params : [TPType(t)] } ):
			return typeString(t)+"*";
		case TPath( { pack : [], name : t } ):
			return t;
		default:
			throw "Don't know how to convert " + haxe.macro.ComplexTypeTools.toString(t) + " to C type";
		}
	}


	public static function buildNativeWrapper() {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var headerClassCode = [];
		for( f in fields.copy() ) {
			switch( f.kind ) {
			case FVar(t, _) if( Lambda.exists(f.meta,function(m) return m.name == "cpp") ):
				fields.remove(f);
				headerClassCode.push(typeString(t) + " " + f.name);
			case FFun(fd):
				fd.expr = mapCode(fd.expr);
			default:
			}
		}
		cl.meta.add(":headerClassCode", [ { expr : EConst(CString([for( l in headerClassCode ) l + ";\n"].join(""))), pos : pos } ], pos);
		cl.meta.add(":headerCode", [macro '#include <SDLSupport.h>'], pos);
		if( cl.name == "Sdl" ) cl.meta.add(":buildXml", [macro "<include name=\"${haxelib:hxsdl}/native.xml\"/>"], pos);
		return fields;
	}

}