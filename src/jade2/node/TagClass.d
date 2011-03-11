
module jade.node.TagClass ;

import jade.Jade ;

final class TagClass : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asString(value).asString(" ");
	}
}