
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
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		stderr.write("\n- ", a.data, "\n");
		_J.Exit(1);
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		//formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		stderr.write("\n- ", a.data, "\n");
		_J.Exit(1);
	}
	
	Tok* peek(size_t pos = 0 ) {
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
	
	Tok* nextSibling(Tok* tk = null) {
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
	
	void parse() {
		lexer.parse ;

		Block block	= NewTok!(Block)();
		
		version(JADE_DEBUG_PARSER_TOK_DUMP) {
		Tok* tk	= lexer._root_tok ;
			while( tk !is null ) {
				//auto node = parseExpr ;
				Log("tab:%d ln:%d:%d %s = `%s`" , tk.tabs, tk.ln,tk._ln, tk.type, tk.string_value );
				tk	= tk.next ;
			}
		}
		
	}
	
	private N NewTok(N,T...)(T t) if( is(N==class) && BaseClassesTuple!(N).length > 0 && is( BaseClassesTuple!(N)[0] == Node) ){
		N node = pool.New!(N)(t) ;
		mixin("node.ty = Node.Type." ~ N.stringof  ~ ";" );
		return node ;
	}
	
	private Node parseExpr(){
		
		return null ;
	}
}
