
module oak.langs.jade.Parser ;

import oak.langs.jade.Jade ;

alias oak.langs.jade.node.Filter.Filter Filter ;

struct Parser {
	Pool*		pool ;
	string		filename ;
	string		filedata ;
	Lexer		lexer ;
	Node		_last_node, root ;
	Tok*		_last_tok ;
	size_t		_root_node_offset ;
	Stack!(Filter,512)
			_filters ;
	Filter		_last_block_filter = null ;
	bool		use_extend ;
	alias 		_last_tok peek ;
	
	void Init(Compiler* cc) in {
		assert( cc !is null);
	} body {
		pool		= cc.pool ;
		filename	= cc .filename ;
		filedata	= cc .filedata ;
		use_extend	= false ;
		lexer.Init(cc) ;
	}
	
	void err(size_t _line = __LINE__, T...)(string fmt, T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		//formattedWrite(a, " at file:`%s` line:%d", filename, ln);
		throw new Exception( a.data );
	}
	
	Tok* advance(ptrdiff_t pos = 0 ) {
		Tok* tk = _last_tok  ;
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
	
	Tok* next(string _file = __FILE__, ptrdiff_t _line = __LINE__)() {
		Tok* tk = _last_tok  ;
		if( tk is null ) {
			return tk ;
		}
		tk	= tk.next ;
		_last_tok = tk ;
		version(JADE_DEBUG_PARSER)
		if( tk is null ) {
			Log!(_file, _line)("move to next tok = null " );
		} else {
			Log!(_file, _line)("move to next tok = %s ln:%d tab:%d  `%s` ", tk.type(), tk.ln, tk.tabs, tk.string_value);
		}
		return tk ;
	}
	
	void dump_next(string _file = __FILE__, ptrdiff_t _line = __LINE__)(){
		Tok* tk = _last_tok  ;
		if( tk is null ) {
			version(JADE_DEBUG_PARSER)
				Log!(_file, _line)("peek = null ");
			return  ;
		}
		version(JADE_DEBUG_PARSER)
			Log!(_file, _line)("peek = %s ln:%d:%d tab=%d `%s`",  tk.type(), tk.ln, tk._ln, tk.tabs, tk.string_value ) ;
		tk	= tk.next ;
		if( tk is null ) {
			Log!(_file, _line)("next = null ");
			return  ;
		}
		version(JADE_DEBUG_PARSER)
			Log!(_file, _line)("next = %s ln:%d:%d tab=%d `%s`",  tk.type(), tk.ln, tk._ln, tk.tabs, tk.string_value ) ;
	}
	
	Tok* peekSibling(Tok* tk = null) {
		if( tk is null ) {
			tk = _last_tok  ;
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
			next() ;
			return tk ;
		} else {
			err("expected %s, but got %s on line:%d",  Tok.sType(ty), tk.type(),  this.filename, tk.ln ) ;
		}
		return null ;
	}
	
	void parse() {
		lexer.parse ;
		
		_last_block_filter = null ;
		_last_tok	= lexer._root_token ;
		root = NewNode!(Block)();
		use_extend	= false ;
		_root_node_offset = 0 ;
		for( auto node	= parseExpr(); node !is null; node = parseExpr()) {
			root.pushChild(node);
			_root_node_offset = 0 ;
			if( use_extend ) {
				auto _filter = cast(Filter) node ;
				if( _filter is null ) {
					err("`%s` with @extend root child must be @block, but find %s at line %d", filename, node.type() , node.ln );
				} else if( !_filter.render_obj.isBlock() && !_filter.render_obj.isExtend() ){
					err("`%s` with @extend root child must be @block, but find @%s at line %d", filename, _filter.render_obj.name , node.ln );
				}
			}
		}
	}
	
	void dump_tok(string _file = __FILE__, ptrdiff_t _line = __LINE__)( bool from_last_tok = false ) {
		writefln("\n--------- dump tok --------\n%s:%d", _file, _line);
		Tok* tk	= lexer._root_token ;
		if( from_last_tok ) {
			tk	= _last_tok ;
		}
		while( tk !is null ) {
			//auto node = parseExpr ;
			writefln("tab:%d ln:%d:%d %s = `%s`" , tk.tabs, tk.ln,tk._ln, tk.type(), tk.string_value );
			tk	= tk.next ;
		}
	}
	
	private N NewNode(N, string _file = __FILE__, ptrdiff_t _line = __LINE__, T... )(T t) if( is(N==class) && BaseClassesTuple!(N).length > 0 && is( BaseClassesTuple!(N)[0] == Node) ){
		_root_node_offset++;
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
			version(JADE_DEBUG_PARSER)
				Log!(_file, _line)(" ===> New %s , ln:%d:%d tab:%d `%s` ",  N.stringof , t[0].ln, t[0]._ln, t[0].tabs, t[0].string_value);
		}  else {
			node = pool.New!(N)(t) ;
		}
		mixin("node.ty = Node.Type." ~ N.stringof  ~ ";" );
		assert(node.firstChild is null ) ;
		assert(node.next is null ) ;
		return node ;
	}
	
