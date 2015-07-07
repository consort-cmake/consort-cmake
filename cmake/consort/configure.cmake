# Configure the build
# generic, default, configuration provided by consort
# override these settings after you have included consort.cmake

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

if( CONSORT_MACOSX AND CONSORT_CLANG AND CMAKE_SYSTEM_VERSION VERSION_GREATER 12 )
	# For modern versions of OSX force c++11 on to ensure we link to the right
	# C++ runtime.
	set(CONSORT_CXX11 ON)
endif()

if(CONSORT_CXX11)
	set(CMAKE_CXX_STANDARD 11)
	if(CONSORT_GCC_47)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++11)
	elseif(CONSORT_GCC_43)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++0x)
	elseif(CONSORT_CLANG)
		#co_add_flags(CMAKE_CXX_FLAGS -std=c++11)
		co_add_flags(CMAKE_CXX_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_EXE_LINKER_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_SHARED_LINKER_FLAGS -stdlib=libc++)
		co_add_flags(CMAKE_MODULE_LINKER_FLAGS -stdlib=libc++)
		# The version of boost I'm using has an issue with clang's version of this
		add_definitions(-DBOOST_NO_CXX11_NUMERIC_LIMITS)
	endif()

	message( STATUS "C++11 enabled" )
endif()

# NDEBUG is typically used to suppress debugging in release builds, but
# RelWithDebInfo is an explicit request for a release build with debugging
# information so we remove NDEBUG from the command line.
co_remove_flags(CMAKE_CXX_FLAGS_RELWITHDEBINFO -DNDEBUG)
co_remove_flags(CMAKE_C_FLAGS_RELWITHDEBINFO -DNDEBUG)

if( CONSORT_WINDOWS AND CONSORT_SUPPORT_WINDOWS_XP )
	# XP support needs a little magic
	if( CONSORT_MSVC_2013 )
		set(CMAKE_GENERATOR_TOOLSET "v120_xp" CACHE STRING "Generator Toolset" FORCE)
	else()
		add_definitions(-D_ATL_XP_TARGETING)
	endif()
endif()

if( CONSORT_WINDOWS )
	add_definitions(-D_WIN32_WINNT=0x0501)
endif()

if( CONSORT_WINDOWS_X86_64 )
	add_definitions(-D_AMD64_)
endif()


if(CONSORT_GCC OR CONSORT_CLANG)
	if(CONSORT_64BIT)
		# 64 bit platforms omit frame pointers for performance reasons, but this
		# hinders debugging and profiling. The generating expression is bordering
		# on illegible, but it basically adds -fno-omit-frame-pointer for all
		# configurations but Release.
		list(APPEND CONSORT_COMPILE_FLAGS "$<$<NOT:$<CONFIG:Release>>:-fno-omit-frame-pointer>" )
	endif()

	# -fPIC is often needed, and doesn't really hurt
	list(APPEND CONSORT_COMPILE_FLAGS -fPIC)
endif()

if(CONSORT_MSVC)
	# Allow MSVC to generate large object files (this can happen when you're
	# using a lot of heavy templates)
	list(APPEND CONSORT_COMPILE_FLAGS "/bigobj" "/Zm1000")
endif()
