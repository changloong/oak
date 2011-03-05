
module jade.Compiler ;

import jade.Jade ;

private {
	
	enum OutType {
		None,
		Code ,
		String ,
		UnStripString ,
		CodeString ,
		Var ,
	}

	static const OutType_Members = EnumNames!(OutType) ;
	
	string outype_string(OutType ty){
		return OutType_Members[ty];
	}
}



struct Compiler {
	alias typeof(this)*	pThis ;
	
	vBuffer		_bu, _code_bu, _text_bu ;
	Parser		parser ;
	bool		terse ;
	OutType		outype ;
	string[]	static_vars ;
	
	void Init(string filename, string data = null ){
		if( _bu is null ){
			_bu		= new vBuffer(1024 * 16, 1024 * 16);
			_code_bu	= new vBuffer(1024 * 16, 1024 * 16);
			_text_bu	= new vBuffer(1024 * 16, 1024 * 16);
		} else {
			_bu.clear ;
		}
		parser.Init(filename, data);
		if( re_text_val.empty ) {
			re_text_val(`(\\?\#?!?){([a-z][\w.\(\)\'\"\_]*)}`, PCRE_CASELESS);
			re_code_if(`^\s*(if|else\s+if)\s+(.+)`, PCRE_CASELESS);
		}
	}
	
	string otype(){
		return outype_string(outype);
	}

	void compile(){
		outype	= OutType.None ;
		this.visit( parser.parser );
		FinishLastOut;
		if( outype !is OutType.None && outype !is OutType.Code ) {
			assert(_bu.length > 0 );
			_bu.move(-1);
			_bu(");\n");
		}
	}		
	
	void FinishLastOut(){
		switch(outype){
			case OutType.CodeString:
			case OutType.String:
			case OutType.UnStripString:
				_bu("'");
			case OutType.Var:
				_bu(" ,");
				break;
			case OutType.None:
				break;
			case OutType.Code:
				break;
			default:
				assert(false, outype_string(outype) );
		}
	}
	
	pThis asString(string val, bool unstrip = true ) {
		OutType _type	= unstrip ? OutType.UnStripString : OutType.String ;
		if( outype !is _type ){
			FinishLastOut() ;
			if( outype is OutType.Code || outype is OutType.None ) {
				_bu("\n$(");
			}
		}
		if( unstrip ) {
			if( outype !is _type ){
				_bu("\n\t1, '");
			}
			_bu.unstrip( val) ;
		} else {
			if( outype !is _type ){
				_bu("\n\t0, '");
			}
			_bu( val) ;
		}
		
		outype	= _type ;
		return &this;
	}
	
	pThis asVar(string val, bool buffer = false , bool unstrip = false ) {
		if( outype !is OutType.Var ) {
			FinishLastOut ;
			if( outype is OutType.Code || outype is OutType.None ) {
				_bu("\n$(");
			}
		}
		if( buffer ) {
			// log("otype=", otype, " var=", val);
			if( unstrip ) {
				_bu("\n\t1, ")(val);
			} else {
				_bu("\n\t0,")(val);
			}
			outype	=  OutType.Var ;
		} else {
			if( unstrip ) {
				_bu("\n\t3, '")(val);
				outype	=  OutType.UnStripString ;
			} else {
				_bu("\n\t2, '")(val);
				outype	=  OutType.String ;
			}
		}
		return &this;
	}
	
	alias void delegate(vBuffer bu) asCodeDg ;
	pThis asCode(string val, bool buffer = false){
		if( buffer ) {
			FinishLastOut;
			if( outype !is OutType.Code && outype !is OutType.None ) {
				assert(_bu.length > 0 );
				_bu.move(-1);
				_bu(");\n");
			}
			_bu(val);
			outype	= OutType.Code ;
		} else {
			if( outype !is  OutType.CodeString ){
				FinishLastOut;
			}
			if( outype is OutType.Code || outype is OutType.None ) {
				_bu("\n$(");
			}
			if( outype !is OutType.CodeString  ) {
				_bu("\n\t4, '");
			}
			_bu.unstrip( val ) ;
			outype	= OutType.CodeString ;
		}
		return &this;
	}
	
	
	static RegExp re_text_val ;
	pThis asText(string val) {
		int lasti	= 0 ;
		// log("otype=", otype," val= `",  val , "`");
		if( re_text_val.each(val, (string[] ms){
			scope(exit){
				lasti	= &ms[0][$-1] - val.ptr + 1 ;
			}
			int starti = &ms[0][0] - val.ptr ;
			if( lasti != starti ){
				asString(val[lasti..starti]);
			}
			if( ms[1].length && ms[1][0] is '\\' ) {
				asString( ms[0][1..$] );
				return true ;
			}
			bool buffer	= false ;
			bool escape	= false ;
			if( ms[1].length is 1 ){
				if( ms[1][0] is '#' ) {
					buffer	= true ;
				} else if( ms[1][0] is '!' ){
					escape	= true ;
				}
			} else if( ms[1].length is 2 ){
				buffer	= true ;
				escape	= true ;
			}
			// log("otype=", otype," var=`",  ms[2], "` buffer=", buffer , " escape=", escape, " src=", ms[0] );
			asVar(ms[2], buffer,  escape);
			return true ;
		}) ){
			if( lasti <= val.length ) {
				asString(val[lasti..$]);
			}
		} else {
			asString(val);
		}
		return &this;
	}
	
	
	void visitNode(Node* node){
		switch( node.tp ) {
			case Node.Type.Block:
				this.visitBlock(node);
				break;
			case Node.Type.Text:
				this.visitText(node);
				break;
			case Node.Type.Tag:
				this.visitTag(node);
				break;
			case Node.Type.Each:
				this.visitEach(node);
				break;
			case Node.Type.Comment:
				this.visitComment(node);
				break;
			case Node.Type.Code:
				this.visitCode(node);
				break;
			case Node.Type.Filter:
				this.visitFilter(node);
				break;
			case Node.Type.DocType:
				this.visitDocType(node);
				break;
			
			default:
				log(node.tp, Node.Type.Tag);
				assert(false, node.type);
		}
	}
	alias visitNode visit;
	
