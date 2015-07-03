# 32/64 bit detection
## Variables/CONSORT_64BIT
# This variable is 1 if `sizeof(void*) >= 8`.
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	set(CONSORT_64BIT 1)
	add_definitions(-DCONSORT_64BIT=1)
endif()

# Compiler detection

## Variables/CONSORT_GCC
# Set to 1 if Consort detects the compiler is GCC (or similar).
#
# In addition, Consort will set the variables `CONSORT_GCC_40`, `CONSORT_GCC_41`
# `CONSORT_GCC_42`, `CONSORT_GCC_43`, `CONSORT_GCC_44`, `CONSORT_GCC_45`,
# `CONSORT_GCC_46`, `CONSORT_GCC_47`, `CONSORT_GCC_48`, and `CONSORT_GCC_49` if
# the GCC version is *greater than or equal to* the appropriate version.

## Variables/CONSORT_MSVC
# Set to 1 if Consort detects the compiler is MSVC.
#
# In addition, Consort will set `CONSORT_MSVC_2010` if the compiler is MSVC 2010,
# `CONSORT_MSVC_2012` if the compiler is MSVC 2012, and `CONSORT_MSVC_2013` if
# the compiler is MSVC 2013.

## Variables/CONSORT_CLANG
# Set to 1 if Consort detects the compiler is Clang.

## Variables/CONSORT_COMPILER_NAME
# * Set to gcc for GCC
# * Set to vs2010 for MSVC 2010
# * Set to vs2012 for MSVC 2012
# * Set to vs2013 for MSVC 2013
# * set to clang for Clang

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

## Variables/CONSORT_MULTICONFIG_BUILD
# Some generators support multiple build configurations, this helps you detect
# that and adjust appropriately. Set to 1 if the generator supports multiple
# build configurations.
if( NOT CMAKE_CFG_INTDIR STREQUAL "." )
	set( CONSORT_MULTICONFIG_BUILD 1 )
endif()

## Variables/CONSORT_DEBUG_BUILD
# Set to 1 if the build type contains debug information
# ([CMAKE_BUILD_TYPE](http://www.cmake.org/cmake/help/v3.3/variable/CMAKE_BUILD_TYPE.html)
# is Debug or RelWithDebInfo). Not set for generators that support multiple
# build configurations (see [CONSORT_MULTICONFIG_BUILD](#/CONSORT_MULTICONFIG_BUILD)).
if( NOT CONSORT_MULTICONFIG_BUILD )
	if( CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo" )
		set( CONSORT_DEBUG_BUILD 1 )
	endif()
endif()

# Platform detection

## Variables/CONSORT_WINDOWS
# Set to 1 if consort detects the build target is Windows. Also adds
# `-DCONSORT_WINDOWS=1` to the compile definitions.
#
# In addition CONSORT_WINDOWS_X86_64 will be defined as a CMake variable and
# preprocessor definition if [CONSORT_64BIT](#/CONSORT_64BIT) is set. Otherwise
# CONSORT_WINDOWS_X86 will be defined as a CMake variable and preprocessor
# definition.

## Variables/CONSORT_MACOSX
# Set to 1 if consort detects the build target is Mac OS X. Also adds
# `-DCONSORT_MACOSX=1` to the compile definitions.
#
# In addition CONSORT_MACOSX_X86_64 will be defined as a CMake variable and
# preprocessor definition if [CONSORT_64BIT](#/CONSORT_64BIT) is set. Otherwise
# CONSORT_MACOSX_X86 will be defined as a CMake variable and preprocessor
# definition.

## Variables/CONSORT_LINUX
# Set to 1 if consort detects the build target is Linux. Also adds
# `-DCONSORT_LINUX=1` to the compile definitions.
#
# In addition CONSORT_LINUX_X86_64 will be defined as a CMake variable and
# preprocessor definition if [CONSORT_64BIT](#/CONSORT_64BIT) is set. Otherwise
# CONSORT_LINUX_X86 will be defined as a CMake variable and preprocessor
# definition.

## Variables/CONSORT_PLATFORM_NAME
# * windows-x86_64 for 64 bit Windows
# * windows-x86 for 32 bit Windows
# * macosx-x86_64 for 64 bit Mac OS X
# * macosx-x86 for 32 bit Mac OS X
# * linux-x86_64 for 64 bit Linux
# * linux-x86 for 32 bit Linux

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
