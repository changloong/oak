
module oak.view.jade.node.Code ;

import oak.view.jade.Jade ;

final class Code : Node {
		
	string 	code ;
	
	this(Tok* tk) {
		assert(tk !is null);
		code	= tk.string_value ;
	}
}