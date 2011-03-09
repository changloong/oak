
module jade.node.InlineElse;

import jade.Jade ;

final class InlineElse : Node {
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	
}