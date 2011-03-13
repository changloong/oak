
module oak.jade.node.Filter ;

import oak.jade.Jade ;

import 
	oak.jade.filter.Js,
	oak.jade.filter.Css,
	oak.jade.filter.Text,
	oak.jade.filter.Include,
	oak.jade.filter.I18n;

final class Filter : Node {
	string		type ;
	bool		hasVar ;
	
	FilterArgs	args ;
	Tag		tag ;
	FilterTagArgs	tag_args ;
	
	this(Tok* tk) {
		type	= tk.string_value ;
		hasVar	= tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		Log("type = %s", type) ;
	}
}