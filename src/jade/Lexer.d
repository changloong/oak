
module jade.Lexer ;

import jade.Jade ;

struct Lexer {
	string	input;
	Tok*[]	deferredTokens ;
	size_t	lastIndents ;
	size_t	ln ;
	Tok*[]	stash ;
	vBuffer	bu1, bu2 = null ;
	
	private static RegExp init_re1, init_re2;
	void Init(string str) {
		if( bu1 is null ) {
			bu1	= new vBuffer(1024 * 16 , 1024 * 16 );
			bu2	= new vBuffer(1024 * 16 , 1024 * 16 );
		}
		init_re1.replace(bu1, str, '\n');
		init_re2.replace(bu2, cast(string) bu1.slice, "  ");
		this.input = cast(string) bu2.slice ;
		
		this.deferredTokens = [] ;
		this.lastIndents = 0;
		this.ln	 = 1 ;
		this.stash	= [] ;
		
	}
	
	Tok* token(Tok.Type tp, string val = null ) {
		Tok* tok = new Tok ;
		tok.tp	= tp ;
		tok.ln	= ln ;
		tok.val	= val ;
		return tok ;
	}
	
	void consume(size_t len) {
        	input = input[len .. $] ;
    	}
	
	Tok* scan(RegExp* re, Tok.Type tp) {
		Tok* tok;
		re.each(input, (string[] captures){
			this.consume(captures[0].length);
			tok	= this.token(tp, captures[1]);
			return false ;
		});
		return tok ;
	}
	
	void defer(Tok* tok) {
		this.deferredTokens	~= tok;
	}
	
	Tok*   lookahead(size_t n){
		size_t fetch = n - this.stash.length;
		while (fetch-- > 0){
			this.stash	~= this.next ;
		}
		return this.stash[--n];
	}
	
	Tok* stashed() {
		if( this.stash.length ) {
			Tok* tok = this.stash[0];
			this.stash	= this.stash[1..$];
			return tok ;
		}
		return null ;
	}
	
	Tok* deferred(){
		if( this.deferredTokens.length ) {
			Tok* tok 	= this.deferredTokens[0];
			this.deferredTokens	= this.deferredTokens[1..$];
			return tok ;
		}
		return null ;
	}
	
	Tok*  advance(){
		Tok* tok = this.stashed ;
		if( tok !is null) {
			return tok ;
		}
		return this.next;
	}
	
	Tok* eos() {
		if (this.input.length){
			return null ;
		}
		return
			this.lastIndents-- > 0  
			? this.token(Tok.Type.Outdent)
		    	: this.token( Tok.Type.Eos ) ;
	}
	
	private static RegExp comment_re1 ;
	Tok*  comment() {
		assert(!comment_re1.empty);
		
		Tok* tok = null ;
		comment_re1.each(input, (string[] ms) {
			tok = token(Tok.Type.Comment, ms[2]);
			tok.isPublic	= ms[1] != `-`;
			consume(ms[0].length) ;
			return false ;
		}) ;
		return tok ;
	}
	
	private static RegExp tag_re1 ;
	Tok*  tag() {
       		return this.scan(&tag_re1, Tok.Type.Tag) ;
    	}
	
	private static RegExp filter_re1 ;
	Tok*  filter() {
        	return this.scan(&filter_re1, Tok.Type.Filter);
    	}
	
	private static RegExp doctype_re1 ;
	Tok* doctype() {
		return this.scan(&doctype_re1, Tok.Type.DocType);
	}
	
	private static RegExp id_re1 ;
	Tok* id(){
		return this.scan(&id_re1, Tok.Type.Id) ;
	}
	
	private static RegExp className_re1 ;
	Tok*  className() {
		return this.scan(&className_re1, Tok.Type.Class );
	}
	
	private static RegExp text_re1 ;
	Tok*   text() {
		return this.scan(&text_re1, Tok.Type.Text);
	}
	
	private static RegExp each_re1 ;
        Tok*  each() {
		Tok* tok  = null ;
		each_re1.each( input, (string[] captures){
			
			tok	= this.token(Tok.Type.Each) ;
			
			// tok.buffer	= captures[1].length > 1 ;
			tok.val		= captures[2] ;
		    	tok.key		= captures[3] .length ? captures[3] : captures[2]  ~ `_index` ;
			tok.code	= captures[4] ;
			tok.ln		= this.ln ;
			
			consume(captures[0].length);
			return false ;
		});
		return tok;
	}

