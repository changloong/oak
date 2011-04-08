
module oak.langs.jade.test ;

version(JADE_TEST) :

import oak.langs.jade.Jade ;

void main(string[] args ){
	string file = `example.jade`;
	auto data = cast(string) std.file.read(file);
	
	ptrdiff_t count = 1 ;
        if( args.length > 1 ) {
                count = ctfe_a2i( args[1] );
        }

	StopWatch sw;
	sw.start;

	Compiler cc ;
	string code ;
	for(ptrdiff_t i =0 ; i < count ; i++) {
		cc.Init(file, data) ;
		code	= cc.compile ;
	}
	
	sw.stop;
	writefln("%d times use time = %dms \n", count, sw.peek.msecs );

	writefln(code);
}
