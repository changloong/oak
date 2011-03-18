
module oak.fcgi.all ;

public import 
	oak.fcgi.Response ,
	oak.fcgi.Request ,
	oak.fcgi.Application ,
	oak.fcgi.Base ;

public import 
	oak.util.Log ,
	oak.util.Pool ,
	oak.util.Ctfe ,
	oak.util.Buffer ;

package import 
	core.thread  ,
	std.exception,
	std.stream,
	std.datetime,
	std.conv,
	std.array,
	std.string,
	std.traits,
	std.stdio;

pragma(lib, "fcgi") ;
version(Windows) pragma(lib, "ws2_32");
