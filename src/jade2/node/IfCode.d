
module jade.node.IfCode ;

import jade.Jade ;

final class IfCode : Node {
	
	string 		cond ;

	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
}