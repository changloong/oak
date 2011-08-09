
module oak.langs.jade.node.Var ;

import oak.langs.jade.Jade ;

final class Var : Node {
	string		value ;
	bool		unQuota ;
	
	this(Tok tk) {
		value	= tk.string_value ;
		unQuota = tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		cc.check_var(this);
		cc.asLine(this.ln);
		cc.asVar(value, unQuota);
	}
}