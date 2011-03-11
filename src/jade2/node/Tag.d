
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
		if( tk.ty is Tok.Type.Tag ) {
			tag	= tk.string_value ;
		} else if(tk.ty is Tok.Type.Id ){
			tag	= "*" ;
			id	= tk.string_value ;
		}else if(tk.ty is Tok.Type.Class ){
			throw new Exception("Error");
		}
		isEmbed	= tk.bool_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl) {
		tpl.asString("<") ;
		string _tag	= tag[0] is '*'  ? "div" : tag ;
		tpl.asString(_tag);
		bool isFindAttr = false ;
		
		if( id !is null ) {
			tpl.asString(" id=\"").asString(id).asString("\"") ;
		}
		
		if( classes !is null ) {
			classes.asD(tpl);
		}
		
		if( attrs !is null ) {
			attrs.eachD(tpl);
		}
		
		if( empty ) {
			tpl.asString(" />");
		} else {
			tpl.asString(">");
			eachD(tpl);
			tpl.asString("</").asString(_tag).asString(">");
		}
	}
}