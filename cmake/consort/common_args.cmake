
## Build Targets/CONSORT_COMMON_GROUPS
#
# Groups common to all target types ([co_exe](#/co_exe), [co_lib](#/co_lib) and
# [co_dll](#/co_dll)).
#
# Groups define a set of information related to a target, groups are found in
# the list of arguments to a target by looking for the group name followed by a
# colon. For example:
#
#     co_exe(hello sources: *.cpp)
#
# the target above uses the "sources:" group to define the source files for the
# target. Every argument that is not a [flag](CONSORT_COMMON_FLAGS) until the
# next group name is considered part of the group.
#
# sources
# : Source files for the target. May include globbing expressions. Every source
#   file or glob must match at least one file that already exists, otherwise
#   Consort will generate an error. The CMake documentation recommends against
#   using globbing expressions, however, Consort believes that its easier to
#   use a globbing expression and re-run cmake as necessary, rather than having
#   to edit the build configuration every time you add a source file.
#
# generated-sources
# : Source files that are conditional or generated in some way by the build
#   system or other targets. May include generator expressions but not globbing
#   expressions.
#
# asm-sources
# : Assembler sources for use with yasm. These files will not be built if ASM
#   support is disabled or yasm was not found on the build system. May include
#   globbing expressions. Every source file or glob must match at least one file
#   that already exists, otherwise Consort will generate an error.
#
# generic-sources
# : Source files to use when ASM support is disabled or yasm was not found. If
#   ASM support is enabled and yasm was found these files will not be built. May
#   include globbing expressions. Every source file or glob must match at least
#   one file that already exists, otherwise Consort will generate an error.
#
# libraries
# : Libraries to link into the target. May include the names of other targets,
#   generator expressions, or variable expansions that define the location of a
#   library (e.g. `${Boost_SYSTEM_LIBRARY}`). Results in a call to
#   [target_link_libraries](http://www.cmake.org/cmake/help/v3.3/command/target_link_libraries.html).
#
# qt-modules
# : Qt modules to link into the target. [co_enable_qt5](#/co_enable_qt5) should be
#   called before attempting to use Qt support. The module names should be
#   capitalised and omit the Qt prefix. For example, use `qt-modules: Core Gui`
#   to link to QtCore and QtGui. Results in a call to
#   [target_link_libraries](http://www.cmake.org/cmake/help/v3.3/command/target_link_libraries.html).
#
# compile-flags
# : Add compile flags for the target. May include generator expressions. Note:
#   the compile flags will apply to all source files (except asm-sources) for
#   the target, so take care to specify options that your compiler will accept
#   for all types of source file the target uses. Results in a call to
#   [target_compile_options](http://www.cmake.org/cmake/help/v3.3/command/target_compile_options.html)
#
# link-flags
# : Add link flags for the target. May include generator expressions. Sets the
#   [LINK_FLAGS](http://www.cmake.org/cmake/help/v3.3/prop_tgt/LINK_FLAGS.html)
#   property on the target.
#
# depends
# : Explicitly declare that the target depends on other CMake targets. Results
#   in a call to [add_dependencies](http://www.cmake.org/cmake/help/v3.3/command/add_dependencies.html).
#
# output-name
# : By default, CMake will use the target name as the name of the output file,
#   `output-name` can be used to change the output file name. Sets the
#   [OUTPUT_NAME](http://www.cmake.org/cmake/help/v3.3/prop_tgt/OUTPUT_NAME.html)
#   property on the target.
#
# resources
# : Explicitly list Qt resource files that should be compiled into the target.
#   It is also acceptable to include Qt resource files in the sources: group, as
#   Consort enables the [AUTORCC](http://www.cmake.org/cmake/help/v3.3/variable/CMAKE_AUTORCC.html)
#   functionality of cmake.
#
# ui-sources
# : List Qt UI files that could be compiled into the target. The files will be
#   generated in the current build directory, and can be included with
#   `#include "ui_{filename}.h"`.
#
# moc-sources
# : List source files that should be run through Qt's MOC. The generated files
#   will automatically be compiled into the target. Note, that the preferred
#   method for triggering MOC runs is to set the [automoc](#/CONSORT_COMMON_FLAGS)
#   flag on the target.
#
# translations
# : List Qt ts files that should generated for the target, and compiled into it.
#   Consort will run Qt's linguist tools to generate translatable strings for
#   the target and put the results in the specified .ts files. The translated
#   strings will then be compiled into the target as resources, available under
#   the `:/translations` prefix.
#
# tr-sources
# : List Qt ts files that should be compiled into the target. The translated
#   strings will then be compiled into the target as resources, available under
#   the `:/translations` prefix. Unlike the `translations` group, the files in
#   the `tr-sources` group are not automatically generated from the source files
#   for thr target.
#
# qm-sources
# : List Qt qm files that should be compiled into the target. The qm files will
#   be made available as resources, available under the `:/translations` prefix.
#
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

## Build Targets/CONSORT_COMMON_FLAGS
#
# Flags common to all target types ([co_exe](#/co_exe), [co_lib](#/co_lib) and
# [co_dll](#/co_dll)). Flags are keywords that can be added to the definition of
# a target to enable some additional functionality or properties, e.g.
#
#     co_exe(hello sources: *.cpp automoc)
#
# the `automoc` keyword in the above example is a flag, and causes Consort to
# set the AUTOMOC property on the target. Flags may appear anywhere in the
# argument list.
#
# automoc
# : Enable automoc for the target (see the [AUTOMOC CMake documentation](http://www.cmake.org/cmake/help/v3.3/prop_tgt/AUTOMOC.html))
#
# autouic
# : Enable autouic for the target (see the [AUTOUIC CMake documentation](http://www.cmake.org/cmake/help/v3.3/prop_tgt/AUTOUIC.html))
#
set( CONSORT_COMMON_FLAGS
	automoc
	autouic
	#no_strip
	#autopch
	#unity
	#no_version_symlink
)

## Utilities/co_process_common_args
#
# ```
# co_process_common_args(target)
# ```
#
# This function is used to process groups and flags common to all target types.
# It is used internally by Consort to set the properties according to arguments
# passed to the target generation functions ([co_exe](#/co_exe),
# [co_lib](#/co_lib) and [co_dll](#/co_dll)).
#
# If necessary, you can use it in your own custom routines to add support for
# Consort's common flags:
#
#     function(my_target name)
#         co_parse_args(THIS "${CONSORT_COMMON_GROUPS}" "${CONSORT_COMMON_FLAGS}" ${ARGN})
#
#         co_safe_glob(THIS_SOURCES ${THIS_SOURCES})
#         add_executable(${name} ${THIS_SOURCES} ${THIS_GENERATED_SOURCES})
#
#         co_process_common_args(${name})
#     endfunction()
#
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
