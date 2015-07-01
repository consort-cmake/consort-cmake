# The MIT License (MIT)
# 
# Copyright (c) 2015 Adam Bowen, https://github.com/consort-cmake
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

if(CONSORT_INCLUDED)
	return()
endif()

set(CONSORT_INCLUDED 1)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_LIST_DIR}")

if (NOT CMAKE_SCRIPT_MODE_FILE)
	cmake_policy(PUSH) # prevent cmake_minimum_required from modifying policy as well
endif()
cmake_minimum_required(VERSION 3.0.3)
if (NOT CMAKE_SCRIPT_MODE_FILE)
	cmake_policy(POP)
endif()

# If CGCC_FORCE_COLOR is set, color-gcc will output colour during the configure
# step, which causes CMake's compiler detection to fail.
set(ENV{CGCC_FORCE_COLOR} 0)

# In-source builds pollute the source tree with build artefacts and prevent
# multiple build trees (for example for cross-compilation) from being associated
# with a single source tree. You usually don't want this, so by default consort
# disables them. If you must you can set CONSORT_PERMIT_INSOURCE_BUILDS to ON
# before including consort.cmake to permit in-source builds.

if(NOT CONSORT_PERMIT_INSOURCE_BUILDS)
	string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" _insource)

	if(_insource)
		message(FATAL_ERROR
			"In-source builds are not permitted!\n"
			"You will need to remove CMakeCache.txt and CMakeFiles.\n"
			"To permit in-source builds use -DCONSORT_PERMIT_INSOURCE_BUILDS=ON.\n"
		)
	endif()

	if(EXISTS "${CMAKE_BINARY_DIR}/CMakeLists.txt")
		message(FATAL_ERROR
			"The build directory may not contain a CMakeLists.txt file!\n"
			"You will need to remove CMakeCache.txt and CMakeFiles.\n"
		)
	endif()
endif()

# Builds on NFS partitions will be slow, consort stops you from doing it by
# default. You can set CONSORT_PERMIT_NFS_BUILDS to ON to enable it.

if( CMAKE_HOST_UNIX )
	if( APPLE )
		execute_process(
			COMMAND df -T nfs "${CMAKE_BINARY_DIR}"
			RESULT_VARIABLE BINARY_DIR_IS_NFS_STATUS
			OUTPUT_VARIABLE DF_SENT_TO_NULL
		)

		if("${BINARY_DIR_IS_NFS_STATUS}" STREQUAL "0")
			set(BINARY_DIR_IS_NFS ON)
		else()
			set(BINARY_DIR_IS_NFS OFF)
		endif()
	else()
		execute_process(
			COMMAND stat -f -c %T "${CMAKE_BINARY_DIR}"
			OUTPUT_VARIABLE BINARY_DIR_FS
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)

		if(NOTBINARY_DIR_FS STREQUAL "nfs")
			set(BINARY_DIR_IS_NFS ON)
		else()
			set(BINARY_DIR_IS_NFS OFF)
		endif()
	endif()

	if(BINARY_DIR_IS_NFS)
		if(CONSORT_PERMIT_NFS_BUILDS)
			message( WARNING "Network build directory detected, your build may be slow." )
		else()
			message( FATAL_ERROR
				"Network build directory detected.\n"
				"Please create your build directory on a local file system.\n"
				"To permit network builds use -DCONSORT_PERMIT_NFS_BUILDS=ON.\n"
			)
		endif()
	endif()
endif()

# Tests are good!
enable_testing()

# Allows include paths to be specified relative to the source root
include_directories(${CMAKE_SOURCE_DIR})

set(CONSORT_VERSION 0.1.0)
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

# options for configuring consort, override these settings before you include
# consort.cmake or on the command line

option(CONSORT_ENABLE_ASM "Enable assembler" ON)
option(CONSORT_REQUIRE_ASM "Require assembler (if enabled)" OFF)
option(CONSORT_PERMIT_INSOURCE_BUILDS "Enable in-source builds" OFF)
option(CONSORT_PERMIT_NFS_BUILDS "Enable network builds" OFF)
option(CONSORT_SUPPORT_WINDOWS_XP "Enable support for Windows XP" OFF)
option(CONSORT_VALGRIND_TESTS "Run tests under valgrind on supported platforms" OFF)

if( CONSORT_MACOSX AND CONSORT_CLANG AND CMAKE_SYSTEM_VERSION VERSION_GREATER 12 )
	# For modern versions of OSX default C++11 on to ensure we link to the right
	# C++ runtime.
	option(CONSORT_CXX11 "Enable support for C++11" ON)
else()
	option(CONSORT_CXX11 "Enable support for C++11" OFF)
endif()

# Global variable
set(CONSORT_VALGRIND_SUPPRESSIONS "" CACHE STRING "List of suppression files to use with valgrind" )
# Convert a "name" to a sensible variable name by making it upper case and
# replacing special characters with underscores.
function( co_var_name outvar var )
	string( TOUPPER "${var}" _out )
	string(REGEX REPLACE "[^A-Z0-9_]" "_" _out "${_out}")
	set("${outvar}" "${_out}" PARENT_SCOPE)
endfunction()

# Determine if the list "list" contains the value "value" and set "variable"
# to 1 or 0 appropriately.
function( co_list_contains list value variable )
	set(_l ${list})
	list( FIND _l "${value}" _i )
	if( _i EQUAL -1 )
		set("${variable}" 0 PARENT_SCOPE)
	else()
		set("${variable}" 1 PARENT_SCOPE)
	endif()
endfunction()

# Generic argument parsing macro
#
# co_parse_args(prefix "group name;group name;..." "flag name; flag name;..." arguments...)
#
# Scan "arguments" looking for "flags" (i.e. an exact match for anything in the
# list of flags) or "groups" (anything in the list of group names followed by a
# colon).
#
# For each flag, this function will set a variable in the parent scope to ON or
# OFF depending on whether the flag is defined. The variable will be an
# upper-cased version of the flag name, with the specified prefix. Special
# characters are replaced with an underscore.
#
# For each group, this function will set a variable in the parent scope to a
# list of all the items that follow the group name. The variable will be an
# upper-cased version of the flag name, with the specified prefix. Special
# characters are replaced with an underscore.
#
# Arguments that are not a flag and occur outside of a group are added to the
# ${prefix}_ARGN variable.
#
# Group and flag names are case sensitive!

function( co_parse_args prefix group_names flag_names )

	foreach( group_name ${group_names} )
		co_var_name( group_var "${group_name}" )
		set( _${group_var} "" )
	endforeach()

	foreach( flag_name ${flag_names} )
		co_var_name( flag_var "${flag_name}" )
		set( _${flag_var} OFF )
	endforeach()

	set( _current_group ARGN )

	foreach( arg ${ARGN} )
		string( REGEX MATCH "^(.+):$" looks_like_group ${arg} )
		co_list_contains( "${group_names}" "${CMAKE_MATCH_1}" is_group )
		co_list_contains( "${flag_names}" "${arg}" is_flag )

		if( looks_like_group AND is_group )
			co_var_name( _current_group "${CMAKE_MATCH_1}" )
		elseif( is_flag AND arg )
			co_var_name( flag_var "${arg}" )
			set( _${flag_var} ON )
		else()
			list( APPEND _${_current_group} "${arg}" )
		endif()
	endforeach()

	foreach( var ${group_names} ${flag_names} ARGN )
		co_var_name( var_name "${var}" )
		set( ${prefix}_${var_name} "${_${var_name}}" PARENT_SCOPE )
	endforeach()

