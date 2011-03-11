
module jade.xtpl.Plugin ;

import jade.xtpl.all ;

__gshared	string[] project_paths ;

static void add_project_path(void* data) {
	project_paths	~= cstring_dup( cast(char*)  data) ;
}

alias void function(void*) dmd_export_cb ;
private struct dmd_export {
	void* stdout ;
	extern(C) void function(void*) fflush;
	extern(C) void function(void*, char*,...) fprintf ;
	dmd_export_cb	__add_path = &add_project_path ;
}
private __gshared dmd_export _G ;

version (Windows) {
	
	import std.c.windows.windows;
	import core.dll_helper;

	static __gshared HINSTANCE g_hInst;

	extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) {
	    switch (ulReason){
		case DLL_PROCESS_ATTACH:
		    g_hInst = hInstance;
		    dll_process_attach( hInstance, true );
		    break;

		case DLL_PROCESS_DETACH:
		    dll_process_detach( hInstance, true );
		    break;

		case DLL_THREAD_ATTACH:
		    dll_thread_attach( true, true );
		    break;

		case DLL_THREAD_DETACH:
		    dll_thread_detach( true, true );
		    break;
	    }
	    return true;
	}
}

export extern(C) size_t plugin_lib_export(size_t ty, void* data) {
	foreach(int id, c; _G.tupleof ) {
		const _name	= typeof(_G).tupleof[id].stringof[  typeof(_G).stringof.length + 3 .. $];
		if( ty is id ){
			static if( _name.length > 2 && _name[0] is '_' && _name[1] is '_' ) {
				_G.tupleof[id](data) ;
			} else {
				_G.tupleof[id]	= cast( typeof(c) ) data ;
			}
		}
	}
	return 0 ;
}

__gshared ubyte[1024 * 512 ] _tpl_global_buffer ;

void tpl_print(string _file = __FILE__, size_t _line = __LINE__, T...)(string fmt, T t) {
	scope bu =  new vBuffer(_tpl_global_buffer) ;
	formattedWrite(bu, " *) %s#%d ", _file[0..$-2], _line);
	static if(T.length > 0 ) {
		formattedWrite(bu, fmt, t);
		bu("\n\0");
	} else {
		bu("Error\n\0");
	}
	_G.fprintf(_G.stdout , cast(char*) _tpl_global_buffer.ptr );
	_G.fflush(_G.stdout);
	_tpl_global_buffer[0]	= 0 ;
}

void tpl_error(string _file = __FILE__, size_t _line = __LINE__, T...)(string fmt, T t) {
	scope bu =  new vBuffer(_tpl_global_buffer) ;
	formattedWrite(bu, "%s#%d ", _file[0..$-2], _line);
	static if(T.length > 0 ) {
		formattedWrite(bu, fmt, t);
		bu("\n\0");
	} else {
		bu("Error\n\0");
	}
	throw new Exception( bu.toString ) ;
}

export extern(C) size_t plugin_lib_import(char* in_name, char** out_error , void** out_buffer) {
	*out_error	= null ;
	try{
		auto args	=  cast(char[]) in_name[0.. strlen(in_name) ] ;
		auto ret	= XTpl.Invoke(args) ;
		if(  ret is null || ret.length is 0 ) {
			return 0 ;	
		}
		scope bu	= new vBuffer(_tpl_global_buffer);
		bu(ret);
		*out_buffer =  cast(char*)  _tpl_global_buffer.ptr ;
		return ret.length ;
	} catch(Exception e) {
		scope bu =  new vBuffer(_tpl_global_buffer) ;
		bu.clear ;
		bu(e.toString)('\0');
		*out_error	= cast(char*)  _tpl_global_buffer.ptr ;
	}
	return 0 ;
}