	private Node parseExpr(string _file = __FILE__, ptrdiff_t _line = __LINE__)() {
		Tok* tk = peek ;
		if( tk is null ) {
			return null ;
		}
		version(JADE_DEBUG_PARSER)
			Log!(_file,_line)("parseExpr %s ln:%d tab:%d  `%s`", tk.type(), tk.ln, tk.tabs, tk.string_value);
		Node node ;
		switch( tk.ty ) {
			
			// not move next node
			case Tok.Type.DocType:
				node	= parseDocType() ;
				break;
			case Tok.Type.Tag:
				node	= parseTag() ;
				break;
			case Tok.Type.FilterType :
				node = parseFilter ;
				break;

			// move next node
			case Tok.Type.String:
				node	= NewNode!(PureString)( tk ) ;
				next() ;
				break;
			
			case Tok.Type.Var:
				node	= NewNode!(Var)( tk ) ;
				next() ;
				break;
	
			case Tok.Type.Code:
				node	= NewNode!(Code)( tk ) ;
				next() ;
				break;
			
			case Tok.Type.If:
				node	= parseInlineIf;
				tk	= peek;
				assert(tk !is null);
				assert(tk.ty is Tok.Type.IfEnd  );
				assert( node !is null );
				next() ;
				break;
			
			case Tok.Type.CommentBlock:
				node	= parseCommentBlock;
				assert(node !is null);
				break;

			case Tok.Type.CommentStart:
				node	= parseComment;
				assert(node !is null);
				tk	= peek ;
				assert(tk !is null);
				assert(tk.ty is Tok.Type.CommentEnd);
				next();
				break;
			
			case Tok.Type.Each_Object:
				node	= parseEach ;
				assert(node !is null);
				break;
			
			case Tok.Type.IfCode:
				node	= parseIfCode ;
				assert(node !is null);
				break;
			
			default:
				dump_next();
				Log("%s ln:%d tab:%d  `%s`", tk.type(), tk.ln, tk.tabs, tk.string_value);
				assert(false) ;
		}
		return node ;
	}
	
	Node parseDocType(){
		Tok* tk	= expect(Tok.Type.DocType) ;
		assert(tk !is null);
		return NewNode!(DocType)( tk ) ;
	}
	
	Tag parseTag(){
		Tok* tk	= expect(Tok.Type.Tag) ;
		assert(tk !is null);
		auto node 	= NewNode!(Tag)( tk ) ;
		
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		// find id, class
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( _ln != _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.Id:
					node.id = tk.string_value ;
					next();
					break ;
					
				case Tok.Type.Class:
					if( node.classes is null ) {
						node.classes	= NewNode!(TagClasses)() ;
					}
					auto _node	=  NewNode!(TagClass)(tk) ;
					node.classes.pushChild( _node ) ;
					next();
					break;
				default:
					break L1;
			}
		}
		
