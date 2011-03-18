
module oak.fcgi.all ;

public import 
	oak.fcgi.VHost ,
	oak.fcgi.Response ,
	oak.fcgi.Request ,
	oak.fcgi.Dispatch ,
	oak.fcgi.Base ,
	oak.fcgi.Application ;

public import 
	oak.fcgi.http.Session ,
	oak.fcgi.http.Cookie ,
	oak.fcgi.http.Header ;

public import 
	oak.util.Log ,
	oak.util.Pool ,
	oak.util.Ctfe ,
	oak.util.Buffer ;


package import 
	core.thread  ,
	core.memory ,
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
