
module jade.Lexer ;

import jade.Jade ;

struct Lexer {
	Pool*		pool ;
	vBuffer		_str_bu ;
	string		filename ;
	
	const(char)*	_ptr ;
	const(char)*	_end ;
	const(char)*	_start ;
	
	Tok*		_root_tok ;
	Tok*		_last_tok ;
	
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
	
	string line(){
		return cast(string) _ptr[ 0 .. find(_ptr, _end, '\n') ];
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception( a.data );
	}
	
	void parse() {
		Tok* tk ;
		while( _ptr <= _end ){
			parseIndent ;
			switch( _ptr[0] ) {
				// DocType
				case '!':
					tk	= parseDocType ;
					break;
				// Comment
				case '/':
					assert(false);
					break;
				// code
				case '-':
					assert(false);
					break;
				// filter
				case ':':
					assert(false);
					break;
				// text
				case '|':
					assert(false);
					break;
				// id
				case '#':
				// class
				case '.':
					tk	= parseTag(`div`) ;
					break;
				// tag 
				default:
					tk	= parseTag ;
					break;
			}
			assert(tk !is null);
			if( _root_tok is null ) {
				_root_tok	= tk ;
			}
			if( _ptr is _end ) {
				break ;
			}
			if( _ptr[0] !is '\r' && _ptr[0] !is '\n' ){
				err("lexer bug");
			}
			skip_newline;
		}
			
	}
	
	private Tok* NewTok(Tok.Type ty, string val = null ) {
		Tok* tk ;
		tk	= pool.New!(Tok)() ;
		tk.ty	= ty ;
		tk.ln	= ln ;
		tk.tabs	= _last_indent_size ;
		tk.pre	= _last_tok ;
		_last_tok	= tk ;
		if( val ) {
			tk.string_value	= val ;
			Log("%s =  `%s` ", Tok.sType(ty), val );
		} else {
			Log("%s", Tok.sType(ty) );
		}
		return tk ;
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
		if( _ptr is _end ) {
			err("expect new line");
		}
		switch( _ptr[0]) {
			case '\r':
				_ptr++;
				if( _ptr !is _end && _ptr[0] is '\n' ) {
					_ptr++;
				}
				break ;
			case '\n':
				_ptr++;
				break;
			default:
				err("expect new line");
		}
		Log("NewLine");
		ln++;
	}
	
	private string skip_identifier() {
		auto __ptr = _ptr ;
		while( _ptr <= _end ) {
			if( 
				_ptr[0] >= '0' && _ptr[0] <= '9' || 
				_ptr[0] >= 'a' && _ptr[0] <= 'z' || 
				_ptr[0] >= 'A' && _ptr[0] <= 'Z' || 
				_ptr[0]	is '_' 
			) {
				_ptr++ ;
			} else {
				break;
			}
		}
		if( __ptr is _ptr ) {
			return null ;
		}
		return cast(string) __ptr[ 0 .. _ptr - __ptr ] ;
	}
	
	private void parseIndent(){
		int i	= 0 ;
		while( _ptr <= _end ) {
			if( _ptr[0] is ' ' ) {
				i++ ;
			} else if(_ptr[0] is '\t'){
				i += 2 ;
			} else {
				break ;
			}
			_ptr++;
		}
		if( i % 2 ) {
			err("expect even indent");
		}
		_last_indent_size	= i / 2 ;
		Log("Indent: %d `%s`", _last_indent_size, line );
	}
	
	
	private void skip_inline_qstring(char q){
		assert(false);
	}
	
	Tok* parseInlineCode( Tok.Type _tmp_ty = Tok.Type.None ){
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
							Tok* tk	= NewTok(Tok.Type.Var, cast(string) val);
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
											Tok* tk	= NewTok(Tok.Type.ElseIf , cast(string) val[3..$] );
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
	

	Tok*  parseInlineString( char _stop_char = 0 ) {
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
				Tok* _tk	= NewTok(Tok.Type.String, cast(string) _str_bu.slice[ _str_pos ..$ ] );
				_str_pos	=  _str_bu.length ;
				push_tk(_tk);
			}
		}
		
