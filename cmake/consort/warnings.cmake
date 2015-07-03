# Configure warning flags

## Warnings/CONSORT_SOFT_C_WARNING_FLAGS
# List of flags Consort will add when soft warnings are enabled for C source files.

## Warnings/CONSORT_SOFT_CXX_WARNING_FLAGS
# List of flags Consort will add when soft warnings are enabled for C++# source files.

## Warnings/CONSORT_SOFT_WARNING_FLAGS
# List of flags Consort will add when soft warnings are enabled.

## Warnings/CONSORT_STRICT_WARNING_FLAGS
# List of flags Consort will add when strict warnings are enabled.

## Warnings/CONSORT_SUPPRESS_WARNING_FLAGS
# List of flags Consort will add when warnings are suppressed.

## Warnings/CONSORT_WARNINGS_ARE_ERRORS
# Flags Consort will add when [co_warnings_are_errors](#/co_warnings_are_errors)
# is set to ON.

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

## Warnings/co_suppress_warnings
# ```
# co_suppress_warnings()
# ```
#
# Suppress all warnings from targets in the current directory and below.
#
# Consort provides three levels of warning, with appropriate flags set for each
# supported compiler. [co_suppress_warnings](#/co_suppress_warnings) is the
# softest level, it only reports warnings that are almost certainly errors - and
# even then only a handful. `co_suppress_warnings` is only recommended for
# external code where warnings cannot be fixed.
# [co_soft_warnings](#/co_soft_warnings) generates warnings that can often lead
# to bugs (although will likely yield a number of false positives).
# [co_strict_warnings](#/co_strict_warnings) generates warnings for any code that
# could lead to a bug, and where the code can be re-written to suppress the
# warning if it is a false positive. Consort uses strict warnings, and treats
# warnings as errors by default.
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

## Warnings/co_soft_warnings
# ```
# co_soft_warnings()
# ```
#
# Apply soft warning flags to this directory and below.
#
# Consort provides three levels of warning, with appropriate flags set for each
# supported compiler. [co_suppress_warnings](#/co_suppress_warnings) is the
# softest level, it only reports warnings that are almost certainly errors - and
# even then only a handful. `co_suppress_warnings` is only recommended for
# external code where warnings cannot be fixed.
# [co_soft_warnings](#/co_soft_warnings) generates warnings that can often lead
# to bugs (although will likely yield a number of false positives).
# [co_strict_warnings](#/co_strict_warnings) generates warnings for any code that
# could lead to a bug, and where the code can be re-written to suppress the
# warning if it is a false positive. Consort uses strict warnings, and treats
# warnings as errors by default.
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

## Warnings/co_strict_warnings
# ```
# co_strict_warnings()
# ```
#
# Apply strict warning flags to this directory and below.
#
# Consort provides three levels of warning, with appropriate flags set for each
# supported compiler. [co_suppress_warnings](#/co_suppress_warnings) is the
# softest level, it only reports warnings that are almost certainly errors - and
# even then only a handful. `co_suppress_warnings` is only recommended for
# external code where warnings cannot be fixed.
# [co_soft_warnings](#/co_soft_warnings) generates warnings that can often lead
# to bugs (although will likely yield a number of false positives).
# [co_strict_warnings](#/co_strict_warnings) generates warnings for any code that
# could lead to a bug, and where the code can be re-written to suppress the
# warning if it is a false positive. Consort uses strict warnings, and treats
# warnings as errors by default.
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

## Warnings/co_warnings_are_errors
# ```
# co_warnings_are_errors(ON|OFF)
# ```
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
