
module jade.node.Attr ;

import jade.Jade ;

final class Attr : Node {
	
	string 	key ;
	MixString	value ;
	
	this(Tok* tk) {
		assert(tk !is null);
		key	= tk.string_value ;
	}
	
	void asD(Compiler* cc) {
		cc.asString(" ").asString(key).asString(" = ");
		auto pos = cc._ret_bu.length - 3 ;
		value.asD(cc) ;
		auto val  = cast(char[])  cc._ret_bu.slice[pos..$] ;
		if( 
			val.length > 5 && 
				(
					val[3] is '(' && val[$-1] is ')' 
						||
					val[3] is '"' && val[$-1] is '"' 
				)
		) {
			val[2] 	= '\\' ;
			val[3] 	= '"' ;
			val[$-1] 	= '\\' ;
			cc._ret_bu('"') ;
		} else {
			val[0] 	= '=' ;
			val[1] 	= '\\' ;
			val[2] 	= '\"' ;
			cc.asString("\"");
		}
	}
}