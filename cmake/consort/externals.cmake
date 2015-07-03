## Externals/co_prefer_static
# ```
# co_prefer_static()
# ```
#
# Prefer finding static libraries (.a files) to shared libraries (.so) files
# when using find_package or find_libraries. Not supported on Windows as static
# and shared libraries both use the .lib extension.
#
# Call this as needed to change the behaviour for subsequent external libraries.
#
# Example:
#
#     co_prefer_static()
#     find_package(PNG) # find static libpng if possible (otherwise fall back to shared)
#
macro( co_prefer_static )
	if( NOT CONSORT_WINDOWS )
		list( REMOVE_ITEM CMAKE_FIND_LIBRARY_SUFFIXES   ".a" )
		list( INSERT      CMAKE_FIND_LIBRARY_SUFFIXES 0 ".a" )
	endif()
endmacro()

## Externals/co_prefer_shared
# ```
# co_prefer_shared()
# ```
#
# Prefer finding shared libraries (.so files) to static libraries (.a) files
# when using find_package or find_libraries. Not supported on Windows as static
# and shared libraries both use the .lib extension.
#
# Call this as needed to change the behaviour for subsequent external libraries.
#
# Example:
#
#     co_prefer_shared()
#     find_package(PNG) # find shared libpng if possible (otherwise fall back to static)
#
macro( co_prefer_shared )
	if( NOT CONSORT_WINDOWS )
		list( REMOVE_ITEM CMAKE_FIND_LIBRARY_SUFFIXES ".a" )
		list( APPEND      CMAKE_FIND_LIBRARY_SUFFIXES ".a" )
	endif()
endmacro()
