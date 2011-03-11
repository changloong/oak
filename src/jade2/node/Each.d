
module jade.node.Each ;

import jade.Jade ;

final class Each : Node {
	string type, key, value, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asLine(this.ln);
		tpl.asCode("foreach(");
		
		if( type !is null ) {
			tpl.asCode(type).asCode(' ').asCode(key).asCode(',').asCode(value);
		} else if( key !is null ){
			tpl.asCode(key).asCode(',').asCode(value);
		} else {
			tpl.asCode(value);
		}
		
		
		tpl.asCode(';').asCode(obj).asCode(") { \n");
		eachD(tpl);
		tpl.asCode("}\n");
	}
}