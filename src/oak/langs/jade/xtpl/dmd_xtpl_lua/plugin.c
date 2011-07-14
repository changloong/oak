
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#if DOS386
#include <dos.h>
#include <sys\stat.h>
#endif

#if linux || __APPLE__ || __FreeBSD__ || __sun&&__SVR4
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <dlfcn.h>
#elif	_WIN32
#include <dos.h>
#include <sys\stat.h>
#include	<windows.h>
#endif

#include "mars.h"
#include "root.h"

// os_error from backend/os.c
void os_error(int line);
#define os_error() os_error(__LINE__)
#pragma noreturn(os_error)


#ifdef __cplusplus
extern "C" {
#endif
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
	static bool is_dmd_xtpl_loaded = false ;
	static	lua_State* dmd_xtpl_lua_L ;
	static char*	dmd_xtpl_lux_file ;


int dmd_xtpl_error(lua_State *L) {
	int len = lua_gettop(L) ;
	
	/*
	for (int i = 1; i <= len ; i++) {
		if( lua_isstring( L, i) ) {
			const char* str	=  lua_tostring( L, i) ;
			printf("\nstr= {}", str );
		}
	}
	*/
	
	lua_pushinteger(L, len * len + 1 ) ;
	return 1 ;
}


bool dmd_xtpl_load() {
	int ret ;
	is_dmd_xtpl_loaded	= true ;
	dmd_xtpl_lua_L	= lua_open();
	if( !dmd_xtpl_lua_L ) {
		os_error();
	}
	luaL_openlibs(dmd_xtpl_lua_L);
	
	lua_register(dmd_xtpl_lua_L, "xtpl_error", dmd_xtpl_error );
	
	ret	= luaL_loadfile(dmd_xtpl_lua_L, dmd_xtpl_lux_file ) ;
	if( ret != 0 ) {
		error("%s",lua_tostring(dmd_xtpl_lua_L, -1) );
		lua_close(dmd_xtpl_lua_L);
		return 1 ;
	}
	ret = lua_pcall(dmd_xtpl_lua_L,0,0,0) ;
	if ( ret != 0 ) {
		error("%s",lua_tostring(dmd_xtpl_lua_L,-1) ) ;
		lua_close(dmd_xtpl_lua_L);
		return 2 ;
	}
	
	return 0 ;
}


#ifdef __cplusplus
}
#endif


size_t plugin_import(/* in */char* name, /* out */ char** d_error , /* out */ void** d_bufer){
	int ret, _ret_len ;
	char* _ret_string ;
	
	if( ! is_dmd_xtpl_loaded ) {
		dmd_xtpl_lux_file = "Z:\\dmd\\bin\\xtpl.lua" ;
		ret	=  dmd_xtpl_load() ;
		fflush(stdout);
		if( ret ) {
			error("load(%s)=%d", dmd_xtpl_lux_file , ret ) ;
			return 0 ;
		}
	}
	
	*d_error = 0 ;
	*d_bufer = 0 ;
	_ret_string	= 0 ;
	_ret_len	= 0 ;
	
	lua_getglobal(dmd_xtpl_lua_L, "xtpl_call");
	lua_pushstring(dmd_xtpl_lua_L, name);
	ret	= lua_pcall(dmd_xtpl_lua_L, 1, 2, 0);
	fflush(stdout);
	if( ret != 0 ) {
		*d_error = (char*) lua_tostring(dmd_xtpl_lua_L,-1) ;
	} else {
		_ret_string = (char*) lua_tostring(dmd_xtpl_lua_L,-1) ;
		if( _ret_string ) {
			_ret_len	= strlen( _ret_string ) ;
			*d_bufer 	= _ret_string ;
		}
	}
	
	lua_pop(dmd_xtpl_lua_L, 1) ;
	
	return  _ret_len ;	
}
