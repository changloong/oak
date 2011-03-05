module fcgi4d.Connection ;

import fcgi4d.all ;
import fcgi4d.Protocol ;

import  std.c.stdlib;
import  std.c.string;

shared class FCGI_Connection {
	enum State {
		isFastCGI,
		isCGIBeforeRequest ,
		isCGIAfterRequest ,
	}
	private	fd_type	_fd ;
	private	string		_validIP ;
	private	State 	_state ;
	
	public this (fd_type fd = 0 /* FCGI_LISTENSOCK_FILENO */ ) {
		OS_LibInit (null);
		_fd 		= fd;
		char* p 	= std.c.stdlib.getenv("FCGI_WEB_SERVER_ADDRS\0".ptr ) ;
		_validIP	= p is null ? null : p[0 .. strlen(p)+1].idup;
		_state 	= OS_IsFcgi (fd) is 0 ? State.isCGIBeforeRequest : State.isFastCGI ;
	}
	
	public this (string host, string port, string validIP = null, int backlog = 10){
		OS_LibInit (null);
		_validIP	= validIP is  null ? null : validIP ~ '\0' ;
		string path	= host ~ ":" ~ port ~ "\0";
		_fd		= OS_CreateLocalIpcFd (path.ptr, backlog);
		_state	= State.isFastCGI ;
	}
	
	public bool isCGI (){
        	return _state != State.isFastCGI ;
	}
	
	public fd_type accept (){
		if ( _state is State.isFastCGI){
			// FastCGI accept
			fd_type result	= OS_Accept (_fd, false, _validIP.ptr) ;
			// log("fd = %d	result=%d", _fd, result);
			return result;
		} else if (_state is  State.isCGIBeforeRequest) {
			// first CGI accept
			_state	= State.isCGIAfterRequest ;
			return _fd ;
		} else {
			// later CGI accept
			return -2;
		}
	}
}