
module jade.node.InlineElseIf ;

import jade.Jade ;

final class InlineElseIf : Node {
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	
}