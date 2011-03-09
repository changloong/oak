
module jade.node.Each ;

import jade.Jade ;

final class Each : Node {
	string type, key, value, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
}