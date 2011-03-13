module oak.fcgi.Request ;

import oak.fcgi.all ;

class FCGI_Request {
	public ptrdiff_t 	exitStatus;
	public HTTP_Header 	header ;
	
	private {
		ptrdiff_t	_thread_id = -1 ;
		ptrdiff_t	_id 	= -1 ;
		FCGI_Stream	_stream ;
		bool		_withExceptions ;
		bool		_keepAlive ;
		ubyte		_role ;
		FCGI_Buffer	_stdout, _stderr , _stdin, _data , _out_bu ;
		FCGI_Buffer[11]	_stream_map ;
	}
	
	
	this(bool withExceptions, ptrdiff_t thread_id) {
		_thread_id	= thread_id ;
		_withExceptions	= withExceptions;
		
		_stream	= new FCGI_Stream ;
		
		_stdout	= new FCGI_Buffer( 1024 * 32 , 1024 * 256 );
		_stderr	= new FCGI_Buffer( 1024 , 1024 * 16 );
		_stdin	= new FCGI_Buffer( 1024 , 1024 * 16 );
		_data	= new FCGI_Buffer( 0 , 1024 ) ;
		_out_bu	= new FCGI_Buffer( 1024 * 32 , 1024 * 256);
		
		_stream_map[FCGI_STDIN]		= _stdin ;
		_stream_map[FCGI_STDOUT]	= _stdout ;
		_stream_map[FCGI_STDERR]	= _stderr ;
		_stream_map[FCGI_DATA]		= _data ;
		
		exitStatus = 0;
       		_id	= -1;
		_role	= 0; //FastCGIRole.UnknownRole
	}
	
	public bool accept (fd_type fd) {
		if (!isFinished ())
			finish ();
		assert(fd>0);
		_stream.init(fd);
		
		_role = FCGI_RESPONDER; ;
		
		_stdout.clear ;
		_stderr.clear ;
		_stdin.clear ;
		_data.clear ;
		_out_bu.clear ;
		
		FCGI_Header fcgi_header ;
		do {
			readRecord(&fcgi_header);
		} while( !(fcgi_header.recordType_ is FCGI_STDIN || fcgi_header.recordType_ is FCGI_DATA) ) ;
		if( _stream_map[fcgi_header.recordType_] is null ) {
			log(" header.type = %d", fcgi_header.recordType_);
			throw new FCGI_ProtocolException ("FastCGI protocol error: expect STDIN or DATA stream ");
		}
		
		if( fcgi_header.contentLength_ > 0 ) {
			int len = fcgi_header.contentLength_ ;
			_stream_map[fcgi_header.recordType_].move(len) ;
			ubyte[] _tmp_buffer = cast(ubyte[]) _stream_map[fcgi_header.recordType_].slice ;
			_stream.readExact(_tmp_buffer.ptr, _tmp_buffer.length);
		}
		
		return true ;
	}
	
	ptrdiff_t thread_id(){
		return _thread_id ;
	}
	
	public bool isFinished() {
		 return _id < 0;
	}
	
	public void finish() {
		// eof records
            	if ( _stdout.length ) {
               	 	writeRecord (FCGI_STDOUT, _stdout.slice.ptr , _stdout.length);
            		writeRecord (FCGI_STDOUT, null, 0);
		}
            	if ( _stderr.length ) {
               	 	writeRecord (FCGI_STDERR, _stderr.slice.ptr , _stderr.length);
               	 	writeRecord (FCGI_STDERR, null , 0);
		}
		
		FCGI_EndRequestBody content;
		content.appStatus1 = (exitStatus >> 24) & 0xff;
		content.appStatus2 = (exitStatus >> 16) & 0xff;
		content.appStatus3 = (exitStatus >> 8) & 0xff;
		content.appStatus4 = (exitStatus) & 0xff;
		content.protocolStatus = FCGI_REQUEST_COMPLETE ;
		content.reserved[0] = 0;
		content.reserved[1] = 0;
		content.reserved[2] = 0;
		writeRecord (FCGI_END_REQUEST, &content, content.sizeof);
		
		if( _out_bu.length ) {
			_stream.writeExact( cast(const void*) &_out_bu.slice[0] , _out_bu.length);
		}
		_out_bu.clear ;
		// close connection
		if (!_keepAlive) {
			_stream.close ;
		}  else {
			log("keep alive");
		}
		
		_stream.finish ;
		_stdout.clear ;
		_stderr.clear ;
		_stdin.clear ;
		_data.clear ;
		
		_id	= -1 ;
		exitStatus = 0;
		_id	= -1;
         	_role	= 0; //FastCGIRole.UnknownRole
		header.reset ;
		
		//arguments_	= arguments_.init;
	}
	
