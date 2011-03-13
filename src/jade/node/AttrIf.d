
module oak.jade.node.AttrIf ;

import oak.jade.Jade ;

final class AttrIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
}