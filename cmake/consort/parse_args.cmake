# Convert a "name" to a sensible variable name by making it upper case and
# replacing special characters with underscores.
function( co_var_name outvar var )
	string( TOUPPER "${var}" _out )
	string(REGEX REPLACE "[^A-Z0-9_]" "_" _out "${_out}")
	set("${outvar}" "${_out}" PARENT_SCOPE)
endfunction()

# Determine if the list "list" contains the value "value" and set "variable"
# to 1 or 0 appropriately.
function( co_list_contains list value variable )
	set(_l ${list})
	list( FIND _l "${value}" _i )
	if( _i EQUAL -1 )
		set("${variable}" 0 PARENT_SCOPE)
	else()
		set("${variable}" 1 PARENT_SCOPE)
	endif()
endfunction()

# Generic argument parsing macro
#
# co_parse_args(prefix "group name;group name;..." "flag name; flag name;..." arguments...)
#
# Scan "arguments" looking for "flags" (i.e. an exact match for anything in the
# list of flags) or "groups" (anything in the list of group names followed by a
# colon).
#
# For each flag, this function will set a variable in the parent scope to ON or
# OFF depending on whether the flag is defined. The variable will be an
# upper-cased version of the flag name, with the specified prefix. Special
# characters are replaced with an underscore.
#
# For each group, this function will set a variable in the parent scope to a
# list of all the items that follow the group name. The variable will be an
# upper-cased version of the flag name, with the specified prefix. Special
# characters are replaced with an underscore.
#
# Arguments that are not a flag and occur outside of a group are added to the
# ${prefix}_ARGN variable.
#
# Group and flag names are case sensitive!

function( co_parse_args prefix group_names flag_names )

	foreach( group_name ${group_names} )
		co_var_name( group_var "${group_name}" )
		set( _${group_var} "" )
	endforeach()

	foreach( flag_name ${flag_names} )
		co_var_name( flag_var "${flag_name}" )
		set( _${flag_var} OFF )
	endforeach()

	set( _current_group ARGN )

	foreach( arg ${ARGN} )
		string( REGEX MATCH "^(.+):$" looks_like_group ${arg} )
		co_list_contains( "${group_names}" "${CMAKE_MATCH_1}" is_group )
		co_list_contains( "${flag_names}" "${arg}" is_flag )

		if( looks_like_group AND is_group )
			co_var_name( _current_group "${CMAKE_MATCH_1}" )
		elseif( is_flag AND arg )
			co_var_name( flag_var "${arg}" )
			set( _${flag_var} ON )
		else()
			list( APPEND _${_current_group} "${arg}" )
		endif()
	endforeach()

	foreach( var ${group_names} ${flag_names} ARGN )
		co_var_name( var_name "${var}" )
		set( ${prefix}_${var_name} "${_${var_name}}" PARENT_SCOPE )
	endforeach()

endfunction()
