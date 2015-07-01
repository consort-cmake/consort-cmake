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
