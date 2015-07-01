# co_prefer_static()
#
# Prefer finding static libraries (.a files) to shared libraries (.so) files
# when using find_package or find_libraries. Not supported on Windows as static
# and shared libraries both use the .lib extension.
#
# Call this as needed to change the behaviour for subsequent external libraries.
macro( co_prefer_static )
	if( NOT CONSORT_WINDOWS )
		list( REMOVE_ITEM CMAKE_FIND_LIBRARY_SUFFIXES   ".a" )
		list( INSERT      CMAKE_FIND_LIBRARY_SUFFIXES 0 ".a" )
	endif()
endmacro()

# co_prefer_shared()
#
# Prefer finding shared libraries (.so files) to static libraries (.a) files
# when using find_package or find_libraries. Not supported on Windows as static
# and shared libraries both use the .lib extension.
#
# Call this as needed to change the behaviour for subsequent external libraries.
macro( co_prefer_shared )
	if( NOT CONSORT_WINDOWS )
		list( REMOVE_ITEM CMAKE_FIND_LIBRARY_SUFFIXES ".a" )
		list( APPEND      CMAKE_FIND_LIBRARY_SUFFIXES ".a" )
	endif()
endmacro()
