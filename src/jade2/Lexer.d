
module jade.Lexer ;

import jade.Jade ;

struct Lexer {
	Pool*		pool ;
	vBuffer		_str_bu ;
	string		filename ;
	
	const(char)*	_ptr ;
	const(char)*	_end ;
	const(char)*	_start ;
	
	Tok*		root ;
	Tok*		_tok ;
	
	size_t		ln, _last_indent_size ;
	
	void Init(Compiler* cc)  in {
		assert( cc !is null);
	} body {
		pool		= &cc.pool ;
		_str_bu		= cc._str_bu ;
		filename	= cc .filename ;
		
		_ptr	= &cc.filedata[0];
		_end	= &cc.filedata[$-1];
		_start	= _ptr ;
		ln	= 1 ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception( a.data );
	}
	
	void parse() {
		root	= peekNewLine ;
		
	}
	
	private Tok* NewTok(Tok.Type ty){
		Tok* tk ;
		tk	= pool.New!(Tok)() ;
		tk.ty	= ty ;
		tk.ln	= ln ;
		tk.tabs	= _last_indent_size ;
		
		return tk ;
	}
	
	Tok* peek() {
		return null ;
	}
	
	
	Tok* peekNewLine() {
		parserIndent ;
		switch( _ptr[0] ) {
			case '!':
				return parserDocType;
			default:
				assert(false);
		}
		return null ;
	}
	
	private void skip_space(){
		while( _ptr <= _end ) {
			if( _ptr[0] != ' ' && _ptr[0] != '\t' ) {
				break ;
			}
			_ptr++ ;
		}
	}
	
	private void skip_newline(){
		while( _ptr <= _end ) {
			if( _ptr[0] != '\r' && _ptr[0] != '\n' ) {
				break ;
			}
			_ptr++ ;
		}
	}
	
	private void parserIndent(){
		int i	= 0 ;
		while( _end - i >= _ptr ) {
			if( _ptr[i] is ' ' ) {
				i++ ;
			} else if(_ptr[i] is '\t'){
				i += 2 ;
			} else {
				break ;
			}
		}
		if( i % 2 ) {
			err("expect even indent");
		}
		_last_indent_size	= i / 2 ;
	}
	
	
	private void skip_inline_qstring(char q){
		assert(false);
	}
	
	Tok* parserInlineCode( Tok.Type _tmp_ty = Tok.Type.None ){
		int lcurly  , paren ;
		
		auto __ptr = _ptr ;
		int len ;
		L1:
		while( ( len = (_end - _ptr)) >= 0 ) {
			switch( _ptr[0] ) {
				case '{':
					lcurly++;
					break;
				case '}':
					if( lcurly is 0 ) {
						if( paren !is 0){
							err("code end error, paren is not match ", paren);
						}
						_ptr++ ;
						auto val	= __ptr[ 0 .. _ptr - __ptr - 1 ] ;
						if( _tmp_ty is Tok.Type.Var ) {
							Tok* tk	= NewTok(Tok.Type.Var);
							tk.string_value	= cast(string) val ;
							return tk ;
						}
						if( val.length <= 1 ) {
							err("expect more code '%s' ", val);
						}
						switch( val[0] ) {
							case '#':
								// #if, #else, #else if ,
								if( val.length > 3 ) {
									// #if
									if( val[1] is 'i' && val[2] is 'f' && (val[3] is ' ' || val[3] is '\t' ) ) {
										
									} else if( val.length > 4  && val[1] is 'e' && val[2] is 'l' && val[3] is 's' && val[4] is 'e' ){
										val	= val[5..$] ;
										// skip space
										while( val.length && val[0] is ' ' || val[0] is '\t' ) {
											val	= val[1..$];
										}
										// #else
										if( val.length is 0 ) {
											return  NewTok(Tok.Type.Else ) ;
										}
										// #else if
										if( val.length > 3 && val[0] is 'i' && val[1] is 'f' && ( val[2] is ' ' || val[2] is '\t') ) {
											Tok* tk	= NewTok(Tok.Type.ElseIf );
											tk.string_value	= cast(string) val[3..$] ;
											return tk ;
										}
									}
								}
							case '/':
								if( val.length is 3 && val[1] is 'i' && val[2] is 'f' ) {
									return  NewTok(Tok.Type.EnfIf ) ;
								}
							default:
								err("inline code error `%s`", __ptr[ 0 .. _ptr - __ptr - 1 ] );
						}
						assert(false);
					}
					lcurly--;
					break;
				case '"':
				case '`':
					skip_inline_qstring(_ptr[0]) ;
					break;
				case '(':
					paren++;
					break;
				case ')':
					paren--;
					break;
				case '\r':
				case '\n':
					err("expect '}'");
					break;
				default:
					break;
			}
			_ptr++ ;
		}
		err("expect '}'");
		return null ;
	}
	

