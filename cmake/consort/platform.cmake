# 32/64 bit detection
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	set(CONSORT_64BIT 1)
	add_definitions(-DCONSORT_64BIT=1)
endif()

# Compiler detection
if( CMAKE_COMPILER_IS_GNUCC )
	set( CONSORT_GCC 1 )
	set( CONSORT_COMPILER_NAME gcc )

	foreach(_minor 0 1 2 3 4 5 6 7 8 9)
		if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.${_minor}" OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "4.${_minor}")
			set( CONSORT_GCC_4${_minor} 1 )
		endif()
	endforeach()
endif()

if( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
	set( CONSORT_CLANG 1 )
	set( CONSORT_COMPILER_NAME clang )
endif()

if( MSVC )
	set( CONSORT_MSVC 1 )

	if( CMAKE_CXX_COMPILER_VERSION LESS 17 AND CMAKE_CXX_COMPILER_VERSION GREATER 15 )
		set( CONSORT_MSVC_2010 1 )
		set( CONSORT_COMPILER_NAME vs2010 )
	elseif( CMAKE_CXX_COMPILER_VERSION LESS 18 )
		set( CONSORT_MSVC_2012 1 )
		set( CONSORT_COMPILER_NAME vs2012 )
	elseif( CMAKE_CXX_COMPILER_VERSION LESS 19 )
		set( CONSORT_MSVC_2013 1 )
		set( CONSORT_COMPILER_NAME vs2013 )
	else()
		message( SEND_ERROR "Compliler detection failed - unrecognised Visual Studio version ${CMAKE_CXX_COMPILER_VERSION}!" )
	endif()
endif()

if( APPLE AND NOT CONSORT_CLANG )
	# The GCC compatibility wrappers do not expose much of the more modern
	# functionality offered by clang, you're better off modifying your
	# build environment to use clang.
	message( WARNING
		"On OSX clang is the recommended compiler, it is advised you\n"
		"export CC=/usr/bin/clang\n"
		"export CXX=/usr/bin/clang++\n"
		"then delete/regenerate your CMakeFiles and CMakeCache.txt.")
endif()

# Some generators support multiple build configurations, this helps you detect
# that and adjust appropriately.
if( NOT CMAKE_CFG_INTDIR STREQUAL "." )
	set( CONSORT_MULTICONFIG_BUILD 1 )
endif()

if( NOT CONSORT_MULTICONFIG_BUILD )
	if( CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo" )
		set( CONSORT_DEBUG_BUILD 1 )
	endif()
endif()

# Platform
if( WIN32 )
	set( CONSORT_WINDOWS 1 )
	add_definitions(-DCONSORT_WINDOWS=1)

	if( CONSORT_64BIT )
		set( CONSORT_PLATFORM_NAME "windows-x86_64" )
		set( CONSORT_WINDOWS_X86_64 1 )
		add_definitions(-DCONSORT_WINDOWS_X86_64=1)
	else()
		set( CONSORT_PLATFORM_NAME "windows-x86" )
		set( CONSORT_WINDOWS_X86 1 )
		add_definitions(-DCONSORT_WINDOWS_X86=1)
	endif()

elseif( APPLE )
	set( CONSORT_MACOSX 1 )
	add_definitions(-DCONSORT_MACOSX=1)

	if( CONSORT_64BIT )
		set( CONSORT_PLATFORM_NAME "macosx-x86_64" )
		set( CONSORT_MACOSX_X86_64 1 )
		add_definitions(-DCONSORT_MACOSX_X86_64=1)
	else()
		set( CONSORT_PLATFORM_NAME "macosx-x86" )
		set( CONSORT_MACOSX_X86 1 )
		add_definitions(-DCONSORT_MACOSX_X86=1)
	endif()

elseif( UNIX )
	set( CONSORT_LINUX 1 )
	add_definitions(-DCONSORT_LINUX=1)

	if( CONSORT_64BIT )
		set( CONSORT_PLATFORM_NAME "linux-x86_64" )
		set( CONSORT_LINUX_X86_64 1 )
		add_definitions(-DCONSORT_LINUX_X86_64=1)
	else()
		set( CONSORT_PLATFORM_NAME "linux-x86" )
		set( CONSORT_LINUX_X86 1 )
		add_definitions(-DCONSORT_LINUX_X86=1)
	endif()

else()
	message( SEND_ERROR "Platform detection failed!" )
endif()