	public bool isClosed(){
		return _stream.isClosed ;
	}
	
	public FCGI_Buffer stdout(T...)(T t){
		foreach(_t;t){
			_stdout(_t);
		}
		return  _stdout;
	}
	public FCGI_Buffer stdin(T...)(T t){
		foreach(_t;t){
			_stdin(_t);
		}
		return _stdin ;
	}
	public FCGI_Buffer stderr(T...)(T t){
		foreach(_t;t){
			_stderr(_t);
		}
		return _stderr;
	}
	public FCGI_Buffer data(T...)(T t){
		foreach(_t;t){
			_data(_t);
		}
		return _data;
	}

	final private void writeRecord (byte type, void* data, size_t size)
	{
		ptrdiff_t len ;
		
		FCGI_Header header;
		
		ubyte[ubyte.max] _padding_tmp ;
		
		while( size > 0 ) {
			
			// fill header
			header.version_ 	= FCGI_VERSION_1;
			header.recordType_ 	= type;
			header.reqID1		= (_id >> 8) & 0xff;
			header.reqID2		= (_id) & 0xff;
			
			len	= size > ushort.max ? ushort.max : size ;
			
			// calc padding
			ptrdiff_t padding = 8 - (len & 7);
			if (padding is 8)
				padding = 0;

			header.contentLength1 = (len >> 8) & 0xff;
			header.contentLength2 = (len) & 0xff;
			header.paddingLength_	= cast( byte ) padding;
			header.reserved		= 0;
			
			// copy header
			_out_bu((cast(char*) &header)[0 .. header.sizeof]);
			// copy data
			_out_bu( data[0 .. len] );
			// pad with zeros
			if( padding > 0 ) {
				_out_bu( _padding_tmp[0 .. padding] );	
			}
			
			size	-= len ;
			data	+= len ;
			
		}
		assert(size is 0);
	}
    
