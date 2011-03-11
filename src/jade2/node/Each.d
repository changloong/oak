
module jade.node.Each ;

import jade.Jade ;

final class Each : Node {
	string type, key, value, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("foreach(");
		
		if( type !is null ) {
			cc.asCode(type).asCode(' ').asCode(key).asCode(',').asCode(value);
		} else if( key !is null ){
			cc.asCode(key).asCode(',').asCode(value);
		} else {
			cc.asCode(value);
		}
		
		
		cc.asCode(';').asCode(obj).asCode(") { \n");
		eachD(cc);
		cc.asCode("}\n");
	}
}