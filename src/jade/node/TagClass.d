
module oak.jade.node.TagClass ;

import oak.jade.Jade ;

final class TagClass : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asString(value).asString(" ");
	}
}