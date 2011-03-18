module oak.fcgi.all ;

public import 
	oak.fcgi.Stream ,
	oak.fcgi.Protocol , 
	oak.fcgi.Request ,
	oak.fcgi.Exception ,
	oak.fcgi.Connection ,
	oak.fcgi.Base ,
	oak.fcgi.Application ;

	
package import 
	std.exception,
	std.stream,
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;

package import 
	oak.util.Ctfe , 
	oak.util.Buffer ;

pragma(lib, "fcgi");
version(Windows) pragma(lib, "ws2_32");

package alias vBuffer FCGI_Buffer ;
class LogSyncClass{}
	
public void log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	synchronized(LogSyncClass.classinfo){
		std.stdio.write(file, ":", line, " ");
		std.stdio.writefln(t);
	}
}
