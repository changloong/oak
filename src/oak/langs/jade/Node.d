
module oak.langs.jade.Node ;

import oak.langs.jade.Jade ;

package import 
	oak.langs.jade.node.Attrs ,
	oak.langs.jade.node.Attr ,
	oak.langs.jade.node.AttrIf ,
	
	oak.langs.jade.node.MixString ,
	oak.langs.jade.node.PureString ,
	oak.langs.jade.node.InlineIf ,
	oak.langs.jade.node.InlineElseIf,
	oak.langs.jade.node.InlineElse,
	oak.langs.jade.node.Var ,
	
	oak.langs.jade.node.Block ,
	oak.langs.jade.node.Comment ,
	oak.langs.jade.node.CommentBlock,
	oak.langs.jade.node.Code ,
	oak.langs.jade.node.DocType ,
	
	oak.langs.jade.node.Each ,
	oak.langs.jade.node.IfCode ,
	oak.langs.jade.node.ElseIfCode,
	oak.langs.jade.node.ElseCode,
	
	oak.langs.jade.node.Filter ,
	oak.langs.jade.node.FilterArgs,
	oak.langs.jade.node.FilterTagArg ,
	oak.langs.jade.node.FilterTagArgs ,
	
	oak.langs.jade.node.TagClass ,
	oak.langs.jade.node.TagClasses ,
	oak.langs.jade.node.Tag ;

package alias oak.langs.jade.node.Filter.Filter Filter; 

abstract class Node {
	
	enum Type {
		None ,
		
		Attrs ,
		Attr ,
		AttrIf ,
		
		MixString ,
		PureString ,
		
		Block ,
		Code ,
		Comment ,
		CommentBlock ,
		DocType ,
		Tag ,
		TagClass,
		TagClasses,
		
		Var ,
		
		Filter ,
		FilterArgs,
		FilterTagArg,
		FilterTagArgs,
		
		InlineIf ,
		InlineElseIf ,
		InlineElse ,
		IfCode ,
		ElseIfCode ,
		ElseCode ,
		Each ,
	}
	
	static const string[] Type_Name = ctfe_enum_array!(Type) ;
	
	Type		ty ;
	size_t		ln ;
	Tok*		_tok ;
	Node		next , firstChild , lastChild, parentNode ;
	private size_t	 _length = 0 ;
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexof!(string)(cast( string[] ) Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	string type(){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}
	
	void pushChild(Node node) {
		node.parentNode	= this ;
		if( firstChild is null ) {
			assert(lastChild is null) ;
			firstChild	= node ;
			lastChild	= node ;
		} else {
			assert(lastChild !is null) ;
			lastChild.next	= node ;
			lastChild	= node ;
		}
		_length++ ;
	}
	
	bool empty() {
		return firstChild is null ;
	}
	
	
	void asD(Compiler* cc){
		assert(false, this.type);
	}
	
	void eachD(Compiler* cc) {
		for(Node n = firstChild ; n !is null ; n = n.next ) {
			n.asD(cc);
		}
	}
	
	void each(scope void delegate(Node) dg) {
		for(Node n = firstChild ; n !is null ; n = n.next ) {
			dg(n);
		}
	}
	
	void err(size_t _line = __LINE__, T...)(Compiler* cc, string fmt,  T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", cc.filename, ln);
		throw new Exception(a.data);
	}

	@property size_t length(){
		return _length ;
	}
}



