module oak.langs.gold.Lang ;

import std.conv ;


template Gold_Lang(This) {
	
	static struct Tok {
		ptrdiff_t	symbol_id ;
		ptrdiff_t	lalr_id ;
		ptrdiff_t	ln ;
		dchar[]	data ;
		
		string symbol(){
			if( symbol_id >=0 && symbol_id < SymbolTable.length ) {
				return SymbolTable[ symbol_id] .name ;
			}
			return null ;
		}
	}
	
	private {
		Pool*		pool ;
		ptrdiff_t	comment_level ;
		
		Stack!(Tok*, 0, 512)	
				lalr_tok_stack ,
				input_stack ;
		
		dchar*		_start, _end, _ptr ;
	}
	
	private Tok* NewTok(ptrdiff_t sym_id = -1 , ptrdiff_t lalr_id = -1 ){
		Tok* tk	=  pool.New!(Tok) ;
		
		tk.symbol_id	= sym_id  ;
		tk.lalr_id	= lalr_id  ;
		
		return tk ;
	}
	
	dchar[] input(){
		if( _start is null || _end is null || _start >= _end ) {
			return null ;
		}
		return _start[ 0 .. _end - _start] ;
	}
	
	void Init(string _input ) {
		if( pool is null ) {
			pool	= new Pool ;
			pool.Init(1024 * 1024 * 4 ) ;
		}
		
		Clear();
		_start	= cast(dchar*) pool.alloc( dchar.sizeof * _input.length ) ;
		_end	= _start + _input.length ;
		_ptr	= _start ;
		foreach( int i, dchar c ; _input){
			_ptr[i]	= c ;
		}
		
		auto tk = NewTok(StartSymbolID, InitLALRID) ;
		lalr_tok_stack.push( tk ) ;
	}
	
	
	void Clear() {
		pool.Clear ;
		comment_level	= 0 ;
		lalr_tok_stack.clear ;
		input_stack.clear ;
	}
	
	Tok* RetrieveToken () {
		Tok* tk	= null ;
		if( _ptr > _end ) {
			tk = NewTok( EofSymbolID ) ;
			return tk ;
		}
		bool isDone	= false ;
		ptrdiff_t len	= 0 ;
		DFAState* state	= cast(DFAState*) &DFATable[InitDfaID] ;
		
		DFAState*	accept_state ;
		ptrdiff_t	accept_len ;
		
		static const(DFAEdge*) dfa_find_edge(DFAState* state, dchar c){
			for(int i =0 ; i < state.edges.length;i++) {
				CharSet* set = cast(CharSet*) &CharSetTable[state.edges[i].charset_id ] ;
				foreach( _c; set.set ){
					if( _c is c ) {
						return &state.edges[i] ;
					}
				}
				
			}
			return null ;
		}

		while( !isDone ) {
			
			bool eof = _ptr + len > _end  ;
			
			if( eof ) {
				throw new Exception("err");
			}
			
			if( state.accept ) {
				accept_state	= state ;
				accept_len	= len ;
			}
			
			auto _edge = dfa_find_edge(state, _ptr[len]) ;
			
			if( _edge !is null ) {
				state	= cast(DFAState*) &DFATable[ _edge.dfa_id ] ;
				len++ ;
			} else {
				if( accept_state !is null ) {
					tk = NewTok( accept_state.sym_id,  accept_state.id ) ;
					tk.data	= _ptr[ 0 .. len + 1 ] ; 
				} else {
					tk = NewTok( ErrorSymbolID ) ;
					tk.data	= _ptr[ 0 .. len + 1 ] ; 
				}
				isDone	= true ;
			}
			
		}
		
		return tk ;
	}
	
	
	static int id(string val){
		foreach(ref sym ;SymbolTable){
			if( sym.name == val ) {
				return sym.id ;
			}
		}
		return -1 ;
	}
	
}