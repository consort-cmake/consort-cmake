if(CONSORT_ENABLE_ASM)
	enable_language(ASM_YASM)

	if(CONSORT_REQUIRE_ASM AND NOT CMAKE_ASM_YASM_COMPILER_WORKS)
		message(SEND_ERROR "Assembler not found, but CONSORT_REQUIRE_ASM is set.")
	endif()
endif()

## Variables/CONSORT_ASM_ENABLED
# Set to 1 if [CONSORT_ENABLE_ASM](#/CONSORT_ENABLE_ASM) is set and yasm was
# found, otherwise set to 0.
if(CONSORT_ENABLE_ASM AND CMAKE_ASM_YASM_COMPILER_WORKS)
	set(CONSORT_ASM_ENABLED 1)
else()
	set(CONSORT_ASM_ENABLED 0)
endif()

if(CONSORT_MACOSX OR CONSORT_WINDOWS_X86)
	# OSX and 32-bit windows expect exports to have the _ prefix
	co_add_flags(CMAKE_ASM_YASM_FLAGS --prefix=_)
endif()

## Utilities/co_add_asm_dependencies
# ```
# co_add_asm_dependencies(file file...)
# ```
#
# Scan input ASM files for dependencies and set the
# [OBJECT_DEPENDS](http://www.cmake.org/cmake/help/v3.3/prop_sf/OBJECT_DEPENDS.html)
# property to ensure rebuilds are triggered as necessary.
#
# Due to limitations of CMake, Consort will not scan for new dependencies when
# files change - so it may be necessary to re-run cmake occasionally to trigger
# proper rebuilds.
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
