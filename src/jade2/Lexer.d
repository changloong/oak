
module jade.Lexer ;

import jade.Jade ;

struct Lexer {
	Pool*		pool ;
	vBuffer	_str_bu ;
	string		filename ;
	
	const(char)*	_ptr ;
	const(char)*	_end ;
	const(char)*	_start ;
	
	Tok*		_root_tok ;
	Tok*		_last_tok ;
	
	size_t	ln, _last_indent_size, _offset_tabs ;
	bool		_search_inline_code ;
	
	void Init(Compiler* cc)  in {
		assert( cc !is null);
	} body {
		pool		= &cc.pool ;
		_str_bu	= cc._str_bu ;
		filename	= cc .filename ;
		
		_ptr	= &cc.filedata[0];
		_end	= &cc.filedata[$-1];
		_start	= _ptr ;
		ln	= 1 ;
		_search_inline_code	= true ;
	}
	
	string line() {
		auto val	= cast(string) _ptr[ 0 .. find(_ptr, _end, '\n') ];
		while( val.length && val[$-1] is '\r' ) val	= val[0..$-1] ;
		return val ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		write("\n", a.data, "\n");
		assert(false);
		//throw new Exception( a.data );
	}
	
	void parse() {
		while( _ptr <= _end ){
			parseIndent ;
			switch( _ptr[0] ) {
				// DocType
				case '!':
					parseDocType ;
					break;
				// Comment
				case '/':
					parseComment;
					break;
				// code
				case '-':
					parseCode;
					break;
				// filter
				case ':':
					assert(false);
					break;
				// text
				case '|':
					_ptr++;
					if( _ptr <= _end ) {
						parseString( !_search_inline_code);
					}
					break;
				// id
				case '#':
				// class
				case '.':
					parseTag(`div`) ;
					break;
				// tag 
				default:
					parseTag ;
					break;
			}
			if( _ptr >= _end ) {
				break ;
			}
			if( _ptr[0] !is '\r' && _ptr[0] !is '\n' ){
				err("lexer bug `%s`", line);
			}
			skip_newline;
		}
			
	}
	
