
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
		Log(" use time = %dms", sw.peek.msecs );
	}
	
	Compiler cc ;
	
	
	for(int i =0 ; i < 1 ; i++) {
		cc.Init(file, data) ;
		cc.compile ;
	}
	
}