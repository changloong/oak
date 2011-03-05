
module jade.Node ;

import jade.Jade ;

package import 
	jade.node.Attrs,
	jade.node.Block ,
	jade.node.Code ,
	jade.node.Comment ,
	jade.node.DocType ,
	jade.node.Each ,
	jade.node.Filter ,
	jade.node.Tag ,
	jade.node.Text ;

private enum NodeType {
	None ,
	// Attrs ,
	Block ,
	Code ,
	Comment ,
	DocType ,
	Each ,
	Filter ,
	Tag ,
	Text ,
}

struct Node {
	alias jade.Node.Node This;
	public alias NodeType Type;
	

	Type	tp = Type.None ;
	string	val ;
	bool	escape ;
	size_t	ln ;
	
	
	static const nodes_offset = jade.Node.Node.ln.offsetof + ln.sizeof ;

	union {
		// Attrs		attrs ;
		Block		block ;
		Code		code ;
		Comment		comment ;
		DocType		doctype ;
		Each		each ;
		Filter		filter ;
		Tag		tag ;
		Text		text ;
	}
	
	bool isNone(){
		return tp is Type.None ;
	}
	//bool isAttrs(){return tp is Type.Attrs ;}
	bool isBlock(){
		return tp is Type.Block ;
	}
	bool isCode(){
		return tp is Type.Code ;
	}
	bool isComment(){
		return tp is Type.Comment ;
	}
	bool isDocType(){
		return tp is Type.DocType ;
	}
	bool isEach(){
		return tp is Type.Each ;
	}
	bool isFilter(){
		return tp is Type.Filter ;
	}
	bool isTag(){
		return tp is Type.Tag ;
	}
	bool isText(){
		return tp is Type.Text ;
	}
	
	string type(){
		static const members = EnumNames!(Node.Type)  ;
		return members[tp];
	}
	
	template Child(T) if(is(T==struct)) {
		alias T	This ;
		
		Node* parent(){
			void*	_parent	= (cast(void*) &this) - Node.nodes_offset ;
			return cast(Node*) _parent ;
		}
		
	}
	
	static Node* New(Type tp)(){
		Node*	node = new Node;
		node.tp	= tp ;
		return node ;
	}
	
}



