
module jade.util.Pcre ;

import std.string, std.conv, std.traits ;

import jade.Jade ;

enum : int {
	PCRE_CASELESS           =0x00000001,
	PCRE_MULTILINE          =0x00000002,
	PCRE_DOTALL             =0x00000004,
	PCRE_EXTENDED           =0x00000008,
	PCRE_ANCHORED           =0x00000010,
	PCRE_DOLLAR_ENDONLY     =0x00000020,
	PCRE_EXTRA              =0x00000040,
	PCRE_NOTBOL             =0x00000080,
	PCRE_NOTEOL             =0x00000100,
	PCRE_UNGREEDY           =0x00000200,
	PCRE_NOTEMPTY           =0x00000400,
	PCRE_UTF8               =0x00000800,
	PCRE_NO_AUTO_CAPTURE    =0x00001000,
	PCRE_NO_UTF8_CHECK      =0x00002000,
	PCRE_AUTO_CALLOUT       =0x00004000,
	PCRE_PARTIAL_SOFT       =0x00008000,
	PCRE_PARTIAL            =0x00008000, /* Backwards compatible synonym */
	PCRE_DFA_SHORTEST       =0x00010000,
	PCRE_DFA_RESTART        =0x00020000,
	PCRE_FIRSTLINE          =0x00040000,
	PCRE_DUPNAMES           =0x00080000,
	PCRE_NEWLINE_CR         =0x00100000,
	PCRE_NEWLINE_LF         =0x00200000,
	PCRE_NEWLINE_CRLF       =0x00300000,
	PCRE_NEWLINE_ANY        =0x00400000,
	PCRE_NEWLINE_ANYCRLF    =0x00500000,
	PCRE_BSR_ANYCRLF        =0x00800000,
	PCRE_BSR_UNICODE        =0x01000000,
	PCRE_JAVASCRIPT_COMPAT  =0x02000000,
	PCRE_NO_START_OPTIMIZE  =0x04000000,
	PCRE_NO_START_OPTIMISE  =0x04000000,
	PCRE_PARTIAL_HARD       =0x08000000,
	PCRE_NOTEMPTY_ATSTART   =0x10000000,
	PCRE_UCP                =0x20000000,

	/* Exec-time and get/set-time error codes */

	PCRE_ERROR_NOMATCH         =(-1),
	PCRE_ERROR_NULL            =(-2),
	PCRE_ERROR_BADOPTION       =(-3),
	PCRE_ERROR_BADMAGIC        =(-4),
	PCRE_ERROR_UNKNOWN_OPCODE  =(-5),
	PCRE_ERROR_UNKNOWN_NODE    =(-5), /* For backward compatibility */
	PCRE_ERROR_NOMEMORY        =(-6),
	PCRE_ERROR_NOSUBSTRING     =(-7),
	PCRE_ERROR_MATCHLIMIT      =(-8),
	PCRE_ERROR_CALLOUT         =(-9),  /* Never used by PCRE itself */
	PCRE_ERROR_BADUTF8        =(-10),
	PCRE_ERROR_BADUTF8_OFFSET =(-11),
	PCRE_ERROR_PARTIAL        =(-12),
	PCRE_ERROR_BADPARTIAL     =(-13),
	PCRE_ERROR_INTERNAL       =(-14),
	PCRE_ERROR_BADCOUNT       =(-15),
	PCRE_ERROR_DFA_UITEM      =(-16),
	PCRE_ERROR_DFA_UCOND      =(-17),
	PCRE_ERROR_DFA_UMLIMIT    =(-18),
	PCRE_ERROR_DFA_WSSIZE     =(-19),
	PCRE_ERROR_DFA_RECURSE    =(-20),
	PCRE_ERROR_RECURSIONLIMIT =(-21),
	PCRE_ERROR_NULLWSLIMIT    =(-22), /* No longer actually used */
	PCRE_ERROR_BADNEWLINE     =(-23),

	/* Request types for pcre_fullinfo() */

	PCRE_INFO_OPTIONS            =0,
	PCRE_INFO_SIZE               =1,
	PCRE_INFO_CAPTURECOUNT       =2,
	PCRE_INFO_BACKREFMAX         =3,
	PCRE_INFO_FIRSTBYTE          =4,
	PCRE_INFO_FIRSTCHAR          =4, /* For backwards compatibility */
	PCRE_INFO_FIRSTTABLE         =5,
	PCRE_INFO_LASTLITERAL        =6,
	PCRE_INFO_NAMEENTRYSIZE      =7,
	PCRE_INFO_NAMECOUNT          =8,
	PCRE_INFO_NAMETABLE          =9,
	PCRE_INFO_STUDYSIZE         =10,
	PCRE_INFO_DEFAULT_TABLES    =11,
	PCRE_INFO_OKPARTIAL         =12,
	PCRE_INFO_JCHANGED          =13,
	PCRE_INFO_HASCRORLF         =14,
	PCRE_INFO_MINLENGTH         =15,

	/* Request types for pcre_config(). Do not re-arrange, in order to remain
	compatible. */

