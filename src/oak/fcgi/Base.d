
module oak.fcgi.Base ;

alias ptrdiff_t fcgi_fd  , fcgi_int , fcgi_bool ;

import std.c.string ,  std.traits ,  std.conv ;

/**
 * Error Codes.
 *
 * Assigned to avoid conflict with EOF and errno(2).
 **/
enum  FCGX_ERROR : fcgi_int
{
	FCGX_UNSUPPORTED_VERSION	= -2,
	FCGX_PROTOCOL_ERROR		= -3,
	FCGX_PARAMS_ERROR		= -4,
	FCGX_CALL_SEQ_ERROR		= -5,
}

/**
 * Responder FCGX_Request.role
 *
 * A responder application is the most basic kind of FastCGI application: it
 * receives the information associated with an HTTP request and generates an
 * HTTP response. Responder is the role most similar to traditional CGI
 * programming, and most FastCGI applications are responders.
 **/
const fcgi_int FCGI_RESPONDER            = 1;

/**
 * Authorizer FCGX_Request.role
 *
 * An authorizer FastCGI application receives the information in an HTTP
 * request header and generates a decision whether to authorize the request.
 **/
const fcgi_int FCGI_AUTHORIZER           = 2;

/**
 * Filter FCGX_Request.role
 *
 * A filter FastCGI application receives the information associated with an
 * HTTP request, plus an extra stream of data from a file stored on the Web
 * server, and generates a "filtered" version of the data stream as an HTTP
 * response.
 **/
const fcgi_int FCGI_FILTER               = 3;

/**
 * FCGX_Request Flags
 *
 * Setting FCGI_FAIL_ACCEPT_ON_INTR prevents FCGX_Accept() from
 * restarting upon being interrupted.
 **/
const fcgi_int FCGI_FAIL_ACCEPT_ON_INTR  = 1;

/**
 * This structure defines the state of a FastCGI stream.
 *
 * Streams are modeled after the FILE type defined in stdio.h.
 * (We wouldn't need our own if platform vendors provided a
 * standard way to subclass theirs.)
 *
 * The state of a stream is private and should only be accessed
 * by the procedures defined below.
 **/
struct FCGX_Stream {
	/**
	 * reader: first valid byte
	 * writer: equals stop
	 **/
	private ubyte *rdNext;

	/**
	 * writer: first free byte
	 * reader: equals stop
	 **/
	private ubyte *wrNext;

	/**
	 * last valid byte + 1
	 * writer: last free byte + 1
	 **/
	private ubyte *stop;

	/**
	 * reader: first byte of current buffer fragment, for ungetc
	 * writer: undefined
	 **/
	private ubyte *stopUnget;

	private fcgi_int isReader;
	private fcgi_int isClosed;
	private fcgi_int wasFCloseCalled;
	private fcgi_int FCGI_errno;		/*!< error status */
	private void function(FCGX_Stream *stream) fillBuffProc;
	private void function(FCGX_Stream *stream, fcgi_int doClose) emptyBuffProc;
	private void* data;

    /**
     * Sets the exit status for stream's request.
     *
     * The exit status is the status code the request would have exited with, 
     * had the request been run as a CGI program.  You can call SetExitStatus
     * several times during a request; the last call before the request ends
     * determines the value.
     **/
    void status(fcgi_int s)
    {
        FCGX_SetExitStatus(s, &this);
    }

    /**
     * Reads a byte from the input stream and returns it.
     *
     * @return
     *	The byte
     * @return
     *	or EOF (-1) if the end of input has been reached.
     **/
    fcgi_int getc()
    {
        return FCGX_GetChar(&this);
    }

    /**
     * Pushes back the character c onto the input stream.
     *
     * One character of pushback is guaranteed once a character has been read.  No
     * pushback is possible for EOF.
     *
     * @return
     *	c if the pushback succeeded
     * @return
     *	EOF if not.
     **/
    fcgi_int ungetc(fcgi_int c)
    {
        return FCGX_UnGetChar(c, &this);
    }

    /**
     * Reads up to buf.length consecutive bytes from the input stream into the
     * buffer buf.
     *
     * Performs no interpretation of the input bytes.
     *
     * @return
     *  A slice of the input buffer.  If result is smaller than buf.length, the
     *  end of input has been reached.
     **/
    char[] getstr(char[] buf)
    {
        fcgi_int len = FCGX_GetStr(buf.ptr, buf.length, &this);
        return buf[0..len];
    }

