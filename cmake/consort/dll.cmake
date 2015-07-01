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
