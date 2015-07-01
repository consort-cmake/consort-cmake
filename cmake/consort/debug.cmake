# co_debug(variable-name variable-name ...)
#
# print the value of each listed variable
function( co_debug )
	foreach(var ${ARGN})
		message( "${var}=${${var}}" )
	endforeach()
endfunction()


# co_stack_trace()
#
# print a stack trace
function( co_stack_trace )
	get_directory_property(LISTFILE_STACK LISTFILE_STACK)
	foreach(l ${LISTFILE_STACK})
		message("  ${l}")
	endforeach()
endfunction()
