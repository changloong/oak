
module oak.jade.node.Tag ;

import oak.jade.Jade ;

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
		assert(tk.ty is Tok.Type.Tag);
		tag	= tk.string_value ;
		isEmbed	= tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		cc.asString("<") ;
		string _tag	= tag[0] is '*'  ? "div" : tag ;
		cc.asString(_tag);

		asAttrs(cc) ;
		
		if( empty ) {
			cc.asString(" />");
		} else {
			cc.asString(">");
			eachD(cc);
			cc.asString("</").asString(_tag).asString(">");
		}
	}
	
	void asAttrs(Compiler* cc) {
		
		if( id !is null ) {
			cc.asString(" id=\"").asString(id).asString("\"") ;
		}
		
		if( classes !is null ) {
			classes.asD(cc);
		}
		
		if( attrs !is null ) {
			attrs.eachD(cc);
		}
	}
}