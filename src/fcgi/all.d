module fcgi4d.all ;

public import 
	
	fcgi4d.Stream ,
	fcgi4d.Protocol , 
	fcgi4d.Request ,
	fcgi4d.Exception ,
	fcgi4d.Connection ,
	fcgi4d.Buffer ,
	fcgi4d.Base ,
	fcgi4d.Application ;

	
package import 
	std.exception,
	std.stream,
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;

pragma(lib, "fcgi");
pragma(lib, "ws2_32");

class LogSyncClass{}
	
public void log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	synchronized(LogSyncClass.classinfo){
		std.stdio.write(file, ":", line, " ");
		std.stdio.writefln(t);
	}
}
