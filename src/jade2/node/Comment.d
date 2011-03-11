
module jade.node.Comment ;

import jade.Jade ;

final class Comment : Node {
	bool isHide ;
	
	this(Tok* tk){
		assert(tk !is null);
		isHide	= tk.bool_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		if( isHide ) {
			return ;
		}
		tpl.asString("<!-- ");
		eachD(tpl);
		tpl.asString(" -->");
	}
}