	PCRE_CONFIG_UTF8                    =0,
	PCRE_CONFIG_NEWLINE                 =1,
	PCRE_CONFIG_LINK_SIZE               =2,
	PCRE_CONFIG_POSIX_MALLOC_THRESHOLD  =3,
	PCRE_CONFIG_MATCH_LIMIT             =4,
	PCRE_CONFIG_STACKRECURSE            =5,
	PCRE_CONFIG_UNICODE_PROPERTIES      =6,
	PCRE_CONFIG_MATCH_LIMIT_RECURSION   =7,
	PCRE_CONFIG_BSR                     =8,

	/* Bit flags for the pcre_extra structure. Do not re-arrange or redefine
	these bits, just add new ones on the end, in order to remain compatible. */

	PCRE_EXTRA_STUDY_DATA             =0x0001,
	PCRE_EXTRA_MATCH_LIMIT            =0x0002,
	PCRE_EXTRA_CALLOUT_DATA           =0x0004,
	PCRE_EXTRA_TABLES                 =0x0008,
	PCRE_EXTRA_MATCH_LIMIT_RECURSION  =0x0010,
	PCRE_EXTRA_MARK                   =0x0020,
}

private {
	struct real_pcre ;
	alias real_pcre	pcre ;
	alias char*	PCRE_SPTR ;
	alias uint		PCRE_ULONG ;
	alias int		PCRE_INT;
	
	struct pcre_extra {
		PCRE_ULONG	flags;		/* Bits for which fields are set */
		void*		study_data;	/* Opaque data from pcre_study() */
		PCRE_ULONG	match_limit;	/* Maximum number of calls to match() */
		void*		callout_data;	/* Data passed back in callouts */
		PCRE_SPTR*	tables;	/* Pointer to character tables */
		PCRE_ULONG	match_limit_recursion;	/* Max recursive calls to match() */
		PCRE_SPTR**	mark;	 /* For passing back a mark pointer */
	}
	
	struct pcre_callout_block {
		PCRE_INT		  _version;           /* Identifies version of block */
		/* ------------------------ Version 0 ------------------------------- */
		PCRE_INT          callout_number;    /* Number compiled into pattern */
		PCRE_INT*	offset_vector;     /* The offset vector */
		PCRE_SPTR	subject;           /* The subject being matched */
		PCRE_INT		subject_length;    /* The length of the subject */
		PCRE_INT		start_match;       /* Offset to start of this match attempt */
		PCRE_INT		current_position;  /* Where we currently are in the subject */
		PCRE_INT		 capture_top;       /* Max current capture */
		PCRE_INT		capture_last;      /* Most recently closed capture */
		void*		callout_data;      /* Data passed in with the call */
		/* ------------------- Added for Version 1 -------------------------- */
		PCRE_INT	 	pattern_position;  /* Offset to next item in the pattern */
		PCRE_INT		next_item_length;  /* Length of next item in the pattern */
		/* ------------------------------------------------------------------ */
	}
	
	extern(C) {
		void*	pcre_malloc(size_t);
		void		pcre_free(void*);
		void*	pcre_stack_malloc(size_t);
		void		pcre_stack_free(void*);
		PCRE_INT	pcre_callout(pcre_callout_block*);
		
		/* Exported PCRE functions */
		pcre*	pcre_compile(PCRE_SPTR, PCRE_INT, PCRE_SPTR*, PCRE_INT*,  /* const */ ubyte*);
		pcre*	pcre_compile2(PCRE_SPTR, PCRE_INT, PCRE_INT *, PCRE_SPTR*,  PCRE_INT *, /* const */ ubyte*);
		PCRE_INT  pcre_config(PCRE_INT, void*);
		PCRE_INT  pcre_copy_named_substring(/*const*/ pcre *, PCRE_SPTR, PCRE_INT *, PCRE_INT, PCRE_SPTR,  PCRE_SPTR, PCRE_INT);
		PCRE_INT  pcre_copy_substring(PCRE_SPTR, PCRE_INT *, PCRE_INT, PCRE_INT, PCRE_SPTR, PCRE_INT);
		PCRE_INT  pcre_dfa_exec(/*const*/ pcre *, /*const*/ pcre_extra *, PCRE_SPTR, PCRE_INT, PCRE_INT, PCRE_INT, PCRE_INT *, PCRE_INT , PCRE_INT *, PCRE_INT);
		PCRE_INT  pcre_exec(/*const*/ pcre*, /*const*/ pcre_extra *, PCRE_SPTR, PCRE_INT, PCRE_INT, PCRE_INT, PCRE_INT *, PCRE_INT);
		void pcre_free_substring(PCRE_SPTR);
		void pcre_free_substring_list(PCRE_SPTR*);
		PCRE_INT  pcre_fullinfo(/*const*/ pcre *, /*const*/ pcre_extra *, PCRE_INT, void*);
		PCRE_INT  pcre_get_named_substring(/*const*/ pcre *, PCRE_SPTR,  PCRE_INT *, PCRE_INT, PCRE_SPTR, PCRE_SPTR*);
		PCRE_INT  pcre_get_stringnumber(/*const*/ pcre *, PCRE_SPTR);
		PCRE_INT  pcre_get_stringtable_entries(/*const*/ pcre *, PCRE_SPTR, PCRE_SPTR*, PCRE_SPTR*);
		PCRE_INT  pcre_get_substring(PCRE_SPTR, PCRE_INT *, PCRE_INT, PCRE_INT, PCRE_SPTR*);
		PCRE_INT  pcre_get_substring_list(PCRE_SPTR, PCRE_INT *, PCRE_INT, PCRE_SPTR**);
		PCRE_INT  pcre_info(/*const*/ pcre *, PCRE_INT *, PCRE_INT *);
		/*const*/ ubyte* pcre_maketables();
		PCRE_INT  pcre_refcount(pcre*, PCRE_INT);
		pcre_extra* pcre_study(/*const*/ pcre *, PCRE_INT, PCRE_SPTR*);
		PCRE_SPTR pcre_version();
	}
	
}