endfunction()
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
# co_safe_glob( output_var glob glob ...)
#
# Expand file globs into output_var, generating an error if any glob files to
# expand to any files.
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

if(CONSORT_ENABLE_ASM)
	enable_language(ASM_YASM)

	if(CONSORT_REQUIRE_ASM AND NOT CMAKE_ASM_YASM_COMPILER_WORKS)
		message(SEND_ERROR "Assembler not found, but CONSORT_REQUIRE_ASM is set.")
	endif()
endif()

if(CONSORT_ENABLE_ASM AND CMAKE_ASM_YASM_COMPILER_WORKS)
	set(CONSORT_ASM_ENABLED 1)
else()
	set(CONSORT_ASM_ENABLED 0)
endif()

if(CONSORT_MACOSX OR CONSORT_WINDOWS_X86)
	# OSX and 32-bit windows expect exports to have the _ prefix
	co_add_flags(CMAKE_ASM_YASM_FLAGS --prefix=_)
endif()

function(co_add_asm_dependencies)
	get_directory_property(_defs_list COMPILE_DEFINITIONS)
	set(_defs "")
	foreach(d ${_defs_list})
		set(_defs "${_defs} -D${d}")
	endforeach()
	string(SUBSTRING "${_defs}" 1 -1 _defs)

	foreach(source_file ${ARGN})
		execute_process(
			COMMAND "${CMAKE_ASM_YASM_COMPILER}" -f ${CMAKE_ASM_YASM_OBJECT_FORMAT} ${_defs} -M "${source_file}"
			RESULT_VARIABLE _deps_result
			OUTPUT_VARIABLE _deps
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)

		if(_deps_result EQUAL 0)
			# yasm splits lines with \\\n, so undo that
			string(REPLACE "\\\n" " " _deps "${_deps}")
			# yasm doesn't escape spaces in the path - our workaround is to
			# find an extension followed by a space, and assume that's a
			# separator
			string(REGEX REPLACE "([.][^. /\\\\]+) +" "\\1;" _deps "${_deps}")
			# the first entry is the name of the object file, the second entry
			# is the source file itself
			list(REMOVE_AT _deps 0 1)

			# this will ensure that dependencies trigger rebuilds, however, sadly
			# there is no easy way to trigger a rescan of the dependencies when
			# the file is changed
			set_source_files_properties("${source_file}" PROPERTIES OBJECT_DEPENDS "${_deps}")
		else()
			message(WARNING "Failed to generate dependencies for ${source_file}.")
		endif()
	endforeach()
endfunction()
# Configure warning flags

if( CONSORT_GCC OR CONSORT_CLANG )
	set(CONSORT_SOFT_C_WARNING_FLAGS
		-Wimplicit
		-Wimplicit-function-declaration
	)

	if( CONSORT_GCC )
		set(CONSORT_SOFT_CXX_WARNING_FLAGS
			-Wstrict-null-sentinel
		)
	endif()

	set(CONSORT_SUPPRESS_WARNING_FLAGS)

	set(CONSORT_SOFT_WARNING_FLAGS
		-Wall
		-Wextra
		-Wno-parentheses
		-Wno-sign-compare
		-Wno-unused-parameter
	)

	set(CONSORT_STRICT_WARNING_FLAGS
		-Wall
		-Wextra
		-Wcast-align
		-Wcast-qual
		-Wchar-subscripts
		-Wformat-nonliteral
		-Wformat-security
		-Wformat-y2k
		-Winit-self
		-Winvalid-pch
		-Wmissing-braces
		-Wmissing-field-initializers
		-Wmissing-format-attribute
		-Wmissing-include-dirs
		-Wmultichar
		-Wno-unused-function
		-Wpacked
		-Wparentheses
		-Wpointer-arith
		-Wredundant-decls
		-Wreturn-type
		-Wsequence-point
		-Wshadow
		-Wsign-compare
		-Wswitch
		-Wtrigraphs
		-Wundef
		-Wunused
		-Wunused-label
		-Wunused-parameter
		-Wunused-value
		-Wunused-variable
		-Wvolatile-register-var
		-Wwrite-strings
	)

	set(CONSORT_WARNINGS_ARE_ERRORS
		-Werror
	)

	if(CONSORT_GCC)
		list(APPEND CONSORT_SUPPRESS_WARNING_FLAGS
			-Wno-format-security
		)
		list(APPEND CONSORT_STRICT_WARNING_FLAGS
			-Wconversion
			-Wno-unused-local-typedefs
		)
	endif()

	if(CONSORT_GCC_43)
		list(APPEND CONSORT_STRICT_WARNING_FLAGS
			-Wsign-conversion
			-Wuninitialized
		)
	endif()

	if(CONSORT_GCC AND NOT CONSORT_GCC_45)
		list(APPEND CONSORT_STRICT_WARNING_FLAGS
			-Wno-strict-aliasing
		)
	endif()

	if(CONSORT_GCC_45)
		list(APPEND CONSORT_SUPPRESS_WARNING_FLAGS
			-Wno-unused-result
			-Wformat=0
		)
		list(APPEND CONSORT_SOFT_WARNING_FLAGS
			-Wno-unused-result
		)
	endif()

	if(CONSORT_GCC_46)
		list(APPEND CONSORT_SOFT_WARNING_FLAGS
			-Wno-unused-but-set-variable
		)
	endif()

	if( CONSORT_CLANG )
		list(APPEND CONSORT_SUPPRESS_WARNING_FLAGS
			-Wno-parentheses
			-Wno-unused-value
		)
		list(APPEND CONSORT_STRICT_WARNING_FLAGS
			-Wno-unused-const-variable
		)
	endif()
elseif( CONSORT_MSVC )
	co_remove_flags( CMAKE_C_FLAGS   "/W3" )
	co_remove_flags( CMAKE_CXX_FLAGS "/W3" )

	add_definitions(
		-D_SCL_SECURE_NO_WARNINGS
	)

	set( CONSORT_WARNINGS_ARE_ERRORS  /WX )
	set( CONSORT_SUPPRESS_WARNING_FLAGS )
	set( CONSORT_SOFT_WARNING_FLAGS   /W1 )
	set( CONSORT_STRICT_WARNING_FLAGS /W3 )
endif()