		auto __ptr = _ptr ;
		
		bool _stop_zero	= _stop_char is 0 ;
		bool _stop_space = false ;
		bool _stop_paren = false ;
		
		if( !_stop_zero ) {
			if( _stop_char is ' ' ) {
				_stop_space	= true ;
			} else {
				assert( _stop_char is ')' );
				_stop_paren	= true ;
			}
		}
		
		size_t	paren_count = 0 ;
		
		int len	;
		L1:
		while( (len = _end - _ptr) >= 0 ) {
			if( !_stop_zero ) {
				if( _stop_space ) {
					if( _ptr[0] is ' ' ) {
						break ;
					}
				} else {
					if( _ptr[0] is ')' ) {
						if( paren_count is 0 ) {
							if( _ptr is _end ){
								err("not end attr");
							}
							break ;
						}
						paren_count-- ;
					} else if( _ptr[0] is '(' ) {
						paren_count++ ;
					}
				}
			} 
			
			switch( _ptr[0] ) {
				case '\\' :
					if( len !is 0 ){
						if( _ptr[1] is '\r' || _ptr[1] is '\n' ) {
							// skip \
							_ptr++ ;
							skip_newline;
							size_t _tabs = _last_indent_size ;
							parseIndent();
							if( _last_indent_size < _tabs ){
								err("expect indent at least %d tabs", _tabs);
							}
							_last_indent_size	= _tabs ;
							assert(false);
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
						if( _ptr != _end && ( _ptr[1] is '(' || _ptr[1] is ')' ) ) {
							_ptr	+= 2 ;
							_str_bu( _ptr[1] );
						} else {
							_ptr++;
							_str_bu('\\');
						}
					}
					break;
				case '$':
					if( len > 0 && _ptr[1] is '{' ) {
						// save old string
						save_string() ;
						// paser var name 
						_ptr += 2 ;
						Tok* _tk = parseInlineCode(Tok.Type.Var) ;
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
						Tok* _tk = parseInlineCode() ;
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
	
	Tok*  parseString(bool inline = true ) {
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
				Tok* tk = NewTok(Tok.Type.String, cast(string) _ptr[0..i] ) ;
				return tk ;
			} else {
				return parseInlineString() ;
			}
		}
		return null ;
	}
	
	Tok* parseDocType() {
		assert(_ptr[0] is '!' ) ;
		int len = _end - _ptr ;
		if(  len < 3 || _ptr[1] !is '!' || _ptr[2] !is '!' ){
			err("expect doctype token");
		}
		_ptr	+= 3 ;
		Tok* tk	= NewTok(Tok.Type.DocType) ;

		if( len > 3 ) {
			skip_space() ;
			Tok* s	= parseString ;
		}
		return tk ;
	}
	

	Tok* parseTag(string tag = null) {

		if( tag is null ) {
			tag	= skip_identifier ;
			if( tag is null ) {
				err("expect tag but find `%s` ", line ) ;
			}
		}
	
		Tok* _tk	= NewTok(Tok.Type.Tag, tag);
		
		if( _ptr is _end ) {
			return _tk;
		}
		
		if( _ptr[0] is '#' ) {
			_ptr++ ;
			string value	= skip_identifier ;
			if( value is null ) {
				err("expect tag.id");
			}
			Tok* _tk_id		= NewTok(Tok.Type.Id, value) ;
		}
		
		if( _ptr[0] is '.' ) {
			_ptr++ ;
			string value	= skip_identifier ;
			if( value is null ) {
				err("expect tag.class");
			}
			Tok* _tk_class		= NewTok(Tok.Type.Class, value) ;
		}
		
		if( _ptr[0] is ':' ) {
			if( _ptr is _end || _ptr[0] !is ' ' && _ptr[0] !is '\t' ) {
				err("expect space");
			}
			skip_space ;
			// inline tag ;
			assert(false) ;
		}
		
		if( _ptr is _end ) {
			return _tk;
		}
		
		skip_space ;
		if( _ptr[0] is '(' ) {
			Tok* _tk_attrs	= parseAttrs() ;
			if( _ptr !is _end && _ptr[0] !is '\r' && _ptr[0] !is '\n' && _ptr[0] !is '\t' && _ptr[0] !is ' ' ){
				err("missing space after attributes `%s`", line);
			}
			skip_space ;
		}
		
		// new line
		if( _ptr !is _end && (_ptr[0] is '\r' || _ptr[0] is '\n') ) {
			return _tk ;
		}
		
		parseInlineString() ;
		
		return _tk ;
	}
	
	Tok* parseAttrs() {
		if( _ptr is _end) {
			err("expect attrs");
		}
		if( _ptr[0] !is '(' ) {
			err("expect '(' ");
		}
		NewTok(Tok.Type.AttrStart) ;
		_ptr++;
		skip_space ;
		
		int len;
		auto __ptr = _ptr ;
		auto _str_pos	= _str_bu.length ;
		
		while( (len = _end - _ptr ) >=0 ) {
			scope(exit){
				_ptr++;
			}
			
			if( len > 0 && _ptr[0] is '{'&& ( _ptr[1] is '#' || _ptr[1] is '/'  ) ) {
				_ptr++;
				Tok* _tk_code	= parseInlineCode();
				assert( _tk_code !is null ) ;
			}
			
			// parse AttrKey
			auto key	= skip_identifier ;
			if( key is null ) {
				err("expect AttrKey");
			}
			Tok* _tk_key	= NewTok(Tok.Type.AttrKey, key);
			
			skip_space ;
			len = _end - _ptr ;
			if( len is 0 ) {
				err("expect AttrEnd" );
			}
			
			if( _ptr[0] is ')' ) {
				return NewTok(Tok.Type.AttrEnd) ;
			}
			
			if( _ptr[0] is '=' ) {
				_ptr++ ;
				skip_space ;
				// find 
				if( _ptr is _end ) {
					err("expect AttrValue") ;
				}
				
				Tok* _tk_val	= NewTok(Tok.Type.AttrValue) ;
				
				char _stop_char	 ;
				
				if(  _ptr[0] is '(' ) {
					_ptr++ ;
					skip_space;
					_stop_char	= ')' ;
				} else {
					_stop_char	= ' ';
				}
				
				parseInlineString( _stop_char ) ;
				
				if( _stop_char !is ' ' ){
					skip_space;
					if( _ptr is _end ) {
						err("expect AttrEnd") ;
					}
					if( _ptr[0] !is ')' ){
						err("expect AttrEnd `%s`", line) ;
					}
					_ptr++;
				}
				skip_space;
			}
			
			skip_space ;
			
			if( _ptr[0] is ',' ) {
				// \\n, {/if}, {#else}, {#else if}
				skip_space ;
				if( _ptr is _end ) {
					err("expect AttrEnd") ;
				}
				len = _end - _ptr ;
				
				// \\n
				if( len > 0 && _ptr[0] is '\\' && (_ptr[1] is '\r' || _ptr[1] is '\n') ){
					_ptr++;
					auto _tabs	= _last_indent_size ;
					skip_newline;
					parseIndent ;
					if( _last_indent_size < _tabs ){
						err("expect indent at least %d tabs", _tabs);
					}
					_last_indent_size	= _tabs ;
					skip_space ;
				}
				// {/if}, {#else}, {#else if}
				if( len > 0 && _ptr[0] is '{' ) {
					parseInlineCode ;
					skip_space ;
				}
				
			} else {
				if( _ptr[0] is ')' ) {
					return NewTok(Tok.Type.AttrEnd) ;
				}
				err("expect AttrKey or AttrEnd `%s`", line ) ;
			}
			
			
		}
		return null ;
	}
	
	
	static size_t safeFind(T)(T* _from , T* _to, T obj){
		T* _p = _from ;
		while( _p <= _to ) {
			if( _p[0] is obj ) {
				break ;
			}
			_p++;
		}
		return _p - _from ;
	}
	private alias safeFind!(const(char)) find ;
}

