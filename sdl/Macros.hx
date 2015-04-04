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
			var e = switch( v.type ) {
			case TPath( { name : "ARR", params : [TPType(t), TPExpr( { expr : EConst(CInt(size)) } )] } ):
				macro LOCAL($i { v.name } [$v { Std.parseInt(size)}], $i { typeString(t) } );
			default:
				macro LOCAL($i { v.name }, $i { typeString(v.type) } );
			};
			if( v.expr == null )
				return e;
			return macro LOCALINIT($e, $i { haxe.macro.ExprTools.toString(mapCpp(v.expr)) } );
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
		case TPath( { pack : pack, name : "NS", params : [TPType(t)] } ):
			return pack.join("::")+"::"+typeString(t);
		case TPath( { name : "PTR", params : [TPType(t)] } ):
			return typeString(t)+"*";
		case TPath( { name : "CONST", params : [TPType(t)] } ):
			return "const "+typeString(t);
		case TPath( { name : "UNSIGNED", params : [TPType(t)] } ):
			return "unsigned "+typeString(t);
		case TPath( { name : "ARR", params : [TPType(t),TPExpr({ expr : EConst(CInt(v)) })] } ):
			return typeString(t) + "["+v+"]";
		case TPath( { pack : [], name : n = "Char" | "Int" } ):
			return n.toLowerCase();
		case TPath( { pack : [], name : t, params : pl } ):
			if( pl.length == 0 )
				return t;
			return t + "<" + [for( p in pl ) switch( p ) { case TPExpr(e): "" + e; case TPType(t): typeString(t); } ].join(",") + ">";
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
		if( headerClassCode.length > 0 ) cl.meta.add(":headerClassCode", [ { expr : EConst(CString([for( l in headerClassCode ) l + ";\n"].join(""))), pos : pos } ], pos);
		var headerCode = '#include <SDLSupport.h>';
		for( m in cl.meta.get() )
			if( m.name == ":headerCode" && m.params.length > 0 )
				switch( m.params[0].expr ) {
				case EConst(CString(s)):
					headerCode += "\n" + s;
					cl.meta.remove(m.name);
				default:
				}
		cl.meta.add(":headerCode", [{ expr : EConst(CString(headerCode)), pos : pos }], pos);
		if( cl.name == "Sdl" ) cl.meta.add(":buildXml", [macro "<include name=\"${haxelib:hxsdl}/native.xml\"/>"], pos);
		return fields;
	}

}