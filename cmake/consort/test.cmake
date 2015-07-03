if(CONSORT_VALGRIND_TESTS)
	find_program( VALGRIND NAMES valgrind )

	if(NOT VALGRIND)
		message(SEND_ERROR "CONSORT_VALGRIND_TESTS set, but valgrind was not found")
	endif()
endif()

## Build Targets/co_test
#
#     co_test(
#        target-name arg arg...
#        command: ...
#        working-directory: ...
#        configurations: ...
#        suppressions: ...
#        no-valgrind
#     )
#
# Mark target-name as a test suite for ctest to run. The `configurations` group
# can be used to indicate the test should only be run for particular build
# configurations. The `suppressions` group can be used to add suppression files
# when the test is run under valgrind and the `no-valgrind` flag can be used
# to indicate the test should not be run under valgrind.
#
# The `command` group can be used to run the test within a specific environment,
# e.g. under xvfb for test suites that require an X frame buffer but need to be
# able to run headless. The `command` group is prefixed to the command used to
# run the test.
#
# The `working-directory` option can be used to specify a working directory for
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