	private Tok* NewTok(Tok.Type ty, string val = null ) {
		Tok* tk ;
		tk	= pool.New!(Tok)() ;
		tk.ty	= ty ;
		tk.ln	= ln ;
		tk.tabs	= _last_indent_size + _offset_tabs ;
		tk.pre	= _last_tok ;
		if( _last_tok !is null ) {
			_last_tok.next	= tk ;
		}
		_last_tok	= tk ;
		if( val !is null ) {
			tk.string_value	= val ;
			Log("`%s` %d = `%s`", Tok.sType(ty), tk.tabs, val);
		} else {
			Log("`%s` %d", Tok.sType(ty), tk.tabs );
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
		if( _ptr >= _end ) {
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
		_last_indent_size	= i / 2 ;
		Log("Indent: %d `%s`", _last_indent_size, line );
	}
	
	
	private void skip_inline_qstring(char q){
		assert(false);
	}
	
	Tok* parseInlineCode( Tok.Type _tmp_ty = Tok.Type.None ){
		int lcurly  , paren ;
		
		auto __ptr = _ptr ;
		L1:
		while(  _ptr  <= _end ) {
			switch( _ptr[0] ) {
				case '{':
					_ptr++ ;
					lcurly++;
					break;
				case '}':
					if( lcurly is 0 ) {
						if( paren !is 0){
							err("code end error, paren is not match ", paren);
						}
						_ptr++ ;
						auto val	= __ptr[ 0 .. _ptr - __ptr -1 ] ;
						if( _tmp_ty is Tok.Type.Var ) {
							Tok* tk	= NewTok(Tok.Type.Var, cast(string) val);
							return tk ;
						}
						if( val.length < 3 ) {
							err("expect more code '%s' ", val);
						}
				
						if( val[0] is 'i' && val[1] is 'f' && ( val[2] is ' '  || val[2] is '\t'  ) ) {
							auto _val	= val[3..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							if( _val.length > 0 ) {
								return  NewTok(Tok.Type.If, cast(string) _val ) ;
							}
						} else if( val.length > 3 &&  val[0] is 'e' && val[1] is 'l' && val[2] is 's' && val[3] is 'e'  ){
							auto _val	= val[4..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							
							// else 
							if( _val.length is 0 ) {
								return  NewTok(Tok.Type.Else ) ;
							} else {
								// else if
								if( _val.length > 3 &&  _val[0] is 'i' && _val[1] is 'f' && ( _val[2] is ' '  || _val[2] is '\t'  )  ) {
									_val	= val[3..$] ;
									while(_val.length && _val[0] is ' ') _val = _val[1..$];
									if( _val.length > 0 ) {
										return  NewTok(Tok.Type.ElseIf, cast(string) _val ) ;
									}
								}
							}
						} else if( val[0] is '/' ) {
							auto _val	= val[1..$] ;
							while(_val.length && _val[0] is ' ') _val = _val[1..$];
							while(_val.length && _val[$-1] is ' ') _val = _val[0..$-1];
							if( _val.length is 2 && _val[0] is 'i' && _val[1] is 'f' ) {
								return  NewTok(Tok.Type.EnfIf ) ;
							}
						}
						err("inline code error `%s`", val );
					}
					_ptr++ ;
					lcurly--;
					break;
				case '"':
				case '`':
					skip_inline_qstring(_ptr[0]) ;
					break;
				case '(':
					_ptr++ ;
					paren++;
					break;
				case ')':
					_ptr++ ;
					paren--;
					break;
				case '\r':
				case '\n':
					err("expect '}'");
					break;
				default:
					_ptr++ ;
			}
		}
		err("expect '}'");
		return null ;
	}
	

	Tok*  parseInlineString( char _stop_char = 0 ) {
		assert( _ptr <= _end) ;
		assert( _ptr[0] !is '\n' &&  _ptr[0] !is '\r' ) ;
		
		// Tok* _last_tk	= null ;
		Tok* _ret_tk	= null ;
		
		void push_tk(Tok* _tk){
			if( _ret_tk is null ) {
				_ret_tk	= _tk ;
				// assert(_last_tk is null);
			} 
			/*
			else {
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
			*/
		}
		
		
		auto _str_pos = _str_bu.length ;
		
		void save_string() {
			if(  _str_bu.length >= _str_pos ) {
				Tok* _tk	= NewTok(Tok.Type.String, cast(string) _str_bu.slice[ _str_pos ..$ ] );
				_str_pos	=  _str_bu.length ;
				push_tk(_tk);
			}
		}
		
		auto __ptr = _ptr ;
		
		bool _stop_zero	= _stop_char is 0 ;
		bool _stop_comma = false ;
		bool _stop_paren = false ;
		
		if( !_stop_zero ) {
			if( _stop_char is ',' ) {
				_stop_comma	= true ;
			} else {
				assert( _stop_char is ')' );
				_stop_paren	= true ;
			}
		}
		
		size_t	paren_count = 0 ;
		
		void string_trim_right(){
			while( _str_bu.length >= _str_pos){
				auto _last_char	=  _str_bu.slice[$-1] ;
				if( _last_char is ' ' || _last_char is '\t' ){
					_str_bu.move(-1);
				} else {
					break;
				}
			}
		}
		
		int len ;
		L1:
		while( (len = _end - _ptr) >= 0 ) {
			if( !_stop_zero ) {
				if( _stop_comma ) {
					if( _ptr < _end ) {
						if( _ptr[1] is ')'   || _ptr[1] is ','  ) {
							_str_bu(_ptr[0]) ;
							_ptr++;
							string_trim_right();
							break ;
						}
					}
				} else {
					if( _ptr[0] is ')' ) {
						if( paren_count is 0 ) {
							if( _ptr is _end ){
								err("not end attr");
							}
							_ptr++ ;
							string_trim_right();
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
							break;
						}
						
						if( len > 3 ) {
							if( _ptr[1] is '$' && _ptr[2] is '{' && _ptr[3] !is ' ' && _ptr[3] !is '\t' && _ptr[3] !is '\r' && _ptr[3] !is '\n' ) {
								_str_bu('$')('{');
								_ptr	+= 3;
								break;
							}
							
						} else {
							if( len > 2 && _ptr[1] is '$' && _ptr[2] is '{' ) {
								err("var error");
							}
						}

						if( len > 2 ) {
							if( _ptr[1] is '{' && _ptr[2] !is ' ' && _ptr[2] !is '\t'  && _ptr[2] !is '\r' && _ptr[2] !is '\n' ) {
								_str_bu('{')(_ptr[2]) ;
								_ptr	+= 3;
								break;
							}
						} else {
							if( len > 0 && _ptr[1] is '{' ){
								err("var error");
							}
						}
						
						// skip ('\\')
						if( _ptr < _end && ( _ptr[1] is '(' || _ptr[1] is ')' ) ) {
							_ptr	+= 2 ;
							_str_bu( _ptr[1] );
						} else {
							_ptr++;
							_str_bu('\\');
						}
						break;
					}
					err("lexer bug `%s`", line);
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
	
	string parseLineString( bool trimr = true ){
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
			auto val	= cast(string) _ptr[0..i] ;
			if( trimr ) {
				while( 
					val.length &&
					( val[$-1] is ' ' || val[$-1] is '\t' || val[$-1] is '\r'|| val[$-1] is '\n'  )
				) {
					val	= val[0..$-1];
				}
			}
			_ptr	+= i ;
			return  val ;
		}
		return null ;
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
				_ptr	+= i ;
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
		skip_space() ;
		Tok* tk	= NewTok(Tok.Type.DocType, parseLineString) ;
		return tk ;
	}
	

	Tok* parseTag(string tag = null) {
		if( tag is null ) {
			skip_space ;
			tag	= skip_identifier ;
			if( tag is null ) {
				// skip empty line
				if( _ptr[0] is '\r' || _ptr[0] is '\n' ) {
					return null ;
				}
				err("expect tag but find `%s` ", _ptr[0], line ) ;
			}
		}
	
		Tok* _tk	= NewTok(Tok.Type.Tag, tag);
		
		while(true) {
			if( _ptr >= _end ) {
				return _tk;
			}
			if( _ptr[0] is ' ' || _ptr[0] is '\t' || _ptr[0] is '\n' || _ptr[0] is '\r' || _ptr[0] is ':' || _ptr[0] is '%'|| _ptr[0] is '(' ){
				break;
			}
			
			if( _ptr[0] is '#' ) {
				_ptr++ ;
				string value	= skip_identifier ;
				if( value is null ) {
					err("expect tag.id");
				}
				Tok* _tk_id		= NewTok(Tok.Type.Id, value) ;
				continue ;
			}
			
			if( _ptr[0] is '.' ) {
				_ptr++ ;
				string value	= skip_identifier ;
				if( value is null ) {
					err("expect tag.class");
				}
				Tok* _tk_class		= NewTok(Tok.Type.Class, value) ;
				continue ;
			}
			err("tag err `%s`", line);
		}
		
		if(  _ptr <= _end  && _ptr[0] is ':' ) {
			_ptr++;
			if( _ptr >= _end || _ptr[0] !is ' ' && _ptr[0] !is '\t' ) {
				err("expect space `%s`", line);
			}
			skip_space ;
			auto _tag	= skip_identifier ;
			if( _tag is null ) {
				if( _ptr >= _end  || _ptr[0] !is ' ' && _ptr[0] !is '\t' ) {
					err("expect embed tag");
				}
				if( _ptr <= _end  && _ptr[0] != '#' && _ptr[0] != '.' ) {
					err("expect embed tag");
				}
				_tag	= "div" ;
			}
			_offset_tabs++;
			auto _embed_tag	= parseTag(_tag) ;
			assert(_embed_tag !is null);
			_offset_tabs-- ;
			return _tk ;
		}
		
		// _search_inline_code ?
		if( _ptr <= _end && _ptr[0] is '%' ) {
			_ptr++;
			_search_inline_code	= true ;
		} else {
			_search_inline_code	= false ;
		}
		
		skip_space ;
		
		scope(exit){
			// search text tag 
			if( std.algorithm.countUntil( Tag.text_block, tag ) >= 0 ) {
				assert(false, tag);
			}
		}
		
		// new line
		if( _ptr <= _end && (_ptr[0] is '\r' || _ptr[0] is '\n') ) {
			return _tk ;
		}
		
		if( _ptr <= _end && _ptr[0] is '(' ) {
			Tok* _tk_attrs	= parseAttrs() ;
			if( _ptr !is _end && _ptr[0] !is '\r' && _ptr[0] !is '\n' && _ptr[0] !is '\t' && _ptr[0] !is ' ' ){
				err("missing space after attributes `%s`", line);
			}
			skip_space ;
		}
		
		// new line
		if( _ptr > _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
			return _tk ;
		}
		
		parseInlineString() ;
		
		return _tk ;
	}
	
	Tok* parseAttrs() {
		if( _ptr >=_end ) {
			err("expect attrs");
		}
		if( _ptr <= _end && _ptr[0] !is '(' ) {
			err("expect '(' ");
		}
		NewTok(Tok.Type.AttrStart) ;
		_ptr++;
		skip_space ;
		
		bool _last_value	= true ;
		
		bool scan_skip_line() {
			if( _ptr <= _end && _ptr[0] is '\\' && (_ptr[1] is '\r' || _ptr[1] is '\n') ) {
				_ptr++;
				auto _tabs	= _last_indent_size ;
				skip_newline;
				parseIndent ;
				if( _last_indent_size < _tabs ){
					err("expect indent at least %d tabs", _tabs);
				}
				_last_indent_size	= _tabs ;
				skip_space ;
				return true ;
			}
			return false ;
		}
		
		bool scan_inline_code() {
			skip_space;
			if( _ptr < _end && _ptr[0] is '{' && _ptr[1] !is ' ' && _ptr[1] !is '\t'  && _ptr[1] !is '\r' && _ptr[1] !is '\n'   ) {
				_ptr++ ;
				parseInlineCode();
				skip_space;
				scan_skip_line ;
				return true ;
			}
			return false ;
		}
		
		bool scan_comma() {
			skip_space ;
			if(   _ptr <= _end  && _ptr[0] is ',' ) {
				// skip ,
				_ptr++ ;
				_last_value	= true ;
				skip_space ;
				scan_inline_code ;
				scan_skip_line ;
				return true ;
			}
			return false ;
		}
		
		bool scan_attrs_end() {
			skip_space ;
			if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("expect AttrEnd" );
			}
			
			scan_inline_code ;
			
			// attr end 
			if( _ptr <= _end  && _ptr[0] is ')' ) {
				_ptr++ ;
				NewTok(Tok.Type.AttrEnd) ;
				return true ;
			}
			
			return false ;
		}
		
		while(  _end >= _ptr ) {
			
			if( scan_attrs_end ) {
				break ;
			}
			
			scan_inline_code ;
			
			// parse AttrKey
			assert(_last_value) ;
			auto key	= skip_identifier ;
			if( key is null ) {
				err("expect AttrKey `%s`", line);
			}
			NewTok(Tok.Type.AttrKey, key);
			
			if( scan_attrs_end ) {
				break ;
			}

			// attribute value 
			if( _ptr <= _end && _ptr[0] is '=' ) {
				_ptr++ ;
				skip_space ;
				if( _ptr >= _end ) {
					err("expect AttrValue") ;
				}
				NewTok(Tok.Type.AttrValue) ;
				char _stop_char	 ;
				if(  _ptr <= _end ) {
					if(  _ptr[0] is '(' ) {
						_ptr++ ;
						skip_space;
						_stop_char	= ')' ;
					} else if( _ptr[0] is ')' ) {
						err("expect AttrValue but `%s`", line);
					} else {
						_stop_char	= ',' ;
					}
				}
				parseInlineString( _stop_char ) ;
				skip_space ;
			}
			
			if( scan_comma ) {
				continue ;
			}
			
			if( scan_attrs_end ) {
				break ;
			}
			
			err("expect AttrKey or AttrEnd `%s`", line ) ;
		}
		return null ;
	}
	
	Tok* parseComment(){
		assert(_ptr[0] is '/' );
		_ptr++;
		if( _ptr >= _end ) {
			err("expect Comment");
		}
		Tok* tk	= null ;
		if( _ptr[0] is '/' ) {
			// inline Common
			_ptr++;
			if( _ptr >= _end ) {
				err("expect Comment");
			}
			tk	= NewTok(Tok.Type.CommentStart);
			if( _ptr[0] is '-' ) {
				_ptr++;
				if( _ptr >= _end ) {
					err("expect Comment");
				}
				tk.bool_value	= true ;
			} else {
				tk.bool_value	= false ;
			}
			_offset_tabs++;
			parseString;
			_offset_tabs--;
			tk	= NewTok(Tok.Type.CommentEnd);
			return tk ;
		}
		
		tk	= NewTok(Tok.Type.CommentBlock);

		if( _ptr[0] is '-' ) {
			_ptr++;
			if( _ptr >= _end ) {
				err("expect Comment");
			}
			tk.bool_value	= true ;
		} else {
			tk.bool_value	= false ;
		}

		_offset_tabs++;
		parseString;
		_offset_tabs--;
		
		return tk ;
	}
	
	Tok* parseCode(){
		Tok* tk ;
		assert(_ptr[0] is '-' );
		_ptr++;
		if( _ptr >= _end ) {
			err("expect Code");
		}
		
		// native code
		if( _ptr[0] is '-' ) {
			_ptr++;
			if( _ptr >= _end ) {
				err("expect Code");
			}
			tk	= NewTok(Tok.Type.Code, parseLineString);
			return tk ;
		}
		if( _ptr[0] !is ' ' && _ptr[0] !is '\t' ) {
			err("expect space");
		}
		skip_space;
		if( _ptr >= _end ) {
			err("expect Code");
		}
		auto code_line	= line ;
		auto code_type	=  _ptr[ 0 .. safeFind!(const(char))(_ptr, &code_line[$-1], ' ') ];
		
		if( code_type == "if" ) {
			_ptr	+= 2 ;
			if( _ptr >= _end ) {
				err("expect Code");
			}
			skip_space ;
			if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				err("expect Code");
			}
			tk	= NewTok(Tok.Type.IfCode, parseLineString);
			return tk ;
		} else if( code_type == "else" ) {
			_ptr	+= 4 ;
			if( _ptr >= _end ) {
				err("expect Code");
			}
			skip_space ;
			if( _ptr >= _end ) {
				err("expect Code");
			}
			if( _ptr[0] is '\r' || _ptr[0] is '\n' ) {
				tk	= NewTok(Tok.Type.ElseIfCode, parseLineString);
				return tk ;
			}
			auto code_type2	=  _ptr[ 0 .. safeFind!(const(char))(_ptr, &code_line[$-1], ' ') ];
			
			if( code_type2 == "if" ) {
				_ptr	+= 2 ;
				if( _ptr >= _end ) {
					err("expect Code");
				}
				skip_space ;
				if( _ptr >= _end || _ptr[0] is '\r' || _ptr[0] is '\n' ) {
					err("expect Code");
				}
				tk	= NewTok(Tok.Type.IfCode, parseLineString);
				return tk ;
			}
			err("expect Code `%s`", code_type2);
			
		} else if( code_type == "each" ) {
			
			assert(false, code_type) ;
			
		} else {
			err("expect Code `%s`", code_type);
		}
		
		return tk ;
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

