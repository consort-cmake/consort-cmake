## Module Functions/co_find_modules
# ```
# co_find_modules( path )
# ```
#
# Find consort modules located in the specified directory (relative to
# CMAKE_CURRENT_SOURCE_DIR). A consort module is a subdirectory of path that
# contains a module.cmake file. The module.cmake file will be included.
#
# To create a module, create a subdirectory of the search path (for example,
# if you call `co_find_modules(modules)` create your module in the
# `modules/my_module` directory), then create a `CMakeLists.txt` and a
# `module.cmake` file in that directory. In the `CMakeLists.txt` declare your
# targets as normal. In the `module.cmake` file call [co_module](#/co_module)
# to declare your module.
#
# You should call this after including consort.cmake and pass in directories
# you would like Consort to search for modules.
#
# Consort will automatically enable modules that are linked to by targets
# included in the build. You can explicitly request Consort include a module
# using [co_require_module](#/co_require_module). At the end of your root
# CMakeLists.txt you should call [co_include_modules](#/co_include_modules) to
# include all activated modules.
#
# Example:
#
#     co_find_modules(modules)
#
#     # Explicitly enable my_module
#     co_require_module(my_module)
#
#     co_include_modules()
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

## Module Functions/co_module
#
#     co_module( name
#         [directory: (relative path to module directory)]
#         [aliases: alias alias ...]
#     )
#
# Declare a Consort module. A consort module is a directory containing a
# CMakeLists.txt and a module.cmake file. The CMakeLists.txt file defines how
# to build the module. The module.cmake file registers the module with Consort.
# Calls to the `co_module` function should be placed in the module.cmake file.
# Consort will then fulfil requests to activate the module by calling
# [add_subdirectory](http://www.cmake.org/cmake/help/v3.3/command/add_subdirectory.html)
# on the directory associated with the module. See [co_find_modules](#/co_find_modules)
# for more information.
#
# The `name` of the module is the name used to activate it, this should normally
# be the name of the library target the module exports, as this will allow
# Consort to automatically activate the module when a target links to it.
#
# The `directory:` is the directory to pass to `add_subdirectory`. By default
# this will be the location of the module.cmake file. Otherwise, it is specified
# relative to the path to the module.cmake file.
#
# The `aliases:` group allows additional names to be associated with the module,
# if, for example, the module contains multiple library targets.
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



## Module Functions/co_require_module
# ```
# co_require_module( name )
# ```
#
# Add the specified module to the list of modules Consort will enable.
#
# See [co_find_modules](#/co_find_modules) and [co_module](#/co_module).
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

## Module Functions/co_include_modules
# ```
# co_include_modules()
# ```
#
# Call [add_subdirectory](http://www.cmake.org/cmake/help/v3.3/command/add_subdirectory.html)
# for every active module that has not already been
# included, if any modules are added to the active list,
# [add_subdirectory](http://www.cmake.org/cmake/help/v3.3/command/add_subdirectory.html)
# will also be called for those modules.
#
# See [co_find_modules](#/co_find_modules) and [co_module](#/co_module).
#
# Example:
#
#     co_find_modules(modules)
#
#     # Explicitly enable my_module
#     co_require_module(my_module)
#
#     co_include_modules()
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