	final private void readRecord (FCGI_Header* fcgi_header){
		read_FCGI_Header(_stream, fcgi_header);
		// log("readRecord , type=%d contentLength=%d, paddingLength=%d , requestID_=%d", fcgi_header.recordType_, fcgi_header.contentLength_ ,  fcgi_header.paddingLength_, fcgi_header.requestID_);
		if ( fcgi_header.version_ !is FCGI_VERSION_1 ) {
			//log(" fcgi_header.version_=%d",  fcgi_header.version_);
			//log(" FCGI_Header = %s",  cast(ubyte[]) _stream._bu.slice[0..FCGI_Header.sizeof] );
			throw new FCGI_ProtocolException ("Unsupported FastCGI version");
		}
		
		ubyte[256] _padding_tmp ;
		switch (fcgi_header.recordType_) {
			case FCGI_BEGIN_REQUEST :
					if (fcgi_header.requestID_ is 0) {
                				throw new FCGI_ProtocolException ("FastCGI protocol error: BeginRecord.requestID was 0");
					}
					if( fcgi_header.contentLength_ !is FCGI_BeginRequestBody.sizeof ) {
						 throw new FCGI_ProtocolException ("FastCGI protocol error: Content length mismatch");
					}
          				if (_id >= 0) {
                				throw new FCGI_ProtocolException ("FastCGI protocol error: Multiplexed connections are not implemented - please report this bug!");
					}
					_id = fcgi_header.requestID_ ;
					FCGI_BeginRequestBody req_body ;
					
					read_FCGI_BeginRequestBody(_stream, &req_body);
					
            				_keepAlive = ( req_body.flags & FCGI_KEEP_CONN ) !is 0;
           				if ( fcgi_header.paddingLength_ >0 ) {
						_stream.readExact(_padding_tmp.ptr, fcgi_header.paddingLength_ );
					}
					
				break ;
			case FCGI_ABORT_REQUEST :
					if (_withExceptions) 
						throw new FCGI_AbortException ();
				break ;
			
			case FCGI_GET_VALUES:
					if (fcgi_header.contentLength_ is 0)
						return ;
					
					int nameLength	= readVariableLength (_stream);
					int valueLength	= readVariableLength (_stream);
					string name	= _stream.read_string( nameLength) ;
					string value	= _stream.read_string( valueLength) ;
					
					
					if ( fcgi_header.paddingLength_ >0 ) {
						_stream.readExact(_padding_tmp.ptr, fcgi_header.paddingLength_ );
					}
					
					string answer = "";
					if ( name == FCGI_MAX_CONNS )
						answer = "100";
					else if (name == FCGI_MAX_REQS )
						answer = "100";
					else if (name == FCGI_MPXS_CONNS )
						answer = "0";
					
					log(":`%s` => `%s` ", name, answer);
					
					// create name/value pair
					ubyte[1024] _answer_tmp ;
					ubyte* _answer_bu	= _answer_tmp.ptr ;
					size_t _answer_size	= _answer_tmp.length ;
					size_t _answer_ret	= 0;
					
					_answer_ret	= writeVariableLength(_answer_bu, _answer_size, name);
					assert(_answer_ret < _answer_size );
					_answer_bu	+= _answer_ret ;
					_answer_size	-= _answer_ret ;
					assert( _answer_size < _answer_tmp.length );
					
					_answer_ret	= writeVariableLength(_answer_bu, _answer_size, answer);
					assert(_answer_ret < _answer_size );
					_answer_bu	+= _answer_ret ;
					_answer_size	-= _answer_ret ;
					assert( _answer_size < _answer_tmp.length );
					
					ubyte[] _buffer = _answer_tmp[ 0 .. $ - _answer_size] ;
					// send it
					writeRecord (FCGI_GET_VALUES, _buffer.ptr, _buffer.length);
					
				break ;
			
			case FCGI_PARAMS:
					// empty one
            				if (fcgi_header.contentLength_ is 0) {
                				return ;
					}
					int toRead = fcgi_header.contentLength_ - fcgi_header.paddingLength_ ;
					int _toRead = toRead ;
					
					while (toRead > 0) {
						int nameLen	= readVariableLength (_stream);
						int valueLen	= readVariableLength (_stream);
						string name	= _stream.read_string(nameLen) ;
						string value	= _stream.read_string(valueLen) ;
						assert(name.length is nameLen);
						assert(value.length is valueLen);
						// log("name=%d:`%s`, value=%d:`%s`",  nameLen, name, valueLen, value);
						header.add(name, value);
						toRead -= (nameLen < 128 ? nameLen+1 : nameLen+4) + (valueLen < 128 ? valueLen+1 : valueLen+4) ;
						
					}
					
           				if ( fcgi_header.paddingLength_ >0 ) {
						_stream.readExact(_padding_tmp.ptr, fcgi_header.paddingLength_ );
					}
					
					if (toRead != 0) {
						log("fcgi_header.contentLength_=%d, fcgi_header.paddingLength_=%d, toRead=%d, _toRead=%d",  fcgi_header.contentLength_, fcgi_header.paddingLength_, toRead,_toRead);
               					throw new FCGI_ProtocolException ("FastCGI protocol error: Receiving multiple name/value pairs in one record is not implemented");
					}
				break ;
			case FCGI_STDIN:
			case  FCGI_DATA:
				// do nothing here
				break;

			default:
				throw new FCGI_ProtocolException ("FastCGI protocol error: Unknown record type");
		}
	}
	
}

private {
	
	static int readVariableLength (FCGI_Stream stream)
	{
		ubyte a;
		stream.read(a);
		if ( a  < 128 ) {
			return a;
		}
		ubyte b,c,d;
		stream.read(b);
		stream.read(c);
		stream.read(d);
		return ((a & 0x7f) << 24) | (b << 16) | (c << 8) | (d);
	}

	
	static size_t writeVariableLength (ubyte* buffer, size_t size, string text)
	{
		size_t _ret ;
		if (text.length < 128 ) {
			_ret	= text.length + 1 ;
			assert( size > _ret );
			buffer[0]	= cast(ubyte)  text.length ;
			buffer[1 .. _ret] = cast(ubyte[]) text;
		}  else  {
			ptrdiff_t len = text.length;
			_ret	=  len+4 ;
			assert( size > _ret );
			buffer[0] = 0xff & ((len >> 24) | 0x80);
			buffer[1] = 0xff & (len >> 16);
			buffer[2] = 0xff & (len >> 8);
			buffer[3] = 0xff & (len);
			buffer[4 .. _ret] = cast(ubyte[]) text;
		}
		return _ret ;
	}
	

	static void read_FCGI_Header(FCGI_Stream stream, FCGI_Header* _this) {
		ubyte a,b;
		// version
		stream.read (_this.version_);
		// recordType
		stream.read (_this.recordType_);
		// requestID
		stream.read (a);
		stream.read (b);
		_this.requestID_ = a << 8 | b;
		// contentLength
		stream.read (a);
		stream.read (b);
		_this.contentLength_ = a << 8 | b;
		// paddingLength
		stream.read (_this.paddingLength_);
		// reserved
		stream.read (a);
	}
	
	static void read_FCGI_BeginRequestBody(FCGI_Stream stream, FCGI_BeginRequestBody* _this){
		byte a,b;

		stream.read (a);
		stream.read (b);
		_this.role_	=   cast(typeof(_this.role_)) ((a << 8) | b);

		stream.read ( _this.flags );

		//input.buffer.skip(5);
		ubyte[5] data;
		stream.readExact(data.ptr, data.length);
    	}
	
}

struct HTTP_Header {
	string	SERVER_SOFTWARE;
	string	SERVER_NAME;
	string	GATEWAY_INTERFACE;
	string	SERVER_PORT;
	string	SERVER_ADDR;
	string	REMOTE_PORT;
	string	REMOTE_ADDR;
	
	string	SCRIPT_NAME;
	string	PATH_INFO;
	string	SCRIPT_FILENAME;
	
	string	DOCUMENT_ROOT;
	string	DOCUMENT_URI;
	
	string	REQUEST_URI;
	string	QUERY_STRING;
	string	REQUEST_METHOD;
	string	REDIRECT_STATUS;
	string	SERVER_PROTOCOL;
	
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
	string	HTTP_X_INSIGHT ;
	string	HTTP_CACHE_CONTROL ;
	string	HTTP_REFERER ;
	string	HTTP_COOKIE ;
	
	void reset(){
		foreach( int i , _field; this.tupleof ) {
			static if( isSomeString!(typeof(this.tupleof[i]) ) ){
				this.tupleof[i]	= null ;
			} else {
				static assert(false) ;
			}
		}
	}
	
	void add(string name, string value){
		foreach( int i , _field; this.tupleof ) {
			const _name = HTTP_Header.tupleof[i].stringof[ HTTP_Header.stringof.length + 3 .. $];
			if( _name == name ) {
				this.tupleof[i]	= value ;
				return ;
			}
		}
		
		log(" `%s` => `%s` ", name, value);
	}
	
	string key(uint i)(){
		return HTTP_Header.tupleof[i].stringof[ HTTP_Header.stringof.length + 3 .. $];
	}
	
	int opApply(scope int delegate(ref string, ref string) dg){
		int result;
		foreach( int i , _field; this.tupleof ) {
			const _name = HTTP_Header.tupleof[i].stringof[ HTTP_Header.stringof.length + 3 .. $];
			result	= dg(_name, this.tupleof[i] ) ;
			if( result ) {
				goto L2 ;
			}
		}
		L2:
		return result;
	}
}
