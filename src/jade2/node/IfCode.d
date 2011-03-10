
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
	
	version(JADE_XTPL)
	void asD(vBuffer bu){
		bu("\nif (")(cond)(") { \n");
		eachD(bu);
		if( elseif !is null ) {
			elseif.asD(bu);
		}
		if( elseBlock !is null ) {
			elseBlock.asD(bu);
		}
		bu("\n}\n");
	}
}