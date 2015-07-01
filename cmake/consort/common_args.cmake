

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