	void visitBlock(Node* block){
		assert(block !is null);
		assert(block.isBlock);
		foreach(_node ;block.block){
			assert( _node !is null);
			visit(_node);
		}
	}
	
	void visitText(Node* text){
		assert(text !is null);
		assert(text.isText);
		_text_bu.clear ;
		text.text.fill( _text_bu );
		asText( cast(string) _text_bu.slice );
	}
	
	void visitTag(Node* tag){
		assert(tag !is null);
		assert(tag.isTag);
		string name = tag.tag.name;

		foreach(int i, ref _name; Tag.self_closing_tags){
			if( name == _name ) {
				asString("<").asString(name);
				visitAttributes(&tag.tag.attrs);
				if( this.terse ) {
					asString(">\n") ;
				} else {
					asString(" />\n") ;
				}
				return ;
			}
		}
		if ( !tag.tag.attrs.empty ) {
			asString("<").asString(name);
			visitAttributes(&tag.tag.attrs);
			asString(">");
		} else {
			asString("<").asString(name).asString(">");
		}
		
            	if (tag.tag.code !is null ){
			visitCode(tag.tag.code);
		}
            	if (tag.tag.text !is null  ) {
			// buffer(utils.text(tag.text.join('\\n').trimLeft()));
			visitText(tag.tag.text);
		}
            	if (tag.tag.block !is null  ) {
			visitBlock(tag.tag.block);
		}
		asString("</").asString( name).asString(">\n");
	}
	
	void visitAttributes(Attrs* attrs){
		if( attrs.id ) {
			asString(` id="`);
			asText( attrs.id.val );
			asString(`"`);
		}
		ubyte[1024 * 4] _bu_tmp_data ;
		scope _tmp_bu	= new vBuffer(_bu_tmp_data);
		foreach(_class; attrs.className){
			_tmp_bu( _class.val)(" ");
		}
		if( _tmp_bu.length > 1 ) {
			_tmp_bu.move(-1);
			asString(` class="`);
			asText( cast(string) _tmp_bu.slice );
			asString(`"`);
		}
		foreach(string key, ref val; attrs.list ){
			
			if( val is null ) {
				asString(" ");
				asText( key );
				asString(`="true"`);
			} else {
				asString(" ");
				asText( key );
				asString(`="`);
				asText( val );
				asString(`"`);
			}
		}
	}
	
	void visitComment(Node* comment){
		assert(comment !is null);
		assert(comment.isComment);
		if (!comment.buffer) return;
		asString("<!-- ");
		asText( comment.val );
		asString(" -->\n");
	}
	
    	static RegExp re_code_if ;
	void visitCode(Node* code){
		assert(code !is null);
		assert(code.isCode);
		
		if( code.code.isVar) {
			assert(code.code.block is null ) ;
			asVar( code.val, code.buffer, code.escape);
			return ;
		}
		
		_code_bu.clear;
		if( !re_code_if.each(code.val, (string[] ms){
			_code_bu(ms[1])(" ( ")( ms[2] )(" ) ");
			return false ;	
		}) ) {
			_code_bu(code.val);
		}

		// Block support
		if (code.code.block) {
			_code_bu("{\n");
			asCode( cast(string) _code_bu.slice,  code.buffer);
			this.visit(code.code.block);
			_code_bu.clear ;
			_code_bu("}\n");
		}
		asCode( cast(string) _code_bu.slice, code.buffer);
	}
	
	
	void visitDocType(Node* doc){
		assert(doc !is null);
		assert(doc.isDocType);

		string name = doc.val;
        	if (`5` == name) {
			this.terse = true;
		}
		string doctype = doc.doctype.value ;
       		if ( doctype is null){
			throw new Error(`unknown doctype "` ~ name ~ `"`);
		}
       		asString(doctype);
       		//_bu("\\n");
	}
	
	string js(){
		return cast(string) _bu.slice ;
	}
	
	void visitEach(Node* node){
		assert(node !is null);
		assert(node.isEach);

		Each* each = &node.each ;
		
		
		_code_bu.clear;
		_code_bu
			("// each: ")(each.obj)(", file: ")(parser.filename)(", line: ")(node.ln)("\n")
			("$.each(this, ")(each.obj)(", function(")(each.value)(", ")(each.key)("){\n");
		;
		asCode( cast(string) _code_bu.slice,  node.buffer);
		if( node.buffer ){
			static_vars	~= each.key ;
			static_vars	~= each.value ;
		}
		this.visitBlock(each.block);
		if( node.buffer ){
			assert(static_vars.length >= 2);
			static_vars	= static_vars[0..$-2] ;
		}
		_code_bu.clear;
		_code_bu("}); \n// each: ")(each.obj)(", file: ")(parser.filename)(", line: ")(node.ln)("\n");
		asCode( cast(string) _code_bu.slice,  node.buffer);
	}
	
	void visitFilter(Node* filter){
		assert(filter !is null);
		assert(filter.isFilter);
		assert(false);
	}
}