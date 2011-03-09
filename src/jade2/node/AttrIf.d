
module jade.node.AttrIf ;

import jade.Jade ;

final class AttrIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
}