		// find attrs 
		L2:
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( _ln != _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.AttrStart:
					node.attrs	= parseAttrs() ;
					assert(node.attrs !is null ) ;
					assert( peek.ty is Tok.Type.AttrEnd);
					next() ;
					break L2;
				
				default:
					break L2;
			}
		}
		
		// find inline text
		tk	= peek ;
		if( tk !is null && tk._ln is _ln ) {
			// tack all child string 
			auto _node	= parseMixString() ;
			assert( _node !is null);
			node.pushChild(_node);
		}
		
		// find all child 
		L3:
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}

		return node ;
	}
	
	
	Attrs parseAttrs() {
		Tok* tk	= expect(Tok.Type.AttrStart) ;
		auto node 	= NewNode!(Attrs)( tk ) ;
		auto _ln	= tk._ln ;
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( _ln != _ln ) {
				err("end attrs wrong ");
				break ;
			}
			switch( tk.ty ) {
				
				case Tok.Type.AttrKey:
					auto _node	= parseAttr();
					assert(_node !is null );
					tk	= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.AttrValueEnd );
					// push to attrs 
					node.pushChild(_node);
				
					// one attr end, more attr to go
					next();
					break ;
		
				case Tok.Type.If:
					//  a if attrs block
					auto _node	= parseAttrIfBlock() ;
					assert(_node !is null );
					tk	= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.IfEnd );
					// push to attrs 
					node.pushChild(_node);
					// one attr if end, more attr to go
					next();
					break;
				
				default:
					// end attrs
					break L1;
			}
		}
		version(JADE_DEBUG_PARSER) {
			dump_next();
			Log(" ========> end attrs ");
		}
		return node ;
	}
	
	
	Node parseAttrIfBlock() {
		Tok* tk		= expect(Tok.Type.If) ;
		auto node 	= NewNode!(InlineIf)( tk ) ;
		
		auto _ln	= tk._ln ;
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				err("missing InlineIf end on line: %d", node.ln );
				break ;
			}
			switch( tk.ty ) {
				
				case Tok.Type.AttrKey:
					auto _node	= parseAttr();
					assert(_node !is null );
					tk	= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.AttrValueEnd );
					// push to attrs 
					node.pushChild(_node);
				
					// one attr end, more attr to go
					next();
					break ;
				
				case Tok.Type.If:
					//  a if attrs block
					auto _node	= parseAttrIfBlock() ;
					assert(_node !is null );
					tk	= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.IfEnd );
					// push to attrs 
					node.pushChild(_node);
					// one attr if end, more attr to go
					next();
					break;

				case Tok.Type.ElseIf :
					assert(false);
					break ;
				case Tok.Type.Else :
					assert(false);
					break ;
				
				case Tok.Type.IfEnd  :
					break L1 ;
				
				default:
					dump_next();
					err("missing InlineIf end on line: %d", node.ln );
			}
		}
		version(JADE_DEBUG_PARSER){
			dump_next();
			Log(" ========> end attr if ");
		}
		return node ;
	}
	
	Node parseAttr() {
		Tok* tk	= expect(Tok.Type.AttrKey) ;
		auto node 	= NewNode!(Attr)( tk ) ;
		node.key	=  tk.string_value ;
		auto _ln	= tk._ln ;
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( _ln != _ln ) {
				err("end attr key wrong ");
				break ;
			}
			switch( tk.ty ) {
				case  Tok.Type.AttrValueStart :
					node.value	= parseAttrValue ;
					assert( node.value !is null ) ;
					tk	= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.AttrValueEnd );
					break L1;
				default:
					dump_tok();
					err("%s ln:%d tab:%d  `%s`", tk.type(), tk.ln, tk.tabs, tk.string_value);
			}
		}
		return node ;
	}
	
	MixString parseAttrValue() {
		Tok* tk	= expect(Tok.Type.AttrValueStart) ;
		auto node 	= NewNode!(MixString)( tk ) ;
		auto _ln	= tk._ln ;
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( _ln != _ln ) {
				err("end attr value wrong ");
				break ;
			}
			switch( tk.ty ) {
				case  Tok.Type.If :
					auto _node	= parseInlineIf() ;
					tk	= peek;
					assert(tk !is null);
					assert(tk.ty is Tok.Type.IfEnd  );
					assert( _node !is null );
					node.pushChild(_node);
					next();
					break ;
		
				case  Tok.Type.String :
					auto _node	= NewNode!(PureString)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case  Tok.Type.Var :
					auto _node	= NewNode!(Var)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case  Tok.Type.AttrValueEnd :
					break L1;
				
				default:
					assert( tk is  peek) ;
					dump_next();
					Log("%s ln:%d tab:%d  `%s`", tk.type(), tk.ln, tk.tabs, tk.string_value);
					assert(false) ;
			}
		}
		version(JADE_DEBUG_PARSER)
			Log(" ========> end attr value ,  end mix string");
		return node ;
	}
	
	Node parseInlineIf() {
		Tok* tk		= expect(Tok.Type.If) ;
		auto node 	= NewNode!(InlineIf)( tk ) ;
		
		auto _ln	= tk._ln ;
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				err("missing InlineIf end on line: %d", node.ln );
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.String :
					auto _node	= NewNode!(PureString)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				case Tok.Type.Var :
					auto _node	= NewNode!(Var)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case Tok.Type.ElseIf :
					auto _node	= NewNode!(InlineElseIf)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case Tok.Type.Else :
					auto _node	= NewNode!(InlineElse)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case Tok.Type.If :
					auto _node	= parseInlineIf ;
					tk	= peek;
					assert(tk !is null);
					assert(tk.ty is Tok.Type.IfEnd  );
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case Tok.Type.IfEnd  :
					break L1 ;
				
				default:
					dump_next();
					err("missing InlineIf end on line: %d", node.ln );
			}
		}
		version(JADE_DEBUG_PARSER){
			dump_next();
			Log(" ========> end if ");
		}
		return node ;
	}
	
	MixString parseMixString() {
		Tok* tk		= peek ;
		
		auto node	= NewNode!(MixString)( tk ) ;
	
		auto _ln	= tk._ln ;
		L1:
		for(  ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.String :
					auto _node	= NewNode!(PureString)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				case Tok.Type.Var  :
					auto _node	= NewNode!(Var)( tk ) ;
					node.pushChild( _node ) ;
					next() ;
					break ;
				
				case Tok.Type.If  :
					auto _node	= parseInlineIf() ;					tk	= peek;
					assert(tk !is null);
					assert(tk.ty is Tok.Type.IfEnd  );
					assert( _node !is null );
					node.pushChild(_node);
					next();
					break ;
				
				default:
					break L1;
			}
		}
		
		version(JADE_DEBUG_PARSER) {
			tk	= peek ;
			if( tk !is null ) {
				dump_next();
				Log("%s ln:%d tab:%d  `%s`", tk.type(), tk.ln, tk.tabs, tk.string_value );
			}
			Log(" ========> end mix string ");
		}
		
		return node ;
	}
	
	Filter parseFilter() {
		Tok* tk	= expect(Tok.Type.FilterType) ;
		assert(tk !is null);
		bool is_block_node	= false ;
		bool is_block_parent	= false ;
		if( tk.render_obj.isExtend() ) {
			if( !root.empty || _root_node_offset !is 0 ) {
				err("@extend must be first node in `%s` at line %d", filename, tk.ln ) ;
			}
			use_extend	= true ;
		} else if( tk.render_obj.isBlock() ) {
			/*
			if( use_extend && _root_node_offset !is 0 ) {
				err("@block must be root node child in `%s` at line %d", filename, tk.ln ) ;
			}
			*/
			is_block_node	= true ;
		} else if( tk.render_obj.isBlock_Parent() ){
			if( !use_extend ) {
				err("@block_parent must be use with @extend at %s:%d", filename, tk.ln ) ;
			}
			is_block_parent	= true ;
		}
		
		auto node	= NewNode!(Filter)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		if( is_block_node ){
			if( _last_block_filter !is null ) {
				node.parent_filter	= _last_block_filter ;
			} else {
				node.parent_filter	= null ;
			}
			_last_block_filter	= node ;
		} else if( is_block_parent ) {
			if( _last_block_filter is null ) {
				err("@block_parent must in @block at %s:%d", filename, tk.ln );
			}
			node.parent_filter	= _last_block_filter ;
		}			
		
		
		scope (exit){
			if( is_block_node ) {
				_last_block_filter	= node.parent_filter ;
			}
		}
	
		
		// find filter arg
		L1:
		for( tk = peek  ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.FilterArgStart :
					if( node.args is null ) {
						node.args = NewNode!(FilterArgs)();
					}
					next();
					if(  node.render_obj.with_args_mixed  ) {
						auto _node	= parseMixString() ;
						assert( _node !is null);
						node.args.pushChild( _node );
						// skip FilterArgEnd
					} else {
						tk	= peek ;
						assert(tk !is null );
						auto _node	= NewNode!(PureString)( tk ) ;
						node.args.pushChild( _node );
						next();
					}
					tk	= peek ;
					assert(tk !is null );
					assert( tk.ty is Tok.Type.FilterArgEnd);
					
					next();
					break ;
					
				default:
					break L1;
			}
		}
	
		// find tag
		L2:
		for( tk = peek  ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.Tag:
					node.tag	= parseTag ;
					assert( node.tag !is null) ;
					break;

				default:
					break L2;
			}
		}
		
		// find sub filter arg tag
		L3:
		for( tk = peek  ; tk !is null ; tk = peek ) {
			if( tk._ln !is _ln ) {
				break ;
			}
			switch( tk.ty ) {
				case Tok.Type.FilterTagKey:
					
					auto _node	= parseFilterTagArg ;
					tk  		= peek ;
					assert( tk !is null);
					assert( tk.ty is Tok.Type.FilterTagKeyValueEnd );
					assert(_node !is null);
					if( node.tag_args is null ) {
						node.tag_args = NewNode!(FilterTagArgs)( tk ) ;
					}
					node.tag_args .pushChild(_node);
					next();
					break ;

				default:
					tk.dump;
					assert(false);
					break L3;
			}
		}
		
		
		// find child text , hasVar
		L4:
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			if( node.render_obj.with_text_children ) {
				if( _node.isVar || _node.isInlineIf || _node.isPureString ) {
					node.pushChild(_node);
				} else {
					err("@%s(line:%s) can't have html children at line %s", node.render_obj.name, node.ln , _node.ln );	
				}
			} else if( node.render_obj.with_html_children ) {
				node.pushChild(_node);
			} else {
				err("@%s(line:%s) can't have children at line %s", node.render_obj.name, node.ln, _node.ln );
			}
		}
		
		if( tk !is null && tk.ty is Tok.Type.FilterArgStart  ) {
			assert(false);
		}
		
		//assert(false) ;
		version(JADE_DEBUG_PARSER) {
			Log(" ==============> end filter ");
		}
		
		
		if( node.args ) {
			if( node.args.length < node.render_obj.args_min ){
				err("@%s at %s:%d is at leas need %d args",  node.render_obj.name , filename, node.ln , node.render_obj.args_min );
			}
			
			if( node.args.length > node.render_obj.args_max ){
				err("@%s at %s:%d is allows a maximum of %d args",  node.render_obj.name , filename, node.ln , node.render_obj.args_max );
			}
		} else {
			if( node.render_obj.args_min ){
				err("@%s at %s:%d is at leas need %d args",  node.render_obj.name , filename, node.ln , node.render_obj.args_min );
			}
		}
		
		if( is_block_node ) {
			node.filter_name	= node.get_arg() ;
			auto _filter	= getFilter( node.filter_name ) ;
			if( _filter !is null ) {
				err("@block.%s:%d conflict with @block.%s:%d at file %s ", _filter.filter_name , _filter.ln, node.filter_name, node.ln , filename  );
			}
			_filters.push( node ) ;
		}
		
		return node ;
	}
	
	Node parseFilterTagArg(){
		Tok* tk		= expect(Tok.Type.FilterTagKey) ;
		assert(tk !is null);
		auto node	=  NewNode!(FilterTagArg)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		tk	= peek ;
		// find FilterTagValueStart
		if( tk is null || tk.ty !is Tok.Type.FilterTagValueStart ) {
			err("missing filter tag arg value start");
		}
		next();
		
		node.value	= parseMixString() ;
		if( node.value is null ) {
			err("missing filter tag arg value");
		}
		
		
		tk	= peek ;
		if( tk is null || tk.ty !is Tok.Type.FilterTagValueEnd ) {
			err("missing filter tag arg value end");
		}
		next();
		

		// find FilterTagArgStart
		tk	= peek ;
		if( tk !is null && tk.ty is Tok.Type.FilterTagArgStart ) {
			next();
			L1:
			for(tk	= peek ; tk !is null ; tk	= peek  ) {
				if( tk.ty is Tok.Type.FilterTagArgStart  ) {
					break ;
				}
				if( tk._ln !is _ln ) {
					break ;
				}
				if( tk.tabs < _tab ) {
					break ;
				}
				if( tk.ty !=  Tok.Type.Tag ) {
					break ;
				}
				assert( node.tag is null );
				node.tag	= parseTag() ;
				assert( node.tag !is null) ;
			}
			tk	= peek ;
			if( tk is null || tk.ty !is Tok.Type.FilterTagArgEnd ) {
				err("missing filter tag arg end");
			}
			next();
		}
		return node ;
	}
	
	Node parseComment(){
		Tok* tk	= expect(Tok.Type.CommentStart) ;
		assert(tk !is null);
		auto node	=  NewNode!(Comment)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		// find inline text
		tk	= peek ;
		if( tk !is null && tk._ln is _ln ) {
			// tack all child string 
			auto _node	= parseMixString() ;
			assert( _node !is null);
			node.pushChild(_node);
		}
		
		return node ;
	}
	
	Node parseIfCode(){
		Tok* tk	= expect(Tok.Type.IfCode) ;
		assert(tk !is null);
		auto node	=  NewNode!(IfCode)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		// find all child 
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}

		// need find elseif
		tk	= peek ;
		if( tk !is null && tk.tabs is _tab && tk.ty is Tok.Type.ElseIf  ) {
			// take elseif block
			node.elseif = parseElseIfCode ;
		}
		
		// need find else
		tk	= peek ;
		if( tk !is null && tk.tabs is _tab && tk.ty is Tok.Type.ElseCode  ) {
			// take else block
			node.elseBlock	= parseElseCode ;
		}
		
		return node ;
	}
	
	ElseIfCode parseElseIfCode(){
		Tok* tk	= expect(Tok.Type.ElseIfCode) ;
		assert(tk !is null);
		auto node	=  NewNode!(ElseIfCode)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		// find all child 
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}
		
		// need find elseif
		tk	= peek ;
		if( tk !is null && tk.tabs is _tab && tk.ty is Tok.Type.ElseIf  ) {
			// take elseif block
			node.elseif = parseElseIfCode ;
		}
		
		// need find else
		tk	= peek ;
		if( tk !is null && tk.tabs is _tab && tk.ty is Tok.Type.ElseCode  ) {
			// take else block
			node.elseBlock	= parseElseCode ;
		}
		
		return node ;
	}
	
	ElseCode parseElseCode(){
		Tok* tk	= expect(Tok.Type.ElseCode) ;
		assert(tk !is null);
		auto node	=  NewNode!(ElseCode)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		// find all child 
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}
		
		return node ;
	}
	
	Node parseCommentBlock(){
		Tok* tk	= expect(Tok.Type.CommentBlock) ;
		assert(tk !is null);
		auto node	=  NewNode!(CommentBlock)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		// find inline text
		tk	= peek ;
		if( tk !is null && tk._ln is _ln ) {
			// tack all child string 
			auto _node	= parseMixString() ;
			assert( _node !is null);
			node.pushChild(_node);
		}
		
		// find all child 
		L3:
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}
		return node ;
	}
	
	Node parseEach(){
		Tok* tk	= expect(Tok.Type.Each_Object) ;
		assert(tk !is null);
		auto node	=  NewNode!(Each)( tk ) ;
		auto _ln	= tk._ln ;
		auto _tab	= tk.tabs ;
		
		tk	= peek ;
		if( tk is null ) {
			err("missing each key, tk is null");
		}
		// find each type
		if( tk.ty is Tok.Type.Each_Type ) {
			assert( tk.string_value !is null ) ;
			node.type	= tk.string_value ;
			next();
			tk	= peek ;
		}
		if( tk is null ) {
			err("missing each key, tk is null");
		}
		// find each key
		if( tk.ty is Tok.Type.Each_Key ) {
			assert( tk.string_value !is null ) ;
			node.key	= tk.string_value ;
			next();
			tk	= peek ;
		}
		
		
		// find each value type
		if( tk.ty is Tok.Type.Each_Type ) {
			assert( tk.string_value !is null ) ;
			node.value_type  = tk.string_value ;
			next();
			tk	= peek ;
		}
		
		if( tk is null ) {
			err("missing each value, tk is null");
		}
		// find each value
		if( tk.ty is Tok.Type.Each_Value ) {
			assert( tk.string_value !is null ) ;
			node.value	= tk.string_value ;
			next();
			tk	= peek ;
		}
		
		if( node.value is null ) {
			err("missing each value,  `%s`", tk.type() );
		}
		
		// find all child 
		L1:
		for(  tk = peek ; tk !is null ; tk = peek ){
			if( tk.tabs <= _tab ) {
				break ;
			}
			auto _node = parseExpr();
			assert(_node !is null);
			node.pushChild(_node);
		}
		
		return node ;
	}
	
	Filter getFilter(string filter_name){
		foreach(Filter _filter ;_filters) {
			if( _filter.filter_name == filter_name ) {
				return _filter ;
			}
		}
		return null ;
	}
}
