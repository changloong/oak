
module jade.node.Tag ;

import jade.Jade ;

final class Tag : Node {
	
	static const string[] self_closing = 
		[
			`meta`,
			`img` ,
			`link` ,
			`input` ,
			`area` ,
			`base` ,
			`col` ,
			`br` ,
			`hr` ,
		] ;
	
	string		tag , id ;
	bool		isEmbed ;
	
	this(Tok* tk) {
		tag	= tk.string_value ;
		isEmbed	= tk.bool_value ;
		
	}
}