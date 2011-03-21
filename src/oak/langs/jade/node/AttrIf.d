
module oak.langs.jade.node.AttrIf ;

import oak.langs.jade.Jade ;

final class AttrIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
}