	private static RegExp code_re1 ;
	Tok*  code() {
		Tok* tok  = null ;
		code_re1.each( input, (string[] captures){
			auto flags = captures[1] ;
			//log(captures[1..$]);
			tok = this.token(Tok.Type.Code, captures[2]) ;
			if(  flags[0] is '-' ){
				if( flags.length > 1 ) {
					// tok.buffer	= true ;
				}
			} else {
				tok.isVar	= true ;
				if( flags.length > 1 ) {
					tok.escape	= flags[0] is '='  ;
					// tok.buffer	= flags[0] is '=' || flags[1] is '=';
				}
			}
			consume(captures[0].length);
			return false ;
		});
		return tok;
	}
	
	private static RegExp attrs_re1 ;
	Tok*  attrs() {
		if( input.length < 3 || input[0] !is '(' ) {
			return null ;
		}
		Tok* tok ;
		int index	= this.indexOfDelimiters('(', ')') ;
		string str	= this.input[1..index] ;
		this.consume(index + 1);
		//log("`", str, "`");
		tok	= this.token(Tok.Type.Attrs, str) ;
		int i = 0 ;
		attrs_re1.split( str, (string pair) {
			int colon = std.string.indexOf( pair, ':');
                 	int equal = std.string.indexOf( pair, '=');
			string key ;
			string val	= null ;
			if (colon < 0 && equal < 0) {
			 	key	= pair ;
			} else {
				int split = equal >= 0 ? equal : colon ;
				if (colon >= 0 && colon < equal) {
					split = colon;
				}
				key	= pair[0..split] ;
				val	= pair[++split .. $] ;
			}
			// key = key.trim().replace(/^['"]|['"]$/g, '') ;
			tok.attrs.add( key, val ) ;
		});
		return tok ;
	}
	
	private static RegExp indent_re1 ;
	Tok* indent() {
		Tok* tok = null ;
		indent_re1.each( input, (string[] captures){
			++this.ln ;
			this.consume(captures[0].length);
			tok = this.token(Tok.Type.Indent, captures[1]) ;
			int indents	= tok.val.length / 2 ;
			if (this.input is null || this.input.length is 0 || this.input[0] is '\n') {
                		tok.tp = Tok.Type.Newline;
                		return false;
			} else if (indents % 1 !is 0) {
				/++
				throw new Error('Invalid indentation, got '
				    + tok.val.length + ' space' 
				    + (tok.val.length > 1 ? 's' : '') 
				    + ', must be a multiple of two.');
				++/
				assert(false);	
			} else if (indents is this.lastIndents) {
				tok.tp = Tok.Type.Newline;
			} else if (indents > this.lastIndents + 1) {
				/*
					throw new Error('Invalid indentation, got ' 
					    + indents + ' expected ' 
					    + (this.lastIndents + 1) + '.');
				*/
				assert(false);	
			} else if (indents < this.lastIndents) {
				int n = this.lastIndents - indents;
				tok.tp = Tok.Type.Outdent;
				while (--n > 0 ) {
					this.defer( this.token(Tok.Type.Outdent) ) ;
				}
			}
            		this.lastIndents = indents;
			return false;
		});
		
		return tok;
	}
	
	Tok* next(){
		Tok* tok = this.deferred ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.eos ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.tag ;
		if( tok !is null ){
			return tok ;
		}

		tok = this.filter ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.each ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.code ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.doctype ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.id ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.className ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.attrs ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.indent ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.comment ;
		if( tok !is null ){
			return tok ;
		}
		tok = this.text ;
		if( tok !is null ){
			return tok ;
		}
		return null ;
	}
	
	static void Init_RegExp() {
		
		init_re1(`\r\n|\r` "\0");
		init_re2(`\t`  "\0");
		
		comment_re1(`^ *\/\/(-)?([^\n]+)`  "\0") ;
		tag_re1(`^(\w[-:\w]*)`  "\0");
		filter_re1(`^:(\w+)`  "\0");
		
		doctype_re1(`^!!! *(\w*)`  "\0");
		id_re1(`^#([\w-]+)`  "\0");
		
		className_re1(`^\.([\w-]+)`  "\0");
		text_re1(`^ ?(?:\| ?)?([^\n]+)`  "\0");
		each_re1(`^(--?) *each *(\w+)(?: *, *(\w+))? * in *([^\n]+)`  "\0");
		code_re1(`^(!?=|--?)([^\n]+)`  "\0");
		
		indent_re1(`^\n( *)`  "\0");
		
		attrs_re1(` *, *(?=['"\w-]+ *[:=]|[\w-]+ *$)`  "\0");
		
	}
	
	int indexOfDelimiters(char start, char end){
		string str = input;
		int	nstart = 0 ,
			nend = 0 ,
			pos = 0 ;
		for (int i = 0, len = str.length; i < len; ++i) {
			if (start is str[i]) {
				++nstart;
			} else if (end is str[i]) {
				if (++nend is nstart) {
					pos = i ;
					break ;
				}
			}
		}
		return pos;
	}
}

static this(){
	Lexer.Init_RegExp ;
}