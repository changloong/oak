
module oak.view.jade.node.FilterTagArg ;

import oak.view.jade.Jade ;

final class FilterTagArg : Node {
	
	string		key ;
	MixString	value ;
	
	Tag		tag ;
	
	this(Tok* tk) {
		key	= tk.string_value ;
	}
}