
module oak.view.jade.node.AttrIf ;

import oak.view.jade.Jade ;

final class AttrIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
}