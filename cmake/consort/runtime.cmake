## Utilities/co_runtime_dll
# ```
# co_runtime_dll(file file...)
# ```
#
# Copy DLLs required at runtime to the bin folder. On Windows in particular,
# it may be necessary to have DLLs in the same folder as the compiled binaries
# in order for the loader to find them. This routine automatically copies the
# files passed as arguments to all of the runtime output directories.
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

## Utilities/co_runtime_link
# ```
# co_runtime_link(target linkname)
# ```
#
# Link the "target" file or directory as "linkname" in each of the runtime
# output locations. Unlike [co_link](#/co_link), this will create multiple links
# for CMake generators that support multiple build configurations.
#
# This is useful for linking resources such as data files or plugins into the
# build directory so the build directory can emulate an installed version of the
# software.
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