struct RegExp {

	alias typeof(this)	pThis ;
	alias bool delegate(string[])	ExecCb ;	
	private {
		const Len		= 32 ;
		
		pcre*		_pcre ;
		pcre_extra*	_pcrex ;
		PCRE_INT		_capture ;
		char*		errmsg ;
		PCRE_INT		errno ;
		PCRE_INT		_options;
	}
	
	bool compile(string pattern, int options = 0) in {
		assert(pattern !is null) ;
	} body {
		free ;
		PCRE_INT	erroffset ;
		_pcre	= pcre_compile2(  cast(char*) std.string.toStringz(pattern), options, &errno, &errmsg, &erroffset, null);
		if( _pcre is null ){
			return false ;
		}
		PCRE_INT	ret	= pcre_fullinfo(_pcre, _pcrex, PCRE_INFO_CAPTURECOUNT, &_capture);
		_capture++;
		if( _capture >= Len ){
			free ;
			return false ;
		}
		_options	= options ;
		return true ;
	}
	
	bool study() {
		_pcrex = pcre_study(_pcre, 0, &errmsg);
		return errmsg is null ;
	}
	
	string error() {
		if( errmsg is null ){
			return null ;
		}
		return to!string(errmsg) ;
	}
	
	PCRE_INT groupIndex(char[] gname) {
		return pcre_get_stringnumber(_pcre, cast(char*)std.string.toStringz(gname));
	}
	
	bool each(string subject, ExecCb dg, int pos = 0) {
		int len = subject.length ;
		PCRE_INT[Len*2]	vec;
		string[Len]		ma ;
		static assert( ma.length * 2 is vec.length );
		int num	= 0 ;
		int index	= 0 ;
		while( pos < len ) {
			num	= pcre_exec(_pcre, _pcrex, cast(char*)std.string.toStringz(subject), len,  pos, 0, &vec[0],  vec.length ) ;
			if( num != _capture ) {
				break ;
			}
			PCRE_INT* _pvec = &vec[0] ;
			for(int i = 0 ; i < num; i ++ ){
				int _from	= _pvec[0] ;
				int _to	= _pvec[1] ;
				_pvec	+=	 2 ;
				/*
				if( _from > _to || subject.length < _from || subject.length < _to ) {
					log(" subject=`", subject, "` pattern=", _pattern, " pos=", pos, "\n", vec );
					log("i=", i, " sub.len=", subject.length, " _from=", _from,  " _to=", _to );
					num = i ;
					break ;
				}
				*/
				if( _from is -1 && _to is -1 ) {
					ma[i]		= subject[ 0 .. 0 ] ;
				} else {
					ma[i]		= subject[_from.. _to] ;
				}
					
			}
			if( !dg( ma[0..num]) ) {
				return true ;
			}
			pos	= vec[1] ;
			index++ ;
		}
		return index !is 0 ;
	}
	
	void free() {
		if( _pcre !is null ){
			pcre_free(_pcre);
		}
		if( _pcrex !is null ){
			pcre_free(_pcrex);
		}
	}
	
	bool empty() {
		return _pcre is null ;
	}
	
	void replace(T)(vBuffer buf, string subject, T _to) {
		int i	= 0 ;
		buf.clear ;
		bool ret = each(subject, (string[] ms) {
			
			int j	= &ms[0][0] - subject.ptr ;
			if( j !is i ) {
				buf( subject[i..j] );
			}
			i	= &ms[0][$-1] - subject.ptr + 1 ;
			static if( isSomeString!(T) ){
				buf(   _to );
			}else static if( is(T==char) ){
				buf( _to );
			}else {
				static assert(false);
			}
			//dg(ms);
			return true ;
		});
		assert(i <= subject.length ) ;
		buf(  subject[i..$] );
	}
	
	alias void delegate(string) split_dg ;
	void split(string subject,  split_dg dg) {
		int i	= 0 ;
		bool ret = each(subject, (string[] ms) {
			int j	= &ms[0][0] - subject.ptr ;
			if( j !is i ) {
				dg(subject[i..j] );
			}
			i	= &ms[0][$-1] - subject.ptr ;
			return true ;
		});
		if(i < subject.length ) {
			dg(subject[i..$] );
		}
	}

	alias compile opCall ;
}
