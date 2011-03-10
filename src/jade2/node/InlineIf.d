
module jade.node.InlineIf ;

import jade.Jade ;

final class InlineIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	
	void asD(vBuffer bu){
		bu("\nif (")(cond)("){\n");
		eachD(bu);
		bu("\n}\n");
	}
	
}