# co_suppress_warnings()
#
# Suppress all warnings
function( co_suppress_warnings )
	set(CONSORT_WARNING_FLAGS "${CONSORT_SUPPRESS_WARNING_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_SOFT_C_WARNING_FLAGS})
	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_STRICT_C_WARNING_FLAGS})
	co_add_flags(CMAKE_C_FLAGS ${CONSORT_SUPPRESS_C_WARNING_FLAGS})
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_SOFT_CXX_WARNING_FLAGS})
	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_STRICT_CXX_WARNING_FLAGS})
	co_add_flags(CMAKE_CXX_FLAGS ${CONSORT_SUPPRESS_CXX_WARNING_FLAGS})
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" PARENT_SCOPE)
endfunction()

# co_soft_warnings()
#
# Apply soft warning flags to this directory and below.
function( co_soft_warnings )
	set(CONSORT_WARNING_FLAGS "${CONSORT_SOFT_WARNING_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_SUPPRESS_C_WARNING_FLAGS})
	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_STRICT_C_WARNING_FLAGS})
	co_add_flags(CMAKE_C_FLAGS ${CONSORT_SOFT_C_WARNING_FLAGS})
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_SUPPRESS_CXX_WARNING_FLAGS})
	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_STRICT_CXX_WARNING_FLAGS})
	co_add_flags(CMAKE_CXX_FLAGS ${CONSORT_SOFT_CXX_WARNING_FLAGS})
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" PARENT_SCOPE)
endfunction()

# co_strict_warnings()
#
# Apply strict warning flags to this directory and below.
function( co_strict_warnings )
	set(CONSORT_WARNING_FLAGS "${CONSORT_STRICT_WARNING_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_SOFT_C_WARNING_FLAGS})
	co_remove_flags(CMAKE_C_FLAGS ${CONSORT_SUPPRESS_C_WARNING_FLAGS})
	co_add_flags(CMAKE_C_FLAGS ${CONSORT_STRICT_C_WARNING_FLAGS})
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" PARENT_SCOPE)

	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_SOFT_CXX_WARNING_FLAGS})
	co_remove_flags(CMAKE_CXX_FLAGS ${CONSORT_SUPPRESS_CXX_WARNING_FLAGS})
	co_add_flags(CMAKE_CXX_FLAGS ${CONSORT_STRICT_CXX_WARNING_FLAGS})
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" PARENT_SCOPE)
endfunction()

# co_warnings_are_errors(ON|OFF)
#
# Set whether or not warnings are errors
function( co_warnings_are_errors flag )
	if(CONSORT_COMPILE_FLAGS)
		list(REMOVE_ITEM CONSORT_COMPILE_FLAGS ${CONSORT_WARNINGS_ARE_ERRORS})
	endif()
	if(CONSORT_ASM_FLAGS)
		list(REMOVE_ITEM CONSORT_ASM_FLAGS -Werror)
	endif()
	if(flag)
		list(APPEND CONSORT_COMPILE_FLAGS ${CONSORT_WARNINGS_ARE_ERRORS})
		list(APPEND CONSORT_ASM_FLAGS -Werror)
	endif()
	set(CONSORT_COMPILE_FLAGS ${CONSORT_COMPILE_FLAGS} PARENT_SCOPE)
	set(CONSORT_ASM_FLAGS ${CONSORT_ASM_FLAGS} PARENT_SCOPE)
endfunction()

# Default to strict mode
co_strict_warnings()
co_warnings_are_errors(ON)
# Configure the build
# generic, default, configuration provided by consort
# override these settings after you have included consort.cmake

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

if( CONSORT_MACOSX AND CONSORT_CLANG AND CMAKE_SYSTEM_VERSION VERSION_GREATER 12 )
	# For modern versions of OSX force c++11 on to ensure we link to the right
	# C++ runtime.
	set(CONSORT_CXX11 ON)
endif()

if(CONSORT_CXX11)
	set(CMAKE_CXX_STANDARD 11)
	if(CONSORT_GCC_47)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++11)
	elseif(CONSORT_GCC_43)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++0x)
	elseif(CONSORT_CLANG)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++11)
		co_add_flags(CMAKE_CXX_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_EXE_LINKER_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_SHARED_LINKER_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_MODULE_LINKER_FLAGS -stdlib=libc++)
		# The version of boost I'm using has an issue with clang's version of this
		add_definitions(-DBOOST_NO_CXX11_NUMERIC_LIMITS)
	endif()

	message( STATUS "C++11 enabled" )
endif()

# NDEBUG is typically used to suppress debugging in release builds, but
# RelWithDebInfo is an explicit request for a release build with debugging
# information so we remove NDEBUG from the command line.
co_remove_flags(CMAKE_CXX_FLAGS_RELWITHDEBINFO -DNDEBUG)
co_remove_flags(CMAKE_C_FLAGS_RELWITHDEBINFO -DNDEBUG)

if( CONSORT_WINDOWS AND CONSORT_SUPPORT_WINDOWS_XP )
	# XP support needs a little magic
	if( CONSORT_MSVC_2013 )
		set(CMAKE_GENERATOR_TOOLSET "v120_xp" CACHE STRING "Generator Toolset" FORCE)
	else()
		add_definitions(-D_ATL_XP_TARGETING)
	endif()
endif()

if( CONSORT_WINDOWS )
	add_definitions(-D_WIN32_WINNT=0x0501)
endif()

if( CONSORT_WINDOWS_X86_64 )
	add_definitions(-D_AMD64_)
endif()

if(CONSORT_64BIT)
	if(CONSORT_GCC OR CONSORT_CLANG)
		# 64 bit platforms omit frame pointers for performance reasons, but this
		# hinders debugging and profiling. The generating expression is bordering
		# on illegible, but it basically adds -fno-omit-frame-pointer for all
		# configurations but Release.
		list(APPEND CONSORT_COMPILE_FLAGS "$<$<NOT:$<CONFIG:Release>>:-fno-omit-frame-pointer>" )
	endif()
endif()

if(CONSORT_MSVC)
	# Allow MSVC to generate large object files (this can happen when you're
	# using a lot of heavy templates)
	list(APPEND CONSORT_COMPILE_FLAGS "/bigobj" "/Zm1000")
endif()


set(CONSORT_COMMON_GROUPS
	sources
	generated-sources
	asm-sources
	generic-sources
	libraries
	qt-modules
	compile-flags
	link-flags
	depends
	output-name
	resources
	ui-sources
	moc-sources
	translations
	tr-sources
	qm-sources
	#definitions
	#version
	#version_file
	#namespace
	#output_name
	#product_name
	#internal_name
	#family_name
	#company_name
	#copyright
	#qt_sources
	#gui_sources
	#translations
	#tr_sources
	#qm_sources
	#exports
	#pch
	#share_pch
	#cotire_exclude
)

set( CONSORT_COMMON_FLAGS
	automoc
	autouic
	#no_strip
	#autopch
	#unity
	#no_version_symlink
)


