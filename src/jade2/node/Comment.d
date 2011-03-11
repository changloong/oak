
module jade.node.Comment ;

import jade.Jade ;

final class Comment : Node {
	bool isHide ;
	
	this(Tok* tk){
		assert(tk !is null);
		isHide	= tk.bool_value ;
	}
	
	void asD(Compiler* cc){
		if( isHide ) {
			return ;
		}
		cc.asString("<!-- ");
		eachD(cc);
		cc.asString(" -->");
	}
}