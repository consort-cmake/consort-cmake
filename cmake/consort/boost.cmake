## Externals/CONSORT_BOOST_LOCATIONS
#
# Define a list of directories to search for boost, Consort will automatically
# add these directories to locations to search for Boost. You can modify this
# list before calling [co_enable_boost](#/co_enable_boost) to adjust the
# locations Consort will search.
#
# By default, [co_enable_boost](#/co_enable_boost) searches the following locations:
#
### Windows
# * c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}
# * c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}
# * c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}
# * c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}
# * c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_COMPILER_NAME}
# * c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_COMPILER_NAME}
# * c:/opt/boost/cxx${CMAKE_CXX_STANDARD}
# * c:/boost/cxx${CMAKE_CXX_STANDARD}
# * c:/opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}
# * c:/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}
# * c:/opt/boost/${CONSORT_PLATFORM_NAME}
# * c:/boost/${CONSORT_PLATFORM_NAME}
# * c:/opt/boost/${CONSORT_COMPILER_NAME}
# * c:/boost/${CONSORT_COMPILER_NAME}
# * c:/opt/boost
# * c:/boost
#
### Linux and OS X
# * /opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}/cxx${CMAKE_CXX_STANDARD}
# * /opt/boost/${CONSORT_PLATFORM_NAME}/cxx${CMAKE_CXX_STANDARD}
# * /opt/boost/${CONSORT_COMPILER_NAME}/cxx${CMAKE_CXX_STANDARD}
# * /opt/boost/cxx${CMAKE_CXX_STANDARD}
# * /opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}
# * /opt/boost/${CONSORT_PLATFORM_NAME}
# * /opt/boost/${CONSORT_COMPILER_NAME}
# * /opt/boost
#
set(CONSORT_BOOST_LOCATIONS "")
if(CONSORT_WINDOWS)
	if(CMAKE_CXX_STANDARD)
		list(APPEND CONSORT_BOOST_LOCATIONS
			"c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}"
			"c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}"
			"c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}"
			"c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_PLATFORM_NAME}"
			"c:/opt/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_COMPILER_NAME}"
			"c:/boost/cxx${CMAKE_CXX_STANDARD}/${CONSORT_COMPILER_NAME}"
			"c:/opt/boost/cxx${CMAKE_CXX_STANDARD}"
			"c:/boost/cxx${CMAKE_CXX_STANDARD}"
		)
	endif()
	list(APPEND CONSORT_BOOST_LOCATIONS
		"c:/opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}"
		"c:/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}"
		"c:/opt/boost/${CONSORT_PLATFORM_NAME}"
		"c:/boost/${CONSORT_PLATFORM_NAME}"
		"c:/opt/boost/${CONSORT_COMPILER_NAME}"
		"c:/boost/${CONSORT_COMPILER_NAME}"
		"c:/opt/boost"
		"c:/boost"
	)
endif()
if(CONSORT_LINUX OR CONSORT_MACOSX)
	if(CMAKE_CXX_STANDARD)
		list(APPEND CONSORT_BOOST_LOCATIONS
			"/opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}/cxx${CMAKE_CXX_STANDARD}"
			"/opt/boost/${CONSORT_PLATFORM_NAME}/cxx${CMAKE_CXX_STANDARD}"
			"/opt/boost/${CONSORT_COMPILER_NAME}/cxx${CMAKE_CXX_STANDARD}"
			"/opt/boost/cxx${CMAKE_CXX_STANDARD}"
		)
	endif()
	list(APPEND CONSORT_BOOST_LOCATIONS
		"/opt/boost/${CONSORT_PLATFORM_NAME}/${CONSORT_COMPILER_NAME}"
		"/opt/boost/${CONSORT_PLATFORM_NAME}"
		"/opt/boost/${CONSORT_COMPILER_NAME}"
		"/opt/boost"
	)
endif()

## Externals/co_enable_boost
#
# ```
# co_enable_boost(version component component...)
# ```
#
# Enable support for Boost, you should specify the version of boost you are
# developing against and a list of boost libraries to find.
#
# Consort searches the paths in [CONSORT_BOOST_LOCATIONS](#/CONSORT_BOOST_LOCATIONS)
# for the specified boost version and libraries. Consort will not search system
# paths and will look for static libraries. Consort:
#
# * Adds the boost include directory to the list of global include directories.
# * Enables boost filesystem V3 (`-DBOOST_FILESYSTEM_VERSION=3`).
# * Disables autolinking on windows (`-DBOOST_ALL_NO_LIB`).
#
# Where necessary Consort will sanitise boost library names to make linking to
# boost as painless as possible.
#
macro(co_enable_boost version)
	foreach(_dir ${CONSORT_BOOST_LOCATIONS})
		if(EXISTS "${_dir}")
			# These should work as a list based on how FindBoost.cmake is implemented
			list(APPEND BOOST_INCLUDEDIR "${_dir}/include")
			list(APPEND BOOST_LIBRARYDIR "${_dir}/lib")
		endif()
	endforeach()

	# Prefer static libraries - you probably want to develop against a version
	# of boost specific to your compiler, platform and application - statically
	# linking it in is the best way to avoid DLL hell and related issues.
	set(Boost_USE_STATIC_LIBS   ON)

	# The default layout type on Linux doesn't include the multi-threaded suffix
	if( UNIX AND NOT APPLE )
		set(Boost_USE_MULTITHREADED OFF)
	endif()

	# Avoid finding the system version of boost
	set(Boost_NO_SYSTEM_PATHS ON)

	find_package(Boost ${version} REQUIRED COMPONENTS ${ARGN})

	if(NOT Boost_FOUND)
		message("Boost was not found. CMake looked in the following locations for version ${version}:")
		co_debug(BOOST_ROOT)
		co_debug(BOOST_INCLUDEDIR)
		co_debug(BOOST_LIBRARYDIR)
	else()
		# Allow boost to be included easily
		include_directories(BEFORE SYSTEM ${Boost_INCLUDE_DIRS})

		# Ensure new boost filesystem is used
		add_definitions(-DBOOST_FILESYSTEM_VERSION=3)

		# Prevent autolinking on Windows for consistent cross-platform behaviour
		add_definitions(-DBOOST_ALL_NO_LIB)

		# Add some dependencies of the boost::thread library
		if( Boost_THREAD_LIBRARY AND CONSORT_LINUX )
			list( APPEND Boost_THREAD_LIBRARY -pthread -lrt )
		endif()

	endif()
endmacro()

## Externals/co_enable_default_boost
#
# ```
# co_enable_default_boost(component component...)
# ```
#
# Enable the boost version and libraries that Consort uses by default.
# By default Consort requests boost 1.58 (the most recent at time of writing)
# and the most frequently used libraries.
#
# You may specify additional components to load as arguments to this function.
#
# By default Consort finds the following boost libraries:
#
# * date_time
# * chrono
# * context
# * coroutine
# * filesystem
# * system
# * thread
# * random
# * regex
# * atomic
# * graph
#
# It is not necessary to specify header only libraries in the component list.
macro(co_enable_default_boost)
	co_enable_boost(
		1.58
		date_time
		chrono
		context
		coroutine
		filesystem
		system
		thread
		random
		regex
		atomic
		graph
		${ARGN}
	)
endmacro()
