
module oak.jade.filter.Css ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Css_Filter(Compiler* cc, Filter  node){
	cc.asString(`<style type="text/css">`);
	node.eachD(cc);
	cc.asString(`</style>`);
}