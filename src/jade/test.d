
module oak.jade.test ;

version(JADE_TEST) :

import oak.jade.Jade ;


void main(string[] args ){
	string file = `example.jade`;
	auto data = cast(string) std.file.read(file);
	
	int count = 1 ;
        if( args.length > 1 ) {
                count = ctfe_a2i( args[1] );
        }

	StopWatch sw;
	sw.start;
	scope(exit){
		sw.stop;
		writefln("%d times use time = %dms", count, sw.peek.msecs );
	}
	
	Compiler cc ;
	
	for(int i =0 ; i < count ; i++) {
		cc.Init(file, data) ;
		auto code	= cc.compile ;
		if( i is 0  ){
			// writefln(code);
			// cc.parser.dump_tok ;
		}
	}
	
}
