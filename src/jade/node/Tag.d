
module jade.node.Tag ;

import jade.Jade ;

struct Tag {
	mixin Node.Child!(typeof(this))	node ;
	
	string	name ;
	Attrs	attrs ;
	
	Node*	text ;
	Node*	code ;
	Node*	block ;
	
	
	static const string[] self_closing_tags = 
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
	
	static const string[] block_tags = 
		[
			`html`,
			`head`,
			`body` ,
			`div` ,
			`p` ,
			`form` ,
			`div` ,
			`table` ,
			`tbody` ,
			`tr` ,
			`h1` ,
			`h2` ,
			`h3` ,
		] ;
}