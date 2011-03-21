
module oak.langs.jade.node.FilterTagArg ;

import oak.langs.jade.Jade ;

final class FilterTagArg : Node {
	
	string		key ;
	MixString	value ;
	
	Tag		tag ;
	
	this(Tok* tk) {
		key	= tk.string_value ;
	}
}