	Tok*  parserInlineString() {
		assert( _ptr <= _end) ;
		assert( _ptr[0] !is '\n' &&  _ptr[0] !is '\r' ) ;
		
		Tok* _last_tk	= null ;
		Tok* _ret_tk	= null ;
		
		void push_tk(Tok* _tk){
			if( _ret_tk is null ) {
				_ret_tk	= _tk ;
				assert(_last_tk is null);
			} else {
				if( _last_tk is null ) {
					_last_tk	= _tk ;
					_tk.pre		= _ret_tk ;
					_ret_tk.next	= _tk ;
				} else {
					_last_tk.next	= _tk ;
					_tk.pre	= _last_tk ;
					_last_tk	= _tk ;
				}
			}
		}
		
		auto _str_pos = _str_bu.length ;
		
		void save_string() {
			if(  _str_bu.length - _str_pos ) {
				Tok* _tk	= NewTok(Tok.Type.String);
				_tk.string_value = cast(string) _str_bu.slice[ _str_pos ..$ ];
				_str_pos	=  _str_bu.length ;
				push_tk(_tk);
			}
		}
		
		auto __ptr = _ptr ;
		
		int len	;
		L1:
		while( (len = _end - _ptr) >= 0 ) {
			switch( _ptr[0] ) {
				case '\\' :
					if( len !is 0 ){
						if( _ptr[1] is '\r' || _ptr[1] is '\n' ) {
							// skip \
							_ptr++ ;
							skip_newline;
							ln++ ;
							size_t _tabs = _last_indent_size ;
							parserIndent();
							if( _last_indent_size < _tabs ){
								err("expect indent at least %d tabs", _tabs);
							}
							_last_indent_size	= _tabs ;
							
						} else if( len > 1 ) {
							if( _ptr[1] is '$' && _ptr[1] is '{' ) {
								_str_bu('$')('{');
								_ptr	+= 3;
								break;
							} else if( _ptr[1] is '{' && (_ptr[2] !is ' ' && _ptr[2] !is '\t') ) {
								_str_bu('{')(_ptr[2]) ;
								_ptr	+= 3;
								break;
							}
						} else {
							_str_bu('\\')( _ptr[1] ) ;
							_ptr	+= 2;
							break;
						}
					} else {
						_ptr++;
						_str_bu('\\');
					}
					break;
				case '$':
					if( len > 0 && _ptr[1] is '{' ) {
						// save old string
						save_string() ;
						// paser var name 
						_ptr += 2 ;
						Tok* _tk = parserInlineCode(Tok.Type.Var) ;
						assert(_tk !is null);
						push_tk(_tk) ;
					} else {
						_ptr++;
						_str_bu('$');
					}
					break ;
				case '{':
					if( len > 0 && _ptr[1] !is ' ' ) {
						// save old string
						save_string() ;
						_ptr += 1 ;
						Tok* _tk = parserInlineCode() ;
						assert(_tk !is null) ;
					} else {
						_ptr++;
						_str_bu('{');
					}
					break;
				case '\r':
				case '\n':
					break L1;
				default:
					_str_bu( _ptr[0] );
					_ptr++;
			}
		}
		save_string() ;
		return _ret_tk ;
	}
	
	Tok*  parserString(bool inline = true ) {
		if( _ptr > _end ) {
			return null ;
		}
		int i	= 0 ;
		while( _end - i >= _ptr ) {
			if( _ptr[i] is '\n' || _ptr[i] is '\r' ) {
				break ;
			}
			i++ ;
		}
		if( i > 0 ) {
			if( !inline ) {
				Tok* tk = NewTok(Tok.Type.String) ;
				tk.string_value	= cast(string) _ptr[0..i] ;
				return tk ;
			} else {
				return parserInlineString() ;
			}
		}
		return null ;
	}
	
	Tok* parserDocType() {
		assert(_ptr[0] is '!' ) ;
		int len = _end - _ptr ;
		if(  len < 3 || _ptr[1] !is '!' || _ptr[2] !is '!' ){
			err("expect doctype token");
		}
		_ptr	+= 3 ;
		Tok* tk	= NewTok(Tok.Type.DocType) ;
		tk.pre	= _tok ;
		_tok	= tk ;
		if( len > 3 ) {
			skip_space() ;
			Tok* s	= parserString ;
			if( s !is null ) {
				tk.next	= s ;
				s.pre	= tk ;
				_tok	= tk ;
			}
		}
		return tk ;
	}
	
}

