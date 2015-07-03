## Build Targets/co_exe
#
# ```
# co_exe(name groups... flags...)
# ```
#
# Declare an executable (EXE) target. The properties of the target are
# specified in a declarative fashion as [groups](#/CONSORT_COMMON_GROUPS) and
# [flags](#/CONSORT_COMMON_FLAGS). The most common groups you will need with
# the `co_dll` function are the `sources:` group, for specifying source files,
# and the `libraries:` group, for specifying libraries to link against.
#
# `co_exe` supports all the common groups and flags, consult the documentation
# for [CONSORT_COMMON_GROUPS](#/CONSORT_COMMON_GROUPS) and
# [CONSORT_COMMON_FLAGS](#/CONSORT_COMMON_FLAGS) for more information on the
# available options.
#
# `co_exe` also supports the following flag:
#
# gui
# : Declare the target to be a GUI program, on Windows this causes the
#   [WIN32_EXECUTABLE](http://www.cmake.org/cmake/help/v3.3/prop_tgt/WIN32_EXECUTABLE.html)
#   property to be set on the target and will enable auto-linking to QtMain.
#   The flag currently has no effect on Linux or OS X.
#
# Example:
#
#    co_exe( my_program sources: my_program.cpp libraries: my_library)
#
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
