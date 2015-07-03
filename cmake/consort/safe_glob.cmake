## Utilities/co_safe_glob
# ```
# co_safe_glob( output_var glob glob ...)
# ```
#
# Expand file globs into output_var, generating an error if any glob files to
# expand to any files. Analogous to `file(GLOB ${var} ${ARGN})` but with a
# sanity check to ensure each glob matches at least one file.
#
function( co_safe_glob var )
	set( _out "" )
	foreach( glob ${ARGN} )
		file( GLOB tmp "${glob}" )

		if( tmp )
			list( APPEND _out ${tmp} )
		else()
			message( SEND_ERROR "No files exist matching '${glob}'." )
		endif()
	endforeach()
	set( "${var}" ${_out} PARENT_SCOPE )
endfunction()
