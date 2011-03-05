
module jade.node.Comment;

import jade.Jade ;

struct Comment {
	mixin Node.Child!(typeof(this)) node ;
}