function( co_process_common_args target )
	if( THIS_AUTOMOC )
		set_target_properties( "${target}" PROPERTIES AUTOMOC TRUE )
	endif()

	if( THIS_AUTOUIC )
		set_target_properties( "${target}" PROPERTIES AUTOUIC TRUE )
	endif()

	if( THIS_LIBRARIES )
		target_link_libraries( "${target}" ${THIS_LIBRARIES})

		foreach(l ${THIS_LIBRARIES})
			co_var_name(v "${l}")
			if(DEFINED "CONSORT_MODULE_${v}_PATH")
				co_require_module("${l}")
			endif()
		endforeach()
	endif()

	if( THIS_ASM_SOURCES AND CONSORT_ASM_ENABLED )
		co_safe_glob( THIS_ASM_SOURCES ${THIS_ASM_SOURCES} )
		add_library("${target}-asm" STATIC ${THIS_ASM_SOURCES})
		target_compile_options("${target}-asm" PRIVATE ${CONSORT_ASM_FLAGS})
		target_link_libraries("${target}" "${target}-asm")
		co_add_asm_dependencies(${THIS_ASM_SOURCES})
	endif()

	if( THIS_GENERIC_SOURCES AND NOT CONSORT_ASM_ENABLED )
		co_safe_glob( THIS_GENERIC_SOURCES ${THIS_GENERIC_SOURCES} )
		add_library("${target}-generic" STATIC ${THIS_GENERIC_SOURCES})
		target_link_libraries("${target}" "${target}-generic")
	endif()

	get_target_property( _sources ${name} SOURCES )

	target_compile_options( ${name} PRIVATE
		${CONSORT_COMPILE_FLAGS}
		${CONSORT_WARNING_FLAGS}
		${THIS_COMPILE_FLAGS}
	)

	# VS2013 uses a more modern version of the Windows SDK, which is not supported
	# on XP. XP support can be enabled by explicitly specifying the SDK version
	# and not calling any of the unsupported routines.
	if( CONSORT_MSVC AND CONSORT_SUPPORT_WINDOWS_XP AND CMAKE_CXX_COMPILER_VERSION GREATER 18 )
		if(THIS_GUI) # set for GUI exe targets (not a 'common' flag)
			if( CONSORT_64BIT )
				list(APPEND THIS_LINK_FLAGS "/SUBSYSTEM:WINDOWS,5.02")
			else()
				list(APPEND THIS_LINK_FLAGS "/SUBSYSTEM:WINDOWS,5.01")
			endif()
		else()
			if( CONSORT_64BIT )
				list(APPEND THIS_LINK_FLAGS "/SUBSYSTEM:CONSOLE,5.02")
			else()
				list(APPEND THIS_LINK_FLAGS "/SUBSYSTEM:CONSOLE,5.01")
			endif()
		endif()
 	endif()

	string(REPLACE ";" " " THIS_LINK_FLAGS "${THIS_LINK_FLAGS}")
	set_target_properties( ${target} PROPERTIES
		LINK_FLAGS "${CONSORT_LINK_FLAGS} ${THIS_LINK_FLAGS}"
	)

	if(THIS_DEPENDS)
		add_dependencies( ${target} ${THIS_DEPENDS} )
	endif()

	if( THIS_OUTPUT_NAME )
		set_target_properties( ${target} PROPERTIES OUTPUT_NAME ${THIS_OUTPUT_NAME} )
	endif()

	if( THIS_QT_MODULES )
		if( QT_FOUND )
			QT_USE_MODULES(${target} ${THIS_QT_MODULES})
		else()
			message(SEND_ERROR
				"Target ${name} requires Qt, but Qt was not found.\n"
				"Try adding co_enable_default_qt() to your CMakeLists.txt."
			)
		endif()
	endif()

	if( THIS_UI_SOURCES )
		target_include_directories("${target}" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
	endif()
endfunction()
function(co_exe name)
	co_parse_args( THIS "${CONSORT_COMMON_GROUPS}" "${CONSORT_COMMON_FLAGS};gui" ${ARGN} )
	set(THIS_NAME "${name}")

	co_safe_glob( THIS_SOURCES ${THIS_SOURCES} )

	co_process_qt_args( ${THIS_NAME} )

	add_executable(
		${THIS_NAME}
		${THIS_SOURCES}
		${THIS_GENERATED_SOURCES}
	)

	if( THIS_GUI )
		set_target_properties( ${THIS_NAME} PROPERTIES WIN32_EXECUTABLE true )
	endif()

	co_process_common_args( ${THIS_NAME} )

endfunction()
function(co_lib name)
	co_parse_args( THIS "${CONSORT_COMMON_GROUPS}" "${CONSORT_COMMON_FLAGS}" ${ARGN} )
	set(THIS_NAME "${name}")

	co_safe_glob( THIS_SOURCES ${THIS_SOURCES} )

	co_process_qt_args( ${THIS_NAME} )

	if( NOT THIS_SOURCES AND NOT THIS_GENERATED_SOURCES )
		set( _source "${CMAKE_CURRENT_BINARY_DIR}/${name}.c" )
		if(NOT EXISTS "${_source}")
			file(WRITE "${_source}" "static void null_lib() {}\n" )
		endif()

		list(APPEND THIS_SOURCES "${_source}")
	endif()

	add_library(
		${THIS_NAME} STATIC
		${THIS_SOURCES}
		${THIS_GENERATED_SOURCES}
	)

	co_process_common_args( ${THIS_NAME} )

endfunction()
function(co_dll name)
	co_parse_args( THIS "${CONSORT_COMMON_GROUPS}" "${CONSORT_COMMON_FLAGS}" ${ARGN} )
	set(THIS_NAME "${name}")

	co_safe_glob( THIS_SOURCES ${THIS_SOURCES} )

	co_process_qt_args( ${THIS_NAME} )

	if( NOT THIS_SOURCES AND NOT THIS_GENERATED_SOURCES )
		set( _source "${CMAKE_CURRENT_BINARY_DIR}/${name}.c" )
		if(NOT EXISTS "${_source}")
			file(WRITE "${_source}" "static void null_lib() {}\n" )
		endif()

		list(APPEND THIS_SOURCES "${_source}")
	endif()

	add_library(
		${THIS_NAME} SHARED
		${THIS_SOURCES}
		${THIS_GENERATED_SOURCES}
	)

	co_process_common_args( ${THIS_NAME} )

endfunction()
# co_find_modules( path )
#
# Find consort modules located in the specified directory (relative to
# CMAKE_CURRENT_SOURCE_DIR). A consort module is a subdirectory of path that
# contains a module.cmake file. The module.cmake file will be included.

function(co_find_modules path)
	if(CONSORT_DEBUG GREATER 0)
		message("Consort searching for modules under ${path}")
	endif()
	file(GLOB _paths "${CMAKE_CURRENT_SOURCE_DIR}/${path}/*")
	foreach(_path ${_paths})
		if(IS_DIRECTORY "${_path}" AND EXISTS "${_path}/module.cmake")
			include("${_path}/module.cmake")
		endif()
	endforeach()

	set(CONSORT_MODULES ${CONSORT_MODULES} PARENT_SCOPE)
endfunction()

# co_module( name
#     [directory: (relative path to module directory)]
#     [aliases: alias alias ...]
# )
#
# Declare a Consort module
#

function(co_module name)
	co_parse_args(MODULE "directory;aliases" "" ${ARGN})
	if(NOT MODULE_DIRECTORY)
		set(path "${CMAKE_CURRENT_LIST_DIR}/${MODULE_DIRECTORY}")
	else()
		set(path "${CMAKE_CURRENT_LIST_DIR}")
	endif()

	foreach(_alias ${name} ${MODULE_ALIASES})
		co_var_name(_alias_var "${_alias}")
		co_list_contains("${CONSORT_MODULES}" "${_alias}" _exists)
		if(_exists)
			message(SEND_ERROR "Module ${_alias} conflicts with a module defined at ${CONSORT_MODULE_${_alias_var}_PATH}")
		else()
			set("CONSORT_MODULE_${_alias_var}_PATH" "${path}" CACHE INTERNAL "path to a module")
			list(APPEND CONSORT_MODULES "${_alias}")
		endif()
	endforeach()

	set(CONSORT_MODULES ${CONSORT_MODULES} PARENT_SCOPE)

	if(CONSORT_DEBUG GREATER 1)
		message("Module ${name} registered")
	endif()
endfunction()




# co_require_module( name )
#
# Add the specified module to the list of modules Consort will enable
#
set( CONSORT_ACTIVE_MODULES "" CACHE INTERNAL "enabled modules" )
function(co_require_module name)
	co_list_contains("${CONSORT_MODULES}" "${name}" _is_module)
	if(_is_module)
		co_list_contains("${CONSORT_ACTIVE_MODULES}" "${name}" _is_active)
		if(NOT _is_active)
			set( CONSORT_ACTIVE_MODULES ${CONSORT_ACTIVE_MODULES} "${name}" CACHE INTERNAL "enabled modules" )
		endif()
	else()
		co_stack_trace()
		message(
			SEND_ERROR
			"Unknown module ${name}"
		)
	endif()
endfunction()

# co_include_modules()
#
# call add_subdirectory for every active module, if any modules are added to the
# active list, add_subdirectory will also be called for those modules.
set( CONSORT_ACTIVATED_MODULES "" CACHE INTERNAL "activated modules" )
function(co_include_modules)

	set( _included_count 0 )
	set( _activated_count 0 )
	list(LENGTH CONSORT_ACTIVE_MODULES _active_count)

	while( NOT _included_count EQUAL _active_count )
		foreach( m ${CONSORT_ACTIVE_MODULES} )
			co_var_name(_m_var "${m}")
			if( DEFINED CONSORT_MODULE_${_m_var}_PATH)
				set(_m_path "${CONSORT_MODULE_${_m_var}_PATH}")

				co_list_contains("${CONSORT_ACTIVATED_MODULES}" "${_m_path}" _activated)

				if( NOT _activated )
					add_subdirectory("${_m_path}")
					set(CONSORT_ACTIVATED_MODULES ${CONSORT_ACTIVATED_MODULES} "${_m_path}" CACHE INTERNAL "activated modules")
					math(EXPR _activated_count "${_activated_count} + 1")
				endif()
			else()
				message(
					SEND_ERROR
					"Unknown module ${m}"
				)
			endif()
		endforeach()

		set(_included_count "${_active_count}")
		list(LENGTH CONSORT_ACTIVE_MODULES _active_count)
	endwhile()

	if( _activated_count EQUAL 1)
		message("-- Consort activated ${_activated_count} module")
	else()
		message("-- Consort activated ${_activated_count} modules")
	endif()
endfunction()
# co_link(target link)
#
# Create a symbolic link (or junction on Windows) at "link" that points to
# "target".
function(co_link target link)
	if( NOT EXISTS "${link}" )
		get_filename_component(_parent "${link}" DIRECTORY)
		file(MAKE_DIRECTORY "${_parent}")

		if( CMAKE_HOST_UNIX )
			message( "  Linking ${link} to ${target}" )
			execute_process(
				COMMAND ${CMAKE_COMMAND}
				-E create_symlink
				"${target}"
				"${link}"
			)
		elseif( CMAKE_HOST_WIN32 )
			message( "  Linking ${link} to ${target}" )
			string(REPLACE "/" "\\" _target "${target}" )
			string(REPLACE "/" "\\" _link "${link}" )
			if(IS_DIRECTORY "${target}")
				execute_process(COMMAND "cmd" "/c" "mklink /j ${_link} ${_target}")
			else()
				execute_process(COMMAND "cmd" "/c" "mklink ${_link} ${_target}")
			endif()
		else()
			message(WARNING
				"Consort does not support symbolic links on this platform.\n"
				"Please manually link\n"
				"    ${link}\n"
				"to\n"
				"    ${target}"
			)
		endif()
	endif()
endfunction()
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
if(CONSORT_VALGRIND_TESTS)
	find_program( VALGRIND NAMES valgrind )

	if(NOT VALGRIND)
		message(SEND_ERROR "CONSORT_VALGRIND_TESTS set, but valgrind was not found")
	endif()
endif()

# co_test(
#    target-name arg arg...
#    command: ...
#    working-directory: ...
#    configurations: ...
#    suppressions: ...
#    no-valgrind
# )
#
# Mark target-name as a test suite for ctest to run. The configurations option
# can be used to indicate the test should only be run for particular build
# configurations. The suppressions option can be used to add suppression files
# when the test is run under valgrind and the no-valgrind option can be used
# to indicate the test should not be run under valgrind.
#
# The command option can be used to run the test within a specific environment,
# e.g. under xvfb for test suites that require an X frame buffer but need to be
# able to run headless.
#
# The working-directory option can be used to specify a working directory for
# the test.
function( co_test name )
	co_parse_args( THIS "configurations;suppressions;command;working-directory" "no-valgrind" ${ARGN} )

	set(_valgrind_opts "--error-exitcode=1" "--leak-check=full")
	foreach( s ${CONSORT_VALGRIND_SUPPRESSIONS} )
		list(APPEND _valgrind_opts "--suppressions=${s}")
	endforeach()
	foreach( s ${THIS_SUPPRESSIONS} )
		list(APPEND _valgrind_opts "--suppressions=${s}")
	endforeach()

	if(THIS_WORKING_DIRECTORY)
		set( THIS_WORKING_DIRECTORY "WORKING_DIRECTORY" ${THIS_CONFIGURATIONS} )

	if( CONSORT_MULTICONFIG_BUILD )
		if(NOT THIS_CONFIGURATIONS)
			set(THIS_CONFIGURATIONS Debug Release RelWithDebInfo MinSizeRel)
		endif()
		foreach( config ${THIS_CONFIGURATIONS} )
			string( TOUPPER ${config} uconfig )
			string( TOLOWER ${config} lconfig )
			if( CONSORT_VALGRIND_TESTS AND VALGRIND AND NOT THIS_NO_VALGRIND )
				add_test(
					NAME run-${name}-${lconfig}
					CONFIGURATIONS ${config}
					${THIS_WORKING_DIRECTORY}
					COMMAND ${THIS_COMMAND}
					${VALGRIND}
					${_valgrind_opts}
					$<TARGET_FILE:${name}>
					${THIS_ARGN}
				)
			else()
				add_test(
					NAME run-${name}-${lconfig}
					CONFIGURATIONS ${config}
					${THIS_WORKING_DIRECTORY}
					COMMAND ${THIS_COMMAND}
					$<TARGET_FILE:${name}>
					${THIS_ARGN}
				)
			endif()
		endforeach()
	else()
		if( THIS_CONFIGURATIONS )
			set( THIS_CONFIGURATIONS "CONFIGURATIONS" ${THIS_CONFIGURATIONS} )
		endif()
		string( TOUPPER ${CMAKE_BUILD_TYPE} uconfig )

		if( CONSORT_VALGRIND_TESTS AND VALGRIND AND NOT THIS_NO_VALGRIND )
			add_test(
				NAME run-${name}
				${THIS_CONFIGURATIONS}
				${THIS_WORKING_DIRECTORY}
				COMMAND ${THIS_COMMAND}
				${VALGRIND}
				${_valgrind_opts}
				$<TARGET_FILE:${name}>
				${THIS_ARGN}
			)
		else()
			add_test(
				NAME run-${name}
				${THIS_CONFIGURATIONS}
				${THIS_WORKING_DIRECTORY}
				COMMAND ${THIS_COMMAND}
				$<TARGET_FILE:${name}>
				${THIS_ARGN}
			)
		endif()
	endif()
endfunction()

# Define a list of directories to search for boost, Consort will automatically
# add these directories to locations to search for Boost.
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

# co_enable_boost(version component component...)
#
# Enable support for Boost, you should specify the version of boost you are
# developing against and a list of boost libraries to find.
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

# co_enable_default_boost(component component...)
#
# Enable the boost version and libraries that Consort uses by default.
# By default Consort requests boost 1.58 (the most recent at time of writing)
# and the most frequently used libraries.
#
# You may specify additional components to load as arguments to this function.
#
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
# Define a list of directories to search for boost, Consort will automatically
# add these directories to locations to search for Boost.
set(CONSORT_QT5_LOCATIONS "")
if(CONSORT_WINDOWS)
	list(APPEND CONSORT_QT5_LOCATIONS
		"c:/opt/qt5/${CONSORT_PLATFORM_NAME}"
		"c:/qt5/${CONSORT_PLATFORM_NAME}"
		"c:/opt/qt/${CONSORT_PLATFORM_NAME}"
		"c:/qt/${CONSORT_PLATFORM_NAME}"
		"c:/opt/qt"
		"c:/qt"
	)
endif()
if(CONSORT_LINUX OR CONSORT_MACOSX)
	list(APPEND CONSORT_QT5_LOCATIONS
		"/opt/qt5/${CONSORT_PLATFORM_NAME}"
		"/opt/qt5"
		"/opt/qt/${CONSORT_PLATFORM_NAME}"
		"/opt/qt"
	)
endif()


# co_enable_qt(module module...)
#
# Find and enable support for Qt5
macro(co_enable_qt5)
	if(NOT QT_ROOT)
		if(CONSORT_GCC AND CONSORT_64BIT)
			set(_qt_suffix gcc_64)
		elseif(CONSORT_GCC)
			set(_qt_suffix gcc)
		elseif(CONSORT_CLANG AND CONSORT_64BIT)
			set(_qt_suffix clang_64)
		elseif(CONSORT_CLANG)
			set(_qt_suffix clang)
		elseif(CONSORT_MSVC2013)
			set(_qt_suffix msvc2013)
		elseif(CONSORT_MSVC2012)
			set(_qt_suffix msvc2012)
		elseif(CONSORT_MSVC2010)
			set(_qt_suffix msvc2010)
		else()
			set(_qt_suffix *)
			message(SEND_ERROR "Compiler not supported by co_enable_qt.")
		endif()

		set(_search_dirs)
		foreach(_dir ${CONSORT_QT5_LOCATIONS})
			if(EXISTS "${_dir}")
				file( GLOB _dirs "${_dir}/5.*/${_qt_suffix}")
				list( SORT _dirs )
				list( REVERSE _dirs )
				list(APPEND _search_dirs ${_dirs})
			endif()
		endforeach()

		find_path(
			QT_ROOT
			NAMES lib/cmake/Qt5/Qt5Config.cmake
			HINTS ${_search_dirs}
			NO_DEFAULT_PATH
		)
	endif()

	if( QT_ROOT )
		if( NOT EXISTS "${QT_ROOT}" )
			message( SEND_ERROR "Qt5 directory ${QT_ROOT} does not exist" )
		endif()
		file( GLOB _qt_modules ${QT_ROOT}/lib/cmake/* )

		foreach( _qt_module ${_qt_modules})
			get_filename_component(_name ${_qt_module} NAME)
			set("${_name}_DIR" "${_qt_module}")
		endforeach()

		find_package(Qt5Core REQUIRED)
		find_package(Qt5LinguistTools REQUIRED)
		find_package(Qt5Designer REQUIRED)
		if( UNIX )
			find_package(Qt5DBus)
		endif()

		set(_modules ${ARGN})
		if(Qt5Core_VERSION_STRING VERSION_LESS "5.4" AND _modules)
			list(REMOVE_ITEM _modules WebChannel)
		endif()

		foreach(m ${_modules})
			find_package(Qt5${m} REQUIRED)
		endforeach()

		# Some distributions don't find the SVG plugin correctly
		if (Qt5Gui_FOUND AND NOT Qt5Gui_PLUGINS MATCHES ".*Qt5::QSvgPlugin.*")
			add_library(Qt5::QSvgPlugin MODULE IMPORTED)
			_populate_Gui_plugin_properties(QSvgPlugin RELEASE "imageformats/${CMAKE_SHARED_LIBRARY_PREFIX}qsvg${CMAKE_SHARED_LIBRARY_SUFFIX}")
			_populate_Gui_plugin_properties(QSvgPlugin DEBUG "imageformats/${CMAKE_SHARED_LIBRARY_PREFIX}qsvg${CMAKE_SHARED_LIBRARY_SUFFIX}")
			list(APPEND Qt5Gui_PLUGINS Qt5::QSvgPlugin)
		endif()

		if(Qt5Core_FOUND)
			set( QT5_FOUND 1 )
			set( QT_FOUND 1 )
			set( CMAKE_AUTORCC 1 )

			message(STATUS "Qt version: ${Qt5Core_VERSION_STRING} (${QT_ROOT})")

			if( NOT QT_TRANSLATIONS_DIR)
				get_target_property(QT_QMAKE_EXECUTABLE Qt5::qmake IMPORTED_LOCATION)
				exec_program(
					${QT_QMAKE_EXECUTABLE} ARGS "-query QT_INSTALL_TRANSLATIONS"
					OUTPUT_VARIABLE QT_TRANSLATIONS_DIR
				)
				file(TO_CMAKE_PATH "${QT_TRANSLATIONS_DIR}" QT_TRANSLATIONS_DIR)
				set(QT_TRANSLATIONS_DIR ${QT_TRANSLATIONS_DIR} CACHE PATH "The location of qt translations")
			endif()

			# Ensure these are always set
			if(NOT Qt5PrintSupportPluginsLocation AND _qt5PrintSupport_install_prefix)
				set(Qt5PrintSupportPluginsLocation "${_qt5PrintSupport_install_prefix}/plugins/printsupport" )
			endif()
			if(NOT Qt5ImageFormatPluginsLocation AND _qt5Gui_install_prefix)
				set(Qt5ImageFormatPluginsLocation "${_qt5Gui_install_prefix}/plugins/imageformats" )
			endif()
			if(NOT Qt5PlatformsPluginsLocation AND _qt5Gui_install_prefix)
				set(Qt5PlatformsPluginsLocation "${_qt5Gui_install_prefix}/plugins/platforms" )
			endif()
			if(NOT Qt5SqlPluginsLocation AND _qt5Sql_install_prefix)
				set(Qt5SqlPluginsLocation "${_qt5Sql_install_prefix}/plugins/sqldrivers" )
			endif()

			# Link plugin directories into the runtime directory
			if(Qt5PrintSupportPluginsLocation)
				co_runtime_link("${Qt5PrintSupportPluginsLocation}" printsupport)
			endif()
			if(Qt5ImageFormatPluginsLocation)
				co_runtime_link("${Qt5ImageFormatPluginsLocation}" imageformats)
			endif()
			if(Qt5PlatformsPluginsLocation)
				co_runtime_link("${Qt5PlatformsPluginsLocation}" platforms)
			endif()
			if(Qt5SqlPluginsLocation)
				co_runtime_link("${Qt5SqlPluginsLocation}" sqldrivers)
			endif()

			# Some versions of Qt don't set this
			if(NOT Qt5PrintSupport_PLUGINS AND Qt5PrintSupportPluginsLocation)
				file(GLOB
					Qt5PrintSupport_PLUGINS
					"${Qt5PrintSupportPluginsLocation}/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
				)
				file(GLOB
					Qt5PrintSupport_PLUGINS_DEBUG
					"${Qt5PrintSupportPluginsLocation}/${CMAKE_SHARED_LIBRARY_PREFIX}*_debug${CMAKE_SHARED_LIBRARY_SUFFIX}"
				)
				list(REMOVE_ITEM Qt5PrintSupport_PLUGINS ${Qt5PrintSupport_PLUGINS_DEBUG})
			endif()

			set( QT_REDISTRIBUTABLES "" )
			if( WIN32 )
				file(GLOB _icu "${_qt5Core_install_prefix}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}icu*${CMAKE_SHARED_LIBRARY_SUFFIX}")
				co_runtime_dll(${_icu})

				foreach( _lib Core ${_modules})
					string(TOUPPER "${_lib}" _LIB)

					get_target_property("QT_QT${_LIB}_SHARED_LIBRARY" "Qt5::${_lib}" LOCATION)
					co_runtime_dll("${QT_QT${_LIB}_SHARED_LIBRARY}")

					get_filename_component(_path "${QT_QT${_LIB}_SHARED_LIBRARY}" PATH)
					get_filename_component(_name "${QT_QT${_LIB}_SHARED_LIBRARY}" NAME_WE)
					co_runtime_dll("${_path}/${_name}d.dll")
				endforeach()
			endif()

			add_definitions(-DCONSORT_QT5)

			if(APPLE)
				find_program(MACDEPLOYQT NAMES macdeployqt PATHS "${QT_ROOT}/bin")
			endif()
		endif()
	endif()
endmacro()

# co_enable_default_qt5(module module...)
#
# Find and enable support for Qt5. This macro will use the default list of
# modules provided by Consort, you can add additional modules if necessary.
#
macro(co_enable_default_qt5)
	co_enable_qt5(
		Gui
		Widgets
		Network
		WebKit
		WebKitWidgets
		WebChannel
		Sql
		Svg
		OpenGL
		Concurrent
		Multimedia
		PrintSupport
		MultimediaWidgets
		Positioning
		Qml
		Quick
		Sensors
		${ARGN}
	)
endmacro()

# co_write_file_if_changed( filename content )
#
# Ensure "filename" contains "content", but do not touch the file if it is not
# necessary. Useful for generating output files, without triggering rebuilds
# when cmake is run.
#
function( co_write_file_if_changed filename content )
	if( EXISTS "${filename}" )
		file(READ "${filename}" _current)

		if( NOT _current STREQUAL content )
			file(WRITE "${filename}" "${content}")
		endif()
	else()
		file(WRITE "${filename}" "${content}")
	endif()
endfunction()


function(co_add_resources outfiles )
	# This function is adapted from QT5_CREATE_TRANSLATION in
	# Qt5CoreMacros.cmake, it is subject to the following licence:
	#
	#=============================================================================
	# Copyright 2005-2011 Kitware, Inc.
	# All rights reserved.
	#
	# Redistribution and use in source and binary forms, with or without
	# modification, are permitted provided that the following conditions
	# are met:
	#
	# * Redistributions of source code must retain the above copyright
	#   notice, this list of conditions and the following disclaimer.
	#
	# * Redistributions in binary form must reproduce the above copyright
	#   notice, this list of conditions and the following disclaimer in the
	#   documentation and/or other materials provided with the distribution.
	#
	# * Neither the name of Kitware, Inc. nor the names of its
	#   contributors may be used to endorse or promote products derived
	#   from this software without specific prior written permission.
	#
	# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#=============================================================================
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(_RCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(rcc_files ${_RCC_UNPARSED_ARGUMENTS})
    set(rcc_options ${_RCC_OPTIONS})

    foreach(it ${rcc_files})
        get_filename_component(outfilename ${it} NAME_WE)
        get_filename_component(infile ${it} ABSOLUTE)
        get_filename_component(rc_path ${infile} PATH)
        set(outfile ${CMAKE_CURRENT_BINARY_DIR}/qrc_${outfilename}.cpp)

        set(_RC_DEPENDS)
        if(EXISTS "${infile}")
            #  parse file for dependencies
            #  all files are absolute paths or relative to the location of the qrc file
            file(READ "${infile}" _RC_FILE_CONTENTS)
            string(REGEX MATCHALL "<file[^<]+" _RC_FILES "${_RC_FILE_CONTENTS}")
            foreach(_RC_FILE ${_RC_FILES})
                string(REGEX REPLACE "^<file[^>]*>" "" _RC_FILE "${_RC_FILE}")
                if(NOT IS_ABSOLUTE "${_RC_FILE}")
                    set(_RC_FILE "${rc_path}/${_RC_FILE}")
                endif()
                set(_RC_DEPENDS ${_RC_DEPENDS} "${_RC_FILE}")
            endforeach()
            # Since this cmake macro is doing the dependency scanning for these files,
            # let's make a configured file and add it as a dependency so cmake is run
            # again when dependencies need to be recomputed.
            qt5_make_output_file("${infile}" "" "qrc.depends" out_depends)
            # The only change is here, my version of Qt uses COPY_ONLY which is
            # incorrect!
            configure_file("${infile}" "${out_depends}" COPYONLY)
        else()
            # The .qrc file does not exist (yet). Let's add a dependency and hope
            # that it will be generated later
            set(out_depends)
        endif()

        add_custom_command(OUTPUT ${outfile}
                           COMMAND ${Qt5Core_RCC_EXECUTABLE}
                           ARGS ${rcc_options} -name ${outfilename} -o ${outfile} ${infile}
                           MAIN_DEPENDENCY ${infile}
                           DEPENDS ${_RC_DEPENDS} "${out_depends}" VERBATIM)
        list(APPEND ${outfiles} ${outfile})
    endforeach()
    set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()

function(co_create_translation _qm_files)
	# This function is adapted from QT5_CREATE_TRANSLATION in
	# Qt5LinguistToolsMacros.cmake, it is subject to the following licence:
	#
	#=============================================================================
	# Copyright 2005-2011 Kitware, Inc.
	# All rights reserved.
	#
	# Redistribution and use in source and binary forms, with or without
	# modification, are permitted provided that the following conditions
	# are met:
	#
	# * Redistributions of source code must retain the above copyright
	#   notice, this list of conditions and the following disclaimer.
	#
	# * Redistributions in binary form must reproduce the above copyright
	#   notice, this list of conditions and the following disclaimer in the
	#   documentation and/or other materials provided with the distribution.
	#
	# * Neither the name of Kitware, Inc. nor the names of its
	#   contributors may be used to endorse or promote products derived
	#   from this software without specific prior written permission.
	#
	# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#=============================================================================
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(_LUPDATE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(_lupdate_files ${_LUPDATE_UNPARSED_ARGUMENTS})
    set(_lupdate_options ${_LUPDATE_OPTIONS})

    set(_my_sources)
    set(_my_tsfiles)
    foreach(_file ${_lupdate_files})
        get_filename_component(_ext ${_file} EXT)
        get_filename_component(_abs_FILE ${_file} ABSOLUTE)
        if(_ext MATCHES "ts")
            list(APPEND _my_tsfiles ${_abs_FILE})
        else()
            list(APPEND _my_sources ${_abs_FILE})
        endif()
    endforeach()
    foreach(_ts_file ${_my_tsfiles})
        if(_my_sources)
          # make a list file to call lupdate on, so we don't make our commands too
          # long for some systems
          get_filename_component(_ts_name ${_ts_file} NAME_WE)
          set(_ts_lst_file "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_ts_name}_lst_file")
          set(_lst_file_srcs)
          foreach(_lst_file_src ${_my_sources})
              set(_lst_file_srcs "${_lst_file_src}\n${_lst_file_srcs}")
          endforeach()

          get_directory_property(_inc_DIRS INCLUDE_DIRECTORIES)
          foreach(_pro_include ${_inc_DIRS})
              get_filename_component(_abs_include "${_pro_include}" ABSOLUTE)
              set(_lst_file_srcs "-I${_pro_include}\n${_lst_file_srcs}")
          endforeach()

          # The only change is to use co_write_file_if_changed to write the file
          # to ensure running cmake doesn't trigger unnecessary rebuilds.
          co_write_file_if_changed(${_ts_lst_file} "${_lst_file_srcs}")
        endif()
        add_custom_command(OUTPUT ${_ts_file}
            COMMAND ${Qt5_LUPDATE_EXECUTABLE}
            ARGS ${_lupdate_options} "@${_ts_lst_file}" -ts ${_ts_file}
            DEPENDS ${_my_sources} ${_ts_lst_file} VERBATIM)
    endforeach()
    qt5_add_translation(${_qm_files} ${_my_tsfiles})
    set(${_qm_files} ${${_qm_files}} PARENT_SCOPE)
endfunction()

macro( QT_WRAP_UI )
	QT5_WRAP_UI(${ARGN})
endmacro()

macro( QT_WRAP_CPP )
	QT5_WRAP_CPP(${ARGN})
endmacro()

macro( QT_WRAP_CPP )
	QT5_WRAP_CPP(${ARGN})
endmacro()

macro( QT_CREATE_TRANSLATION )
	QT5_CREATE_TRANSLATION(${ARGN})
endmacro()

macro( QT_ADD_TRANSLATION )
	QT5_ADD_TRANSLATION(${ARGN})
endmacro()

macro( QT_ADD_RESOURCES )
	QT5_ADD_RESOURCES(${ARGN})
endmacro()

macro( QT_USE_MODULES )
	foreach( m ${THIS_QT_MODULES} )
		target_link_libraries(${name} "Qt5::${m}")
	endforeach()
endmacro()

# co_process_qt_args(target)
#
# Adjust properties of target as necessary to add Qt support. Note that this
# macro needs to be called before target is declared.
#
macro(co_process_qt_args target)
	set(THIS_TRANSLATION_SOURCES
		${THIS_SOURCES}
		${THIS_GENERATED_SOURCES}
	)

	if( THIS_MOC_SOURCES )
		co_safe_glob( THIS_MOC_SOURCES ${THIS_MOC_SOURCES} )
		QT_WRAP_CPP( THIS_GENERATED_MOC_SOURCES ${THIS_MOC_SOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_MOC_SOURCES})
	endif()

	if( THIS_UI_SOURCES )
		co_safe_glob( THIS_UI_SOURCES ${THIS_UI_SOURCES} )
		QT_WRAP_UI( THIS_GENERATED_UI_SOURCES ${THIS_UI_SOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_UI_SOURCES})
		list(APPEND THIS_TRANSLATION_SOURCES ${THIS_UI_SOURCES})
	endif()

	if( THIS_TRANSLATIONS AND THIS_TRANSLATION_SOURCES )
		co_create_translation( _files ${THIS_TRANSLATIONS} ${THIS_TRANSLATION_SOURCES} OPTIONS -silent )
		list(APPEND THIS_QM_SOURCES ${_files})
		list(APPEND THIS_GENERATED_SOURCES ${_files})
	endif()

	if( THIS_TR_SOURCES )
		QT_ADD_TRANSLATION( _files ${THIS_TR_SOURCES} )
		list(APPEND THIS_QM_SOURCES ${_files})
		list(APPEND THIS_GENERATED_SOURCES ${_files})
	endif()

	if( THIS_QM_SOURCES )
		set( _resource_file "<RCC><qresource prefix=\"/translations\">" )
		foreach( qm ${THIS_QM_SOURCES} )
			get_filename_component(qm_file ${qm} NAME)
			set( _resource_file "${_resource_file}<file alias=\"${qm_file}\">${qm}</file>")
		endforeach()
		set( _resource_file "${_resource_file}</qresource></RCC>")

		co_write_file_if_changed(${CMAKE_CURRENT_BINARY_DIR}/${target}_translations.qrc "${_resource_file}")

		list(APPEND THIS_RESOURCES ${CMAKE_CURRENT_BINARY_DIR}/${target}_translations.qrc)
	endif()

	if( THIS_RESOURCES )
		co_safe_glob( THIS_RESOURCES ${THIS_RESOURCES} )
		co_add_resources( THIS_GENERATED_RESOURCES ${THIS_RESOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_RESOURCES})
	endif()

endmacro()
