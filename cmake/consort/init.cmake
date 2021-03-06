if (NOT CMAKE_SCRIPT_MODE_FILE)
	cmake_policy(PUSH) # prevent cmake_minimum_required from modifying policy as well
endif()
cmake_minimum_required(VERSION 3.0.3)
if (NOT CMAKE_SCRIPT_MODE_FILE)
	cmake_policy(POP)
endif()

# If CGCC_FORCE_COLOR is set, color-gcc will output colour during the configure
# step, which causes CMake's compiler detection to fail.
set(ENV{CGCC_FORCE_COLOR} 0)

if(NOT CONSORT_PERMIT_INSOURCE_BUILDS)
	string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" _insource)

	if(_insource)
		message(FATAL_ERROR
			"In-source builds are not permitted!\n"
			"You will need to remove CMakeCache.txt and CMakeFiles.\n"
			"To permit in-source builds use -DCONSORT_PERMIT_INSOURCE_BUILDS=ON.\n"
		)
	endif()

	if(EXISTS "${CMAKE_BINARY_DIR}/CMakeLists.txt")
		message(FATAL_ERROR
			"The build directory may not contain a CMakeLists.txt file!\n"
			"You will need to remove CMakeCache.txt and CMakeFiles.\n"
		)
	endif()
endif()

if( CMAKE_HOST_UNIX )
	if( APPLE )
		execute_process(
			COMMAND df -T nfs "${CMAKE_BINARY_DIR}"
			RESULT_VARIABLE _result
			OUTPUT_QUIET
		)

		if("${_result}" STREQUAL "0")
			set(_nfs_build 1)
		endif()
	else()
		execute_process(
			COMMAND stat -f -c %T "${CMAKE_BINARY_DIR}"
			OUTPUT_VARIABLE _result
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)

		if(_result STREQUAL "nfs")
			set(_nfs_build 1)
		endif()
	endif()

	if(_nfs_build)
		if(CONSORT_PERMIT_NFS_BUILDS)
			message( WARNING "Network build directory detected, your build may be slow." )
		else()
			message( FATAL_ERROR
				"Network build directory detected.\n"
				"Please create your build directory on a local file system.\n"
				"To permit network builds use -DCONSORT_PERMIT_NFS_BUILDS=ON.\n"
			)
		endif()
	endif()
endif()

# Tests are good!
enable_testing()

# Allows include paths to be specified relative to the source root
include_directories(${CMAKE_SOURCE_DIR})

