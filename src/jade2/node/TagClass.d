
module jade.node.TagClass ;

import jade.Jade ;

final class TagClass : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asString(value).asString(" ");
	}
}