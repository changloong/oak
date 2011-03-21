
module oak.langs.jade.node.TagClass ;

import oak.langs.jade.Jade ;

final class TagClass : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asString(value).asString(" ");
	}
}