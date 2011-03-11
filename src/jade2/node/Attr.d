
module jade.node.Attr ;

import jade.Jade ;

final class Attr : Node {
	
	string 	key ;
	MixString	value ;
	
	this(Tok* tk) {
		assert(tk !is null);
		key	= tk.string_value ;
	}
	
	version(JADE_XTPL) 
	void asD(XTpl tpl){
		tpl.asString(' ').asString(key).asString("=\"");
		value.asD(tpl);
		tpl.asString('"');
	}
}