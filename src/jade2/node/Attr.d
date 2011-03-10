
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
	void asD(vBuffer bu){
		bu(' ')(key)("=\"");
		value.asD(bu);
		bu('"');
	}
}