
module oak.view.jade.node.TagClass ;

import oak.view.jade.Jade ;

final class TagClass : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asString(value).asString(" ");
	}
}