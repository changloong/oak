
module jade.node.PureString ;

import jade.Jade ;

final class PureString : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	void asD(Compiler* cc) {
		cc.asString(value);
	}
}