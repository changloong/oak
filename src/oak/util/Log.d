module oak.util.Log ;


import std.stdio ;

class LogSyncClass{}
	
public void Log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	synchronized(LogSyncClass.classinfo){
		std.stdio.write(file, ":", line, " ");
		std.stdio.writefln(t);
	}
}

	
public void log( string file= __FILE__, int line = __LINE__, T...)(T t){//
	synchronized(LogSyncClass.classinfo){
		// std.stdio.write(file, ":", line, " ");
		std.stdio.writefln(t);
	}
}