    /**
     * Reads up to buf.length-1 consecutive bytes from the input stream into the
     * buffer.
     *
     * Stops before n-1 bytes have been read if '\\n' or EOF is read.  The
     * terminating '\\n' is copied to str.  After copying the last byte into str,
     * stores a '\\0' terminator.
     *
     * @return
     *	null if EOF is the first thing read from the input stream
     * @return
     *	str otherwise
     **/
    char[] getline(char[] buf)
    {
        char* rv = FCGX_GetLine(buf.ptr, buf.length, &this);

        if (rv is null)
            return null;

        assert(rv == buf.ptr);

        size_t i = 0;
        while (rv[i] != '\0')
            i++;

        return rv[0..i];
    }

    /**
     * Returns true if end-of-file has been detected while reading from stream;
     * otherwise returns false.
     *
     * Note that FCGX_HasSeenEOF(s) may return 0, yet an immediately following
     * FCGX_GetChar(s) may return EOF.  This function, like the standard C stdio
     * function feof, does not provide the ability to peek ahead.
     *
     * @return
     *	true if end-of-file has been detected, false if not.
     **/
    bool eof()
    {
        return FCGX_HasSeenEOF(&this) !is 0;
    }

    /**
     * Writes a byte to the output stream.
     *
     * @return
     *	false if an error occurred.
     **/
    bool putc(char c)
    {
        return FCGX_PutChar(c, &this) is c;
    }

    /**
     * Writes buffer into the output stream.
     *
     * Performs no interpretation of the output bytes.
     *
     * @return
     *	Number of bytes written (n) for normal return
     * @return
     *	EOF (-1) if an error occurred.
     **/
    fcgi_int putstr(string str)
    {
        return FCGX_PutStr(str.ptr, str.length, &this);
    }

    /**
     * Flushes any buffered output.
     *
     * Server-push is a legitimate application of FCGX_FFlush.
     * Otherwise, FCGX_FFlush is not very useful, since FCGX_Accept
     * does it implicitly.  Calling FCGX_FFlush in non-push applications
     * results in extra writes and therefore reduces performance.
     *
     * @return
     *	false if an error occurred.
     **/
    bool flush()
    {
        return FCGX_FFlush(&this) is 0;
    }

    /**
     * Closes the stream.
     *
     * For writers, flushes any buffered output.
     *
     * Close is not a very useful operation since FCGX_Accept does it implicitly. 
     * Closing the out stream before the err stream results in an extra write if
     * there's nothing in the err stream, and therefore reduces performance.
     *
     * @return
     *	false if an error occurred.
     **/
    bool close()
    {
        return FCGX_FClose(&this) is 0;
    }

    /**
     * Return the stream error code.
     *
     * @return
     *	0 means no error
     * @return
     *	> 0 is an errno(2) error
     * @return
     *	< 0 is an FastCGI error.
     **/
    
    fcgi_int errno(){
	return FCGX_GetError(&this) ;
    }
    
    string error()
    {
	fcgi_int errno	= FCGX_GetError(&this) ;
	string 	 errstr = null ;
	if( errno > 0 ) {
		version (Posix)
		{
		    char[256] buf = void;
		    version (linux)
		    {
			auto s = std.c.string.strerror_r(errno, buf.ptr, buf.length);
		    }
		    else
		    {
			std.c.string.strerror_r(errno, buf.ptr, buf.length);
			auto s = buf.ptr;
		    }
		} else {
		    auto s = std.c.string.strerror(errno);
		}
		errstr	= to!string(s);
	} else if( errno < 0 ) {
		alias traits_allMembers!(FCGX_ERROR) Enum_Names;
		foreach(int i, name; Enum_Names){
			const _name	= Enum_Names[i].stringof[1..$-1] ;
			if( __traits(getMember, FCGX_ERROR, _name) is errno ) {
				errstr	= _name ;
				break ;
			}
		}
	}
	
        return errstr ;
    }

}

/**
 * An environment (as defined by environ(7)): A NULL-terminated array
 * of strings, each string having the form name=value.
 **/
alias char** FCGX_ParamArray;

/**
 * FCGX_Request State associated with a request.
 *
 * Its exposed for API simplicity, I expect parts of it to change!
 **/
struct FCGX_Request {
	fcgi_int requestId;			        /*<! valid if isBeginProcessed */
	fcgi_int role;
	FCGX_Stream *inStream;
	FCGX_Stream *outStream;
	FCGX_Stream *errStream;
	FCGX_ParamArray envp;

	private void* paramsPtr;
	private fcgi_int ipcFd;		        /*!< < 0 means no connection */
	private fcgi_int isBeginProcessed;	/*!< FCGI_BEGIN_REQUEST seen */
	private fcgi_int keepConnection;	    /*!< don't close ipcFd */
	package fcgi_int appStatus;
	private fcgi_int nWriters;		    /*!< number of open writers (0..2) */
	private fcgi_int flags;
	private fcgi_int listen_sock;

    /**
     * Initialize a FCGX_Request
     *
     * @param sock
     *	is a file descriptor returned by FCGX_OpenSocket() or 0 (default).
     * @param flags
     *	is the flags for this request.
     * 	The only supported flag at this time is FCGI_FAIL_ON_INTR.
     * @return 
     *	0 upon success.
     **/
    fcgi_fd Init(fcgi_fd sock = 0, fcgi_int flags = 0)
    {
        return FCGX_InitRequest(&this, sock, flags);
    }

    /**
     * Accept a new request
     *
     * Be sure to call FCGX_Init() first.
     *
     * @return
     *	true for successful call
     * @return
     *	false for error.
     *
     * @attention
     *	Finishes the request accepted by (and frees any
     *	storage allocated by) the previous call to FCGX_Accept.
     *	Creates input, output, and error streams and
     *	assigns them to *in, *out, and *err respectively.
     *	Creates a parameters data structure to be accessed
     *	via getenv(3) (if assigned to environ) or by FCGX_GetParam
     *	and assigns it to *envp.
     *
     *	DO NOT retain pointers to the envp array or any strings
     *	contained in it (e.g. to the result of calling FCGX_GetParam),
     *	since these will be freed by the next call to FCGX_Finish
     *	or FCGX_Accept.
     *
     *	DON'T use the FCGX_Request, its structure WILL change.
     **/
    bool accept()
    {
        return FCGX_Accept_r(&this) == 0;
    }

    /**
     * Finish the request
     *
     * @attention
     *	Finishes the request accepted by (and frees any
     *	storage allocated by) the previous call to FCGX_Accept.
     *
     *	DO NOT retain pointers to the envp array or any strings
     *	contained in it (e.g. to the result of calling FCGX_GetParam),
     *	since these will be freed by the next call to FCGX_Finish
     *	or FCGX_Accept.
     **/
    void finish()
    {
        FCGX_Finish_r(&this);
    }

    /**
     * Free the memory and, if close is true, IPC FD associated with the request
     * (multi-thread safe).
     **/
    void free(bool close = false)
    {
        FCGX_Free(&this, close);
    }

    /**
     * obtain value of FCGI parameter in environment
     *
     * @return
     *	Value bound to name
     * @return
     *	NULL if name not present in the environment envp.
     * @note
     * 	Caller must not mutate the result or retain it past the end of this
     *	request.
     **/
    char[] param(const char *name)
    {
        char* rv = FCGX_GetParam(name, this.envp);

        if (rv is null)
            return null;

        size_t i = 0;
        while (rv[i] !is '\0')
            i++;

        return rv[0..i];
    }

};

/* C API */

/*! @private */
extern(C):
// This is a hack to make doxygen document this properly
template _doc_hack_() { }

/**
 * Tests to see if this process is a CGI process rather than a FastCGI process.
 *
 * @return
 *	1 if this process appears to be a CGI process.
 **/
fcgi_int FCGX_IsCGI();

/**
 * Initialize the FCGX library.
 *
 * Call in multi-threaded apps before calling FCGX_Accept_r().
 *
 * @return
 *	0 on success
 **/
fcgi_int FCGX_Init();

/**
 * Create a FastCGI listen socket.
 *
 * @param path
 *	is the Unix domain socket (named pipe for WinNT), or a colon followed by
 *	a port number.  e.g. "/tmp/fastcgi/mysocket", ":5000"
 * @param backlog
 *	is the listen queue depth used in the listen() call.
 * @return
 *	the socket file descriptor or -1 on error.
 **/
fcgi_fd FCGX_OpenSocket(const char *path, fcgi_int backlog);

/**
 * Initialize a FCGX_Request for use with FCGX_Accept_r().
 *
 * @param request
 *	A pointer to the FCGX_Request structure to initialize
 * @param sock
 *	is a file descriptor returned by FCGX_OpenSocket() or 0 (default).
 * @param flags
 *	is the flags for this request.
 * 	The only supported flag at this time is FCGI_FAIL_ON_INTR.
 * @return 
 *	0 upon success.
 **/
fcgi_bool FCGX_InitRequest(FCGX_Request *request, fcgi_fd sock, fcgi_int flags);

/**
 * Accept a new request (multi-thread safe).
 *
 * Be sure to call FCGX_Init() first.
 *
 * @return
 *	0 for successful call
 * @return
 *	-1 for error.
 *
 * @attention
 *	Finishes the request accepted by (and frees any
 *	storage allocated by) the previous call to FCGX_Accept.
 *	Creates input, output, and error streams and
 *	assigns them to *in, *out, and *err respectively.
 *	Creates a parameters data structure to be accessed
 *	via getenv(3) (if assigned to environ) or by FCGX_GetParam
 *	and assigns it to *envp.
 *
 *	DO NOT retain pointers to the envp array or any strings
 *	contained in it (e.g. to the result of calling FCGX_GetParam),
 *	since these will be freed by the next call to FCGX_Finish
 *	or FCGX_Accept.
 *
 *	DON'T use the FCGX_Request, its structure WILL change.
 **/
fcgi_bool FCGX_Accept_r(FCGX_Request *request);

/**
 * Finish the request (multi-thread safe).
 *
 * @attention
 *	Finishes the request accepted by (and frees any
 *	storage allocated by) the previous call to FCGX_Accept.
 *
 *	DO NOT retain pointers to the envp array or any strings
 *	contained in it (e.g. to the result of calling FCGX_GetParam),
 *	since these will be freed by the next call to FCGX_Finish
 *	or FCGX_Accept.
 */
void FCGX_Finish_r(FCGX_Request *request);

/**
 * Free the memory and, if close is true, IPC FD associated with the request
 * (multi-thread safe).
 **/
void FCGX_Free(FCGX_Request* request, int close);

/**
 * Accept a new request (NOT multi-thread safe).
 *
 * @return
 *	0 for successful call
 * @return
 *	-1 for error.
 *
 * @attention
 *	Finishes the request accepted by (and frees any
 *	storage allocated by) the previous call to FCGX_Accept.
 *	Creates input, output, and error streams and
 *	assigns them to *in, *out, and *err respectively.
 *	Creates a parameters data structure to be accessed
 *	via getenv(3) (if assigned to environ) or by FCGX_GetParam
 *	and assigns it to *envp.
 *
 *	DO NOT retain pointers to the envp array or any strings
 *	contained in it (e.g. to the result of calling FCGX_GetParam),
 *	since these will be freed by the next call to FCGX_Finish
 *	or FCGX_Accept.
 **/
int FCGX_Accept(
	FCGX_Stream **inStream,
	FCGX_Stream **outStream,
	FCGX_Stream **errStream,
	FCGX_ParamArray *envp);

/**
 * Finish the current request (NOT multi-thread safe).
 *
 * @attention
 *	Finishes the request accepted by (and frees any
 *	storage allocated by) the previous call to FCGX_Accept.
 *
 *	DO NOT retain pointers to the envp array or any strings
 *	contained in it (e.g. to the result of calling FCGX_GetParam),
 *	since these will be freed by the next call to FCGX_Finish
 *	or FCGX_Accept.
 **/
void FCGX_Finish();

/**
 * FCGI_FILE request stream handling.
 *
 * @param stream
 *	is an input stream for a FCGI_FILTER request.
 *	stream is positioned at EOF on FCGI_STDIN.
 *	Repositions stream to the start of FCGI_DATA.
 *	If the preconditions are not met (e.g. FCGI_STDIN has not
 *	been read to EOF) sets the stream error code to
 *	FCGX_CALL_SEQ_ERROR.
 *
 * @return
 *	0 for a normal return
 * @return
 *	< 0 for error
 **/
int FCGX_StartFilterData(FCGX_Stream *stream);

/**
 * Sets the exit status for stream's request.
 *
 * The exit status is the status code the request would have exited with, had
 * the request been run as a CGI program.  You can call SetExitStatus several
 * times during a request; the last call before the request ends determines the
 * value.
 **/
void FCGX_SetExitStatus(fcgi_int status, FCGX_Stream *stream);

/**
 * obtain value of FCGI parameter in environment
 *
 * @return
 *	Value bound to name
 * @return
 *	NULL if name not present in the environment envp.
 * @note
 * 	Caller must not mutate the result or retain it past the end of this
 *	request.
 */
char* FCGX_GetParam(const char *name, FCGX_ParamArray envp);

/**
 * Reads a byte from the input stream and returns it.
 *
 * @return
 *	The byte
 * @return
 *	or EOF (-1) if the end of input has been reached.
 **/
fcgi_int FCGX_GetChar(FCGX_Stream *stream);

/**
 * Pushes back the character c onto the input stream.
 *
 * One character of pushback is guaranteed once a character has been read.  No
 * pushback is possible for EOF.
 *
 * @return
 *	c if the pushback succeeded
 * @return
 *	EOF if not.
 **/
fcgi_int FCGX_UnGetChar(fcgi_int c, FCGX_Stream *stream);

/**
 * Reads up to n consecutive bytes from the input stream into the character
 * array str.
 *
 * Performs no interpretation of the input bytes.
 *
 * @return
 *	Number of bytes read. If result is smaller than n, the end of input has
 *	been reached.
 **/
fcgi_int FCGX_GetStr(char *str, fcgi_int n, FCGX_Stream *stream);

/**
 * Reads up to n-1 consecutive bytes from the input stream into the character
 * array str.
 *
 * Stops before n-1 bytes have been read if '\\n' or EOF is read.  The
 * terminating '\\n' is copied to str.  After copying the last byte into str,
 * stores a '\\0' terminator.
 *
 * @return
 *	null if EOF is the first thing read from the input stream
 * @return
 *	str otherwise
 **/
char *FCGX_GetLine(char *str, fcgi_int n, FCGX_Stream *stream);

/**
 * Returns EOF if end-of-file has been detected while reading from stream;
 * otherwise returns 0.
 *
 * Note that FCGX_HasSeenEOF(s) may return 0, yet an immediately following
 * FCGX_GetChar(s) may return EOF.  This function, like the standard C stdio
 * function feof, does not provide the ability to peek ahead.
 *
 * @return
 *	EOF if end-of-file has been detected, 0 if not.
 **/

fcgi_int FCGX_HasSeenEOF(FCGX_Stream *stream);

/**
 * Writes a byte to the output stream.
 *
 * @return
 *	The byte, or EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_PutChar(fcgi_int c, FCGX_Stream *stream);

/**
 * Writes n consecutive bytes from the character array str into the output
 * stream.
 *
 * Performs no interpretation of the output bytes.
 *
 * @return
 *	Number of bytes written (n) for normal return
 * @return
 *	EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_PutStr(const char *str, fcgi_int n, FCGX_Stream *stream);

/**
 * Writes a null-terminated character string to the output stream.
 *
 * @return
 *	number of bytes written for normal return
 * @return
 *	EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_PutS(const char *str, FCGX_Stream *stream);

/**
 * Performs printf-style output formatting and writes the results to the output
 * stream.
 *
 * @return
 *	number of bytes written for normal return,
 * @return
 * EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_FPrintF(FCGX_Stream *stream, const char *format, ...);

/**
 * Performs printf-style output formatting and writes the results to the output
 * stream.
 *
 * @return
 *	number of bytes written for normal return,
 * @return
 *	EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_VFPrintF(
	FCGX_Stream *stream,
	const char *format,
	/* va_list */ void* arg);

/**
 * Flushes any buffered output.
 *
 * Server-push is a legitimate application of FCGX_FFlush.
 * Otherwise, FCGX_FFlush is not very useful, since FCGX_Accept
 * does it implicitly.  Calling FCGX_FFlush in non-push applications
 * results in extra writes and therefore reduces performance.
 *
 * @return
 *	EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_FFlush(FCGX_Stream *stream);

/**
 * Closes the stream.
 *
 * For writers, flushes any buffered output.
 *
 * Close is not a very useful operation since FCGX_Accept does it implicitly. 
 * Closing the out stream before the err stream results in an extra write if
 * there's nothing in the err stream, and therefore reduces performance.
 *
 * @return
 *	EOF (-1) if an error occurred.
 **/
fcgi_int FCGX_FClose(FCGX_Stream *stream);

/**
 * Return the stream error code.
 *
 * @return
 *	0 means no error
 * @return
 *	> 0 is an errno(2) error
 * @return
 *	< 0 is an FastCGI error.
 **/
fcgi_int FCGX_GetError(FCGX_Stream *stream);

/**
 * Clear the stream error code and end-of-file indication.
 */
void FCGX_ClearError(FCGX_Stream *stream);

/**
 * Create a FCGX_Stream (used by cgi-fcgi).
 *
 * This shouldn't be needed by a FastCGI applictaion.
 **/
FCGX_Stream *FCGX_CreateWriter(fcgi_fd sock, fcgi_int rId, fcgi_int bufflen, fcgi_int streamType);

/**
 * Free a FCGX_Stream (used by cgi-fcgi).
 *
 * This shouldn't be needed by a FastCGI applictaion.
 */
void FCGX_FreeStream(FCGX_Stream **stream);

/**
 *  Prevent the lib from accepting any new requests.
 *
 * @note
 *	Signal handler safe.
 **/
void FCGX_ShutdownPending();

