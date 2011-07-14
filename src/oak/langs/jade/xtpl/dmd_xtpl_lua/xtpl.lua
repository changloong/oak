
local xtpl_pool	= {} 

local xtpl_new = function( klass, lcoal)
	
end

local xtpl_obj	= {
	new = function( args ) 
		local pos	= string.find(args, ':' );
		if( pos < 3 ) then
			return 1, args
		end
		local klass	= string.sub(args, 0, pos -1 ) ;
		local loc	= string.sub(args,  pos + 1 ) ;
		
		local _klass	= rawget(xtpl_pool, klass ) ;
		if( _klass ) then 
			return 1, "位置冲突"
		end
		xtpl_new	= xtpl_new(klass, loc );
		return 0, klass
	end ,
	
	assign	= function( args ) 
		print("@assign	= ", args)
		return 1, "assign 错误"
	end ,
}

function xtpl_call(args)

 	local len	= string.len(args) ;
	if( len < 8 ) then 
		return nil
	end
	if( 'tpl://' == string.sub(args, 0 , 6) ) then
		local pos	= string.find(args, '::', 7 );
		if( pos <= 8 ) then
			error(args)
		end
		local fun	=  string.sub(args, 7, pos -1 )  ;
		
		local _fun	= rawget(xtpl_obj, fun ) 
		local _args	= string.sub(args, pos + 2 ) 
		if( _fun ) then 
			return _fun(_args)
		end
		error(args)
	end
	return   nil
end
