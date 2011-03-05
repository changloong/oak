
module jade.Parser ;

import jade.Jade ;

struct Parser {
	
	string	filename;
	string	input ;
	Lexer	lexer ;
	
	void Init(string filename, string str){
		this.input	= str ;
		this.filename = filename;
		this.lexer.Init(str);
	}
	
	Tok* peek(){
        	return this.lexer.lookahead(1);
	}
	
	Node* parser(){
		Node* block = Node.New!(Node.Type.Block) ;
		block.ln = this.lexer.ln ;
		
		while ( !this.peek.isEos ) {
			if (this.peek.isNewline ) {
				this.lexer.advance;
			} else {
				Node* node	= this.parseExpr() ;
				if( node is null ){
					break;
				}
				block.block.push(node);
			}
		}
		return block;
	}
	
	Tok* expect(Tok.Type tp){
		if (this.peek.tp is tp) {
			return this.lexer.advance;
		} else {
			throw new Exception( std.string.format("expected %s, but got %s on line:%d",  Tok.type(tp), this.peek.type,  this.filename, this.lexer.ln ));
		}
		return null ;
	}
	
	Tok* accept(Tok.Type tp){
		if (this.peek.tp is tp) {
			return this.lexer.advance;
		}
		return null ;
	}
	
	Node* parseExpr() {
		switch(this.peek.tp){
			case Tok.Type.Tag :
				return this.parseTag();
			case Tok.Type.DocType :
				return this.parseDocType();
			case Tok.Type.Filter :
				return this.parseFilter();
			case Tok.Type.Comment :
				return this.parseComment();
			case Tok.Type.Text :
				return this.parseText();
			case Tok.Type.Each :
				return this.parseEach();
			case Tok.Type.Code :
				return this.parseCode();
			case Tok.Type.Id :
			case Tok.Type.Class :
				Tok* tok = this.lexer.advance ;
                		this.lexer.defer(this.lexer.token( Tok.Type.Tag , `div` ));
				this.lexer.defer(tok);
				return this.parseExpr();
			default:
				
				throw new Exception(  std.string.format("unexpected tok %s , on file:%s, line:%d \n%s", this.peek.type,  this.filename, this.peek.ln, this.input) );
		}
		return null ;
	}
	
	Node* parseText(){
		Tok* tok = this.expect(Tok.Type.Text);
		Node* node  = Node.New!(Node.Type.Text);
		node.val	= tok.val ;
		return node ;
	}
	
	Node* parseCode(){
		Tok* tok = this.expect(Tok.Type.Code);
		Node* node  = Node.New!(Node.Type.Code);
		node.val = tok.val ;
		
		node.escape = tok.escape ;
		node.code.isVar = tok.isVar;
		
		node.ln = this.lexer.ln;
		if ( this.peek.isIndent) {
            		node.code.block	= this.parseBlock() ;
		}
		return node ;
	}
	Node* parseComment(){
		Tok* tok	= this.expect(Tok.Type.Comment);
		Node* node	= Node.New!(Node.Type.Comment);
		node.val	= tok.val ;
		
		node.ln	= this.lexer.ln;
		return node ;
	}
	Node* parseDocType(){
		Tok* tok	= this.expect(Tok.Type.DocType);
		Node* node	= Node.New!(Node.Type.DocType);
		node.val	= tok.val ;
		node.ln = this.lexer.ln;
		return node ;
	}
	
	Node* parseFilter(){
		Tok* tok	= this.expect(Tok.Type.Filter);
		Tok* attrs	= this.expect(Tok.Type.Attrs);
		Node* block;
		if (this.lexer.lookahead(2).isText) {
			block = this.parseTextBlock();
		} else {
			block = this.parseBlock();
		}
		Node* node	= Node.New!(Node.Type.Filter);
		node.val	= tok.val ;
		node.ln 	= this.lexer.ln;
		node.filter.block	= block ;
		node.filter.attrs	= attrs ;
		node.ln = this.lexer.ln;
		return node ;
	}
	
	Node* parseEach(){
		
		Tok* tok	= this.expect(Tok.Type.Each);
		Node* node	= Node.New!(Node.Type.Each);
		
		node.each.obj	= tok.code ;
		node.val	= tok.val ;
		
		node.each.key	= tok.key ;
		
		node.each.block	= this.parseBlock();
		
		node.ln = this.lexer.ln;
		return node ;
	}
	
	Node* parseTextBlock(){
		Node* text	= Node.New!(Node.Type.Text);
		text.ln = this.lexer.ln;
		this.expect(Tok.Type.Indent);
		
		while (this.peek.isText || this.peek.isNewline) {
			if( this.peek.isNewline ) {
				this.lexer.advance;
			} else {
				text.text.push(this.lexer.advance.val);
			}
		}
		this.expect(Tok.Type.Outdent);
		return text ;
	}
	
	Node* parseBlock(){
		Node* node ;
		Node* block	= Node.New!(Node.Type.Block);
		block.ln = this.lexer.ln;
		this.expect(Tok.Type.Indent);
		while ( !this.peek.isOutdent ) {
			if( this.peek.isNewline ) {
				this.lexer.advance;
			} else {
				block.block.push(this.parseExpr());
			}
		}
		this.expect(Tok.Type.Outdent);
		return block ;
	}
	
	
	Node* parseTag(){
		string name = this.lexer.advance.val ;
		Node* tag = Node.New!(Node.Type.Tag);
		tag.tag.name	= name ;
		tag.ln = this.lexer.ln;
		
		// (attrs | class | id)*
		Lout:
		while (true) {
			switch (this.peek.tp) {
			    case Tok.Type.Id :
			    case Tok.Type.Class :
				Tok* tok = this.lexer.advance;
				//tag.setAttribute(tok.type, "'" + tok.val + "'");
			    	tag.tag.attrs.add( tok ) ;
				continue;
			    case Tok.Type.Attrs:
				Tok*  attrs = this.lexer.advance ;
			    	tag.tag.attrs.copy( &attrs.attrs );
			    	/*
				    names = Object.keys(obj);
					for (var i = 0, len = names.length; i < len; ++i) {
					    var name = names[i],
						val = obj[name];
					    tag.setAttribute(name, val);
					}
			    	*/
				continue;
			    default:
				break Lout;
			}
		}
		
		// (text | code)?
		switch (this.peek.tp) {
		    case  Tok.Type.Text:
			tag.tag.text = this.parseText();
			break;
		    case Tok.Type.Code:
			tag.tag.code = this.parseCode();
			break;
		    default:
			break;
       		}
		
		// newline*
       		while (this.peek.isNewline){
			this.lexer.advance;
		}
		
		// Assume newline when tag followed by text
		if (this.peek.isText) {
		  	if (tag.tag.text is null){
				tag.tag.text = Node.New!(Node.Type.Text);
			}
			tag.tag.text.text.push(`\n`);
		}
		
		// block?
		if (this.peek.isIndent) {
			Node* block = this.parseBlock() ;
			if (tag.tag.block is null) {
				tag.tag.block = block ;	 
			} else {
				for (int i = 0, len = block.block.list.length; i < len; ++i) {
					tag.tag.block.block.push(block.block.list[i]);
				}
			}
		}
		return tag ;
	}
	
}