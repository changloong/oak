
module oak.langs.jade.node.Code ;

import oak.langs.jade.Jade ;

final class Code : Node {
		
	string 	code ;
	
	this(Tok* tk) {
		assert(tk !is null);
		code	= tk.string_value ;
	}
}