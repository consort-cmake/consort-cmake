## Build Targets/co_lib
#
# ```
# co_lib(name groups... flags...)
# ```
#
# Declare a static library (archive) target. The properties of the target are
# specified in a declarative fashion as [groups](#/CONSORT_COMMON_GROUPS) and
# [flags](#/CONSORT_COMMON_FLAGS). The most common groups you will need with
# the `co_lib` function are the `sources:` group, for specifying source files,
# and the `libraries:` group, for specifying libraries to link against.
#
# `co_lib` supports all the common groups and flags, consult the documentation
# for [CONSORT_COMMON_GROUPS](#/CONSORT_COMMON_GROUPS) and
# [CONSORT_COMMON_FLAGS](#/CONSORT_COMMON_FLAGS) for more information on the
# available options.
#
# If you do not specify any source files, Consort will generate a dummy source
# file to make the target into a "real" target. This can be used to specify
# linker dependencies or for future proofing with header only libraries.
#
# Example:
#
#    co_lib( my_library sources: my_library.cpp libraries: ${Boost_DATE_TIME_LIBRARY})
#
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
