
module jade.node.DocType ;

import jade.Jade ;

final class DocType : Node {
	
	string type ;
	
	this(Tok* tk) {
		type	= tk.string_value ;
	}
}