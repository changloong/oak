
module jade.Token;

import jade.Jade ;

struct Tok {
	enum Type {
		Eos ,
		Newline,
		Outdent ,
		Tag ,
		Filter ,
		Each ,
		Code ,
		DocType ,
		Id ,
		Class ,
		Attrs ,
		Indent ,
		Comment ,
		Text ,
	}
	
	Type		tp ;
	size_t	ln ;
	string		val ;
	bool		buffer ;
	bool		escape ;
	bool		isVar ;
	string		key ;
	string		code ;
	Attrs		attrs ;
	
	bool isEos(){
		return tp is Type.Eos ;
	}
	bool isNewline(){
		return tp is Type.Newline ;
	}
	bool isOutdent(){
		return tp is Type.Outdent ;
	}
	bool isTag(){
		return tp is Type.Tag ;
	}
	bool isFilter(){
		return tp is Type.Filter ;
	}
	bool isEach(){
		return tp is Type.Each ;
	}
	bool isDocType(){
		return tp is Type.DocType ;
	}
	bool isId(){
		return tp is Type.Id ;
	}
	bool isClass(){
		return tp is Type.Class ;
	}
	bool isAttrs(){
		return tp is Type.Attrs ;
	}
	bool isIndent(){
		return tp is Type.Indent ;
	}
	bool isComment(){
		return tp is Type.Comment ;
	}
	bool isText(){
		return tp is Type.Text ;
	}
	
	static const members = EnumNames!(Tok.Type) ;
	
	string type(){
		return members[tp];
	}
	
	static string type(int _tp){
		if( _tp >=0 && _tp < members.length ) {
			return members[_tp];
		}
		return "UnKnow!" ~ to!string(_tp) ;
	}
}