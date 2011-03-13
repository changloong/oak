
module oak.jade.node.CommentBlock ;

import oak.jade.Jade ;

final class CommentBlock : Node {
	bool 	isHide ;
	
	this(Tok* tk) {
		isHide	= tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		
	}
}