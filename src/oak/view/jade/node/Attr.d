
module oak.view.jade.node.Attr ;

import oak.view.jade.Jade ;

final class Attr : Node {
	
	string 	key ;
	MixString	value ;
	
	this(Tok* tk) {
		assert(tk !is null);
		key	= tk.string_value ;
	}
	
	void asD(Compiler* cc) {
		cc.asString(" ").asString(key).asString("=\"");
		value.asD(cc) ;
		cc.asString("\"");
	}
}