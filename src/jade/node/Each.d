
module oak.jade.node.Each ;

import oak.jade.Jade ;

final class Each : Node {
	string type, key, value, value_type, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		
		
		cc.asLine(this.ln);
		cc.check_each(this);
		cc.asCode("foreach(");
	
		if( key !is null ){
			if( type !is null ) {
				cc.asCode(type).asCode(' ');
			}
			cc.asCode(key).asCode(',');
		} 

		if( value_type !is null ) {
			cc.asCode(value_type).asCode(' ');
		}

		cc.asCode(value);
		cc.asCode(';').asCode(obj).asCode(") { \n");
		eachD(cc);
		cc.asCode("}\n");
	}
}