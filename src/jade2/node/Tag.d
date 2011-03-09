
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
	TagClasses	classes ;
	Attrs		attrs ;
	
	this(Tok* tk) {
		tag	= tk.string_value ;
		isEmbed	= tk.bool_value ;
	}
	
	void asD(vBuffer bu ) {
		bu('<') ;
		string _tag	= tag[0] is '*'  ? "div" : tag ;
		bu(_tag);
		bool isFindAttr = false ;
		
		if( id !is null ) {
			bu(" id=\"")(id)("\"") ;
		}
		
		if( classes !is null ) {
			bu(" class=\"") ;
			assert(false) ;
		}
		
		if( attrs !is null ) {
			attrs.eachD(bu);
			assert(false) ;
		}
		bu('>');
		eachD(bu);
		bu("</")(_tag)(">");
	}
}