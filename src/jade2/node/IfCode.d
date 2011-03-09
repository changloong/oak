
module jade.node.IfCode ;

import jade.Jade ;

final class IfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;
	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
}