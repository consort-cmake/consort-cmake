# co_runtime_dll(file file...)
#
# Copy DLLs required at runtime to the bin folder.
function(co_runtime_dll)
	if( CO_MULTICONFIG_BUILD )
		set( _dirs
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL}
		)
	else()
		set( _dirs
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
		)
	endif()
	if( _dirs )
		list( REMOVE_DUPLICATES _dirs )

		file(MAKE_DIRECTORY ${_dirs})
		foreach( _dir ${_dirs} )
			file(COPY ${ARGN} DESTINATION "${_dir}")
		endforeach()
	endif()
endfunction()

# co_runtime_link(target linkname)
#
# Link the "target" file or directory as "linkname" in each of the runtime
# output locations. Unlike co_link, this will create multiple links for CMake
# generators that support multiple build configurations.
function(co_runtime_link target linkname)
	if( CO_MULTICONFIG_BUILD )
		set( _dirs
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL}
		)
	else()
		set( _dirs
			${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
		)
	endif()
	if( _dirs )
		list( REMOVE_DUPLICATES _dirs )
		foreach( _dir ${_dirs} )
			co_link( "${target}" "${_dir}/${linkname}" )
		endforeach()
	endif()
endfunction()
