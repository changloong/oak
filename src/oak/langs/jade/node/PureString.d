
module oak.langs.jade.node.PureString ;

import oak.langs.jade.Jade ;

final class PureString : Node {
	string		value ;
	bool		escape ;
	
	this(Tok tk ) {
		value	= tk.string_value ;
		escape	= tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		cc.asString(value, escape) ;
	}
}