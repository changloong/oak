
module jade.node.ElseIfCode ;

import jade.Jade ;

final class ElseIfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;

	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
}