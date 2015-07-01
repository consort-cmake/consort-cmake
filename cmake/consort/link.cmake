# co_link(target link)
#
# Create a symbolic link (or junction on Windows) at "link" that points to
# "target".
function(co_link target link)
	if( NOT EXISTS "${link}" )
		get_filename_component(_parent "${link}" DIRECTORY)
		file(MAKE_DIRECTORY "${_parent}")

		if( CMAKE_HOST_UNIX )
			message( "  Linking ${link} to ${target}" )
			execute_process(
				COMMAND ${CMAKE_COMMAND}
				-E create_symlink
				"${target}"
				"${link}"
			)
		elseif( CMAKE_HOST_WIN32 )
			message( "  Linking ${link} to ${target}" )
			string(REPLACE "/" "\\" _target "${target}" )
			string(REPLACE "/" "\\" _link "${link}" )
			if(IS_DIRECTORY "${target}")
				execute_process(COMMAND "cmd" "/c" "mklink /j ${_link} ${_target}")
			else()
				execute_process(COMMAND "cmd" "/c" "mklink ${_link} ${_target}")
			endif()
		else()
			message(WARNING
				"Consort does not support symbolic links on this platform.\n"
				"Please manually link\n"
				"    ${link}\n"
				"to\n"
				"    ${target}"
			)
		endif()
	endif()
endfunction()
