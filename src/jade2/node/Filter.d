
module jade.node.Filter ;

import jade.Jade ;

final class Filter : Node {
	string		type ;
	bool		hasVar ;
	this(Tok* tk) {
		type	= tk.string_value ;
		hasVar	= tk.bool_value ;
	}
}