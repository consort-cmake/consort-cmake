# co_join(output-variable glue list-item...)
#
# Collapse list items into a string, joining them with the specified glue.
#
function( co_join var glue )
	set(_val "")
	set(_first 1)
	foreach( el ${ARGN} )
		if(_first)
			set(_first 0)
			set( _val "${el}" )
		else()
			set( _val "${_val}${glue}${el}" )
		endif()
	endforeach()
	set( ${var} "${_val}" PARENT_SCOPE )
endfunction()

# co_split(output-variable glue string...)
#
# Split one or more strings into lists using the specified glue character
#
function( co_split var glue )
	if( ARGN )
		string(REPLACE "${glue}" ";" _val ${ARGN} )
		set( ${var} ${_val} PARENT_SCOPE )
	else()
		set( ${var} "" PARENT_SCOPE )
	endif()
endfunction()

# co_remove_flags(var flag...)
#
# Remove all matching flags from the (space separated) list of flags in "var".
#
function( co_remove_flags var )
	co_split(_flags " " "${${var}}")
	list(LENGTH _flags _n)
	if( _n GREATER 0 )
		list(REMOVE_ITEM _flags ${ARGN})
		co_join(_flags " " ${_flags})
		set( ${var} "${_flags}" PARENT_SCOPE )
	endif()
endfunction()

# co_add_flags(var flag...)
#
# Add all matching flags to the (space separated) list of flags in "var".
#
# Existing duplicates will be removed.
#
function(co_add_flags var)
	co_split(_flags " " "${${var}}")
	list(LENGTH _flags _n)
	if( _n GREATER 0 )
		list(REMOVE_ITEM _flags ${ARGN})
	endif()

	list(APPEND _flags ${ARGN})

	co_join(_flags " " ${_flags})
	set( ${var} "${_flags}" PARENT_SCOPE )
endfunction()

# co_replace_flag(var old-flag new-flag)
#
# Replace old_flag with new_flag in the (space separated) list of flags
#
function( co_replace_flag var old_flag new_flag )
	co_split(_flags " " "${${var}}")

	set(_new_flags "")
	foreach( _flag ${_flags} )
		if( _flag STREQUAL old_flag )
			list(APPEND _new_flags ${new_flag})
		else()
			list(APPEND _new_flags ${_flag})
		endif()
	endforeach()

	co_join(_flags " " ${_new_flags})
	set( ${var} "${_flags}" PARENT_SCOPE )
endfunction()

