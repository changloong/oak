
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
	
	static const string[] text_block = 
		[
			`style`,
			`script`,
			`textarea` ,
		] ;
}