
module jade.test ;

version(JADE_TEST) :

import jade.Jade ;

void main(){
	string file = `example.jade`;
	auto data = cast(string) std.file.read(file);
	
	StopWatch sw;
	sw.start;
	scope(exit){
		sw.stop;
		log(" use time=", sw.peek.msecs, "ms" );
	}
	
	Compiler compiler;
	compiler.Init(file, data );
	compiler.compile ;
	
	log("result:\n", compiler.js ) ;
	
}