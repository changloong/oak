
module jade.node.Code ;

import jade.Jade ;

final class Code : Node {
		
	string 	code ;
	
	this(Tok* tk) {
		assert(tk !is null);
		code	= tk.string_value ;
	}
}