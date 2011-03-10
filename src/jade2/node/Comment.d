
module jade.node.Comment ;

import jade.Jade ;

final class Comment : Node {
	bool isHide ;
	
	this(Tok* tk){
		assert(tk !is null);
		isHide	= tk.bool_value ;
	}
	
	
	void asD(vBuffer bu){
		if( isHide ) {
			return ;
		}
		bu("<!-- ");
		eachD(bu);
		bu(" -->");
	}
}