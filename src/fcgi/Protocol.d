module fcgi4d.Protocol ;

import fcgi4d.all ;


enum {
	FCGI_LISTENSOCK_FILENO	= 0 ,
	FCGI_MAX_LENGTH	= 0xffff ,
	FCGI_HEADER_LEN = 8 ,
	FCGI_VERSION_1	= 1 ,
	FCGI_NULL_REQUEST_ID	= 0 ,
	FCGI_KEEP_CONN = 1 ,
}

enum : ubyte {
	FCGI_BEGIN_REQUEST       =1 ,
	FCGI_ABORT_REQUEST       =2 ,
	FCGI_END_REQUEST         =3 ,
	FCGI_PARAMS              =4 ,
	FCGI_STDIN               =5 ,
	FCGI_STDOUT              =6 ,
	FCGI_STDERR              =7 ,
	FCGI_DATA               =8 ,
	FCGI_GET_VALUES         =9 ,
	FCGI_GET_VALUES_RESULT  =10 ,
	FCGI_UNKNOWN_TYPE       =11 ,
	FCGI_MAXTYPE  = FCGI_UNKNOWN_TYPE ,
}

enum {
	FCGI_RESPONDER  = 1 ,
	FCGI_AUTHORIZER = 2 ,
	FCGI_FILTER     = 3 ,
}

enum {
	FCGI_REQUEST_COMPLETE = 0,
	FCGI_CANT_MPX_CONN    = 1,
	FCGI_OVERLOADED       = 2,
	FCGI_UNKNOWN_ROLE     = 3,
}

enum : string {
	FCGI_MAX_CONNS  = "FCGI_MAX_CONNS" ,
	FCGI_MAX_REQS	= "FCGI_MAX_REQS" ,
	FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS" ,
}

struct FCGI_Header {
	/*
	ubyte	_version;
	ubyte	type;
	ubyte	requestIdB1;
	ubyte	requestIdB0;
	ubyte	contentLengthB1;
	ubyte	contentLengthB0;
	ubyte	paddingLength;
	ubyte	reserved;
	*/
	byte 	version_;
	byte	recordType_;
	union {
		short	requestID_;
		struct{
			byte	reqID1;
			byte	reqID2;
		}
	}
	union{
		short	contentLength_;
		struct {
			byte contentLength1 ;
			byte contentLength2 ;
		}
	}
	byte	paddingLength_;
	byte	reserved ;
}
static assert( FCGI_HEADER_LEN is FCGI_Header.sizeof );

struct FCGI_BeginRequestBody {
	ubyte		roleB1;
	ubyte		roleB0;
	ubyte		flags;
	ubyte[5]	reserved;
	
	alias roleB1 	role_ ;
}

struct FCGI_BeginRequestRecord {
    FCGI_Header	_header;
    FCGI_BeginRequestBody _body;
}
static assert(FCGI_BeginRequestRecord.sizeof is 16);

struct FCGI_EndRequestBody {
	/*
	ubyte	appStatusB3;
	ubyte	appStatusB2;
	ubyte	appStatusB1;
	ubyte	appStatusB0;
	ubyte	protocolStatus;
	ubyte[3]	reserved;
	*/
	byte appStatus1;
	byte appStatus2;
	byte appStatus3;
	byte appStatus4;
	byte protocolStatus;
	byte[3] reserved;
}

struct FCGI_EndRequestRecord {
    FCGI_Header	_header;
    FCGI_EndRequestBody	_body;
}

static assert(FCGI_EndRequestRecord.sizeof is 16);

struct FCGI_UnknownTypeBody {
    ubyte	type;    
    ubyte[7]	reserved;
}

struct FCGI_UnknownTypeRecord {
    FCGI_Header	_header;
    FCGI_UnknownTypeBody _body;
}
static assert(FCGI_UnknownTypeRecord.sizeof is 16);
