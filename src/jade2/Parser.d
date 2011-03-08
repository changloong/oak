
module jade.Parser ;

import jade.Jade ;

struct Parser {
	Pool*		pool ;
	string		filename ;
	string		filedata ;
	Lexer		lexer ;
	
	void Init(Compiler* cc) in {
		assert( cc !is null);
	} body {
		pool		= &cc.pool ;
		filename	= cc .filename ;
		filedata	= cc .filedata ;
		lexer.Init(cc) ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		//formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		stderr.write("\n- ", a.data, "\n");
		_J.Exit(1);
	}
	
	Tok* peek(ptrdiff_t pos = 0 ) {
		Tok* tk = lexer._last_tok  ;
		while( pos > 0 ) {
			if( tk is null ) {
				break ;
			}
			tk	= tk.next ;
			pos--;
		}
		while( pos < 0 ) {
			if( tk is null ) {
				break ;
			}
			tk	= tk.pre ;
			pos++ ;
		}
		return tk ;
	}
	
	Tok* next() {
		Tok* tk = lexer._last_tok  ;
		if( tk is null ) {
			return tk ;
		}
		tk	= tk.next ;
		lexer._last_tok = tk ;
		return tk ;
	}
	
	Tok* peekSibling(Tok* tk = null) {
		if( tk is null ) {
			tk = lexer._last_tok  ;
		}
		if( tk is null ) {
			return tk ;
		}
		auto tab = tk.tabs ;
		auto ln = tk.ln ;
		auto _ln = tk._ln ;
		tk	= tk.next ;
		for( tk = tk.next; tk !is null; tk = tk.next ) {
			// child 
			if( tk.tabs > tab ) {
				continue ;
			}
			// don't has sibling
			if( tk.tabs < tab ) {
				return null ;
			}
			assert(tk.tabs is tab ) ;
			if( tk._ln is _ln ){
				continue ;
			}
			// find sibling
			break ;
		}
		return tk ;
	}
	
	Tok* expect(Tok.Type ty) {
		Tok*	tk	= this.peek ;
		if( tk is null  ){
			err("expected %s, but got EOF",  Tok.sType(ty), this.filename ) ;
		}
		if ( tk.ty is ty) {
			next ;
			return tk ;
		} else {
			err("expected %s, but got %s on line:%d",  Tok.sType(ty), tk.type,  this.filename, tk.ln ) ;
		}
		return null ;
	}
	
	void parse() {
		lexer.parse ;
		Block block	= NewNode!(Block)();
		
		for( auto node	= parseExpr(); node !is null; node	= parseExpr()){
			block.pushChild(node) ;
		}
		
		version(JADE_DEBUG_PARSER_TOK_DUMP1) {
			Tok* tk	= lexer._root_tok ;
			while( tk !is null ) {
				//auto node = parseExpr ;
				Log("tab:%d ln:%d:%d %s = `%s`" , tk.tabs, tk.ln,tk._ln, tk.type, tk.string_value );
				tk	= tk.next ;
			}
		}
		
	}
	
	private N NewNode(N,T...)(T t) if( is(N==class) && BaseClassesTuple!(N).length > 0 && is( BaseClassesTuple!(N)[0] == Node) ){
		N node ;

		static if( T.length > 0 && isPointer!(T[0]) && is(pointerTarget!(T)==Tok) ) {
			static if( is(typeof(node.__ctor(t)))  )  {
				node = pool.New!(N)(t) ;
			} else if( T.length is 0) {
				node = pool.New!(N)() ;
			} else {
				// pragma(msg, T.stringof) ;
				node = pool.New!(N)( t[1..$] ) ;
			}
			assert(  t[0]  !is null ) ;
			if( node._tok is null ) {
				node._tok	= t[0] ;
			}
			if( node.ln is 0 ) {
				node.ln	= t[0].ln ;
			}
		}  else {
			node = pool.New!(N)(t) ;
		}
		
		mixin("node.ty = Node.Type." ~ N.stringof  ~ ";" );
		assert(node.firstChild is null ) ;
		assert(node.next is null ) ;
		return node ;
	}
	
	private Node parseExpr(){
		Tok* tk = peek ;
		switch( tk.ty ) {
			case Tok.Type.DocType:
				return parseDocType() ;
			case Tok.Type.Tag:
				return parseTag() ;
			default:
				Log("%s %d:%d  %s", tk.type, tk.ln, tk.tabs, tk.string_value);
				assert(false) ;
		}
		return null ;
	}
	
	Node parseDocType(){
		Tok* tk	= expect(Tok.Type.DocType) ;
		assert(tk !is null);
		return NewNode!(DocType)( tk ) ;
	}
	
	Node parseTag(){
		Tok* tk	= expect(Tok.Type.Tag) ;
		assert(tk !is null);
		auto node 	= NewNode!(Tag)( tk ) ;
		
		for(  tk = peek ; tk !is null ; tk = peek ){
			switch( tk.ty ) {
				case Tok.Type.AttrStart:
					auto _node	= parseAttrs() ;
					assert(_node !is null ) ;
					
					break ;
				default:
					Log("%s %d:%d  %s", tk.type, tk.ln, tk.tabs, tk.string_value);
					assert(false) ;
			}
		}
		return node ;
	}
	
	
	Node parseAttrs() {
		Tok* tk	= expect(Tok.Type.AttrStart) ;
		auto node 	= NewNode!(Attrs)( tk ) ;
		
		for(  tk = peek ; tk !is null ; tk = peek ) {
			switch( tk.ty ) {
				case Tok.Type.AttrEnd:
					return node ;
				case Tok.Type.AttrKey:
					auto _node	= parseAttr();
					assert(_node !is null );
					// push to attrs 
					break ;
		
				default:
					Log("%s %d:%d  %s", tk.type, tk.ln, tk.tabs, tk.string_value);
					assert(false) ;
			}
		}
		return null ;
	}
	
	
	Node parseAttr() {
		Tok* tk	= expect(Tok.Type.AttrKey) ;
		auto node 	= NewNode!(Attr)( tk ) ;
		node.key	=  tk.string_value ;

		for(  tk = peek ; tk !is null ; tk = peek ) {
			switch( tk.ty ) {
				/*
				case Tok.Type.AttrEnd:
					return node ;
				case Tok.Type.AttrKey:
					auto _node	= parseAttr();
					assert(_node !is null );
					// push to attrs 
					break ;
				*/
				case  Tok.Type.AttrValue :
					node.value	= parseAttrValue ;
					assert( node.value !is null ) ;
					break ;
				default:
					Log("%s %d:%d  %s", tk.type, tk.ln, tk.tabs, tk.string_value);
					assert(false) ;
			}
		}
		return node ;
	}
	
	AttrValue parseAttrValue() {
		Tok* tk	= expect(Tok.Type.AttrValue) ;
		auto node 	= NewNode!(AttrValue)( tk ) ;
		for(  tk = peek ; tk !is null ; tk = peek ) {
			switch( tk.ty ) {
				default:
					Log("%s %d:%d  %s", tk.type, tk.ln, tk.tabs, tk.string_value);
					assert(false) ;
			}
		}
		return node ;
	}
}
