
module oak.fcgi.http.Header ;

import oak.fcgi.all ;

struct FCGI_Header (bool IsRequest ) {
	
	alias typeof(this) This ;
	
	string	FCGI_ROLE ;
	string	REDIRECT_STATUS;
	string	GATEWAY_INTERFACE;
	
	string	REMOTE_ADDR;
	string	REMOTE_PORT;
	
	string	SERVER_SOFTWARE;
	string	SERVER_NAME;
	string	SERVER_PORT;
	string	SERVER_ADDR;
	string	SERVER_PROTOCOL;
	
	string	DOCUMENT_ROOT;
	string	DOCUMENT_URI;
	
	string	SCRIPT_NAME;
	string	SCRIPT_FILENAME;
	
	string	PATH_INFO;
	
	string	REQUEST_URI;
	string	REQUEST_METHOD;
	string	QUERY_STRING;
	
	string	CONTENT_TYPE ;
	string	CONTENT_LENGTH ;
	
	string	HTTP_HOST;
	string	HTTP_USER_AGENT;
	string	HTTP_ACCEPT ;
	string	HTTP_ACCEPT_LANGUAGE ;
	string	HTTP_ACCEPT_ENCODING ;
	string	HTTP_ACCEPT_CHARSET ;
	string	HTTP_KEEP_ALIVE ;
	string	HTTP_CONNECTION ;
	string	HTTP_CACHE_CONTROL ;
	string	HTTP_REFERER ;
	string	HTTP_COOKIE ;
	string	HTTP_PRAGMA ;
	string	HTTP_X_INSIGHT ;
	
	private ptrdiff_t[string] _keys_offset ;
	
	private {
		string[string]	_headers ;
	}
	
	void Reset() {
		foreach(uint i, c ; this.tupleof ) {
			static if( isSomeString!( typeof(c) ) ) {
				c = null ;
			}
		}
		_headers	= null ;
	}
	
	void Init(char** param, Pool* pool){
		while (*param !is null)
		{
			ptrdiff_t eq = 0;
			while ((*param)[eq] != '\0' && (*param)[eq] != '=') {
				eq++;
			}

			ptrdiff_t end = eq;
			while ((*param)[end] != '\0') {
				end++;
			}
			
			auto _key	= cast(string) pool.Copy( (*param)[0..eq] ) ;
			auto _value	=  cast(string) pool.Copy( (*param)[eq+1..end] ) ;
			
			add(_key, _value) ;
			
			param++;
		}
		_headers.rehash ;
	}
	
	package void add(string key, string value) {
		auto zpos	= key in _keys_offset ;
		if( zpos !is null ) {
			auto ret	=  cast(string*) (cast(ubyte*) &this + *zpos) ;
			*ret 	= value ;
		} else {
			Log("%s => %s ", key, value);
			_headers[key] = value ;
		}
	}
	
	string get(string key) {
		auto zval	= key in _headers ;
		if( zval !is null ) {
			return *zval;
		}
		auto zpos	= key in _keys_offset ;
		if( zpos !is null ) {
			auto ret	=  cast(string*) (cast(ubyte*) &this + *zpos) ;
			return   *ret ;
		}
		return null ;
	}
	
	void Boostrap(){
		foreach(uint i, c ; This.init.tupleof ){
			const name	= This.tupleof[i].stringof[ This.stringof.length + 3 .. $ ];
			static if( isSomeString!( typeof(c) ) ) {
				_keys_offset[ name ] = This.tupleof[i].offsetof ;
			}
		}
		_keys_offset.rehash ;
	}
	
	
	ptrdiff_t opApply(scope ptrdiff_t delegate(ref string, ref string) dg){
		ptrdiff_t result;
		foreach(uint i, c ; This.init.tupleof ){
			const name	= This.tupleof[i].stringof[ This.stringof.length + 3 .. $ ];
			static if( isSomeString!( typeof(c) ) ) {
				result	= dg(name, this.tupleof[i] ) ;
				if( result ) {
					goto L2 ;
				}
			}
		}
		foreach( string key, string value ; _headers ) {
			result	= dg(key, value ) ;
			if( result ) {
				goto L2 ;
			}
		}
		L2:
		return result;
	}
}

alias FCGI_Header!(true)	Req_Header ;


