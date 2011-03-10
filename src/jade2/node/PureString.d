
module jade.node.PureString ;

import jade.Jade ;

final class PureString : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(vBuffer bu ) {
		bu(value);
	}
}