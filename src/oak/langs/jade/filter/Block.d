
module oak.langs.jade.filter.Block ;

import oak.langs.jade.Jade ;



alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Block_Filter(Compiler* cc, Filter node) {
	assert(cc.parser.use_extend is false);
	// find from_node with same filter;
	Compiler* _cc 	= cc ;
	Filter	_node	= node ;
	if( cc.from_compiler !is null ) {
		Find_From_Filter(cc.from_compiler, _cc, _node);
	}
	assert(_node !is null );
	assert(_cc !is null );
	
	cc.asCode("// <block.").asCode(node.filter_name).asCode(">\n");
	cc.asLine(node.ln);
	if( _cc !is cc ) {
		_cc.asLine(_node.ln);
	}
	_node.eachD(_cc);
	_cc.FinishLastOut();
	cc.asCode("// </block.").asCode(node.filter_name).asCode("> ");
	cc.asCode(" file:").asCode( _cc.filename).asCode(" line:").asCode(_node.ln);
	if( _cc !is cc ) {
		cc.asCode(" file:").asCode( cc.filename).asCode(" line:").asCode( node.ln );
	}
	cc.asCode("\n");
}

private void Find_From_Filter(Compiler* cc, ref Compiler* _cc, ref Filter _node ){
	assert(_node.render_obj !is null);
	assert(_node.render_obj.isBlock() );
	auto _filter	= cc.parser.getFilter( _node.filter_name );
	if( _filter !is null ) {
		_node	= _filter ;
		_cc	= cc ;
	}
	if( cc.from_compiler !is null ) {
		Find_From_Filter( cc.from_compiler, _cc, _node );
	}
}

void Jade_Block_Parent_Filter(Compiler* cc, Filter node) {
	assert(node.render_obj.isBlock_Parent());
	assert(node.parent_filter !is null);
	assert(node.parent_filter.render_obj.isBlock());
	
	Compiler* _cc 	= cc ;
	Filter	_node	= node.parent_filter ;
	if( cc.parent_compiler !is null ) {
		Find_Parent_Filter(cc.parent_compiler, _cc, _node);
	}
	assert(_node !is null );
	assert(_cc !is null );
	if(   _cc is cc ){
		cc.err("missing @parent_block at %s:%d %s", cc.filename, node.ln );
	}
	
	
	cc.asCode("// <block_parent.").asCode(_node.filter_name).asCode(">\n");
	cc.asLine(node.ln);
	if( _cc !is cc ) {
		_cc.asLine(_node.ln);
	}
	_node.eachD(_cc);
	_cc.FinishLastOut();
	cc.asCode("// </block_parent.").asCode(_node.filter_name).asCode("> ");
	cc.asCode(" file:").asCode( _cc.filename).asCode(" line:").asCode(_node.ln);
	if( _cc !is cc ) {
		cc.asCode(" file:").asCode( cc.filename).asCode(" line:").asCode( node.ln );
	}
	cc.asCode("\n");
	
}


private void Find_Parent_Filter(Compiler* cc, ref Compiler* _cc, ref Filter _node ){
	assert(_node.render_obj !is null);
	assert(_node.render_obj.isBlock() );
	auto _filter	= cc.parser.getFilter( _node.filter_name );
	if( _filter !is null ) {
		_node	= _filter ;
		_cc	= cc ;
		return ;
	}
	if( cc.parent_compiler !is null ) {
		Find_Parent_Filter( cc.parent_compiler, _cc, _node );
	}
}
