
# options for configuring consort, override these settings before you include
# consort.cmake or on the command line

option(CONSORT_ENABLE_ASM "Enable assembler" ON)
option(CONSORT_REQUIRE_ASM "Require assembler (if enabled)" OFF)
option(CONSORT_PERMIT_INSOURCE_BUILDS "Enable in-source builds" OFF)
option(CONSORT_PERMIT_NFS_BUILDS "Enable network builds" OFF)
option(CONSORT_SUPPORT_WINDOWS_XP "Enable support for Windows XP" OFF)
option(CONSORT_VALGRIND_TESTS "Run tests under valgrind on supported platforms" OFF)

if( CONSORT_MACOSX AND CONSORT_CLANG AND CMAKE_SYSTEM_VERSION VERSION_GREATER 12 )
	# For modern versions of OSX default C++11 on to ensure we link to the right
	# C++ runtime.
	option(CONSORT_CXX11 "Enable support for C++11" ON)
else()
	option(CONSORT_CXX11 "Enable support for C++11" OFF)
endif()

# Global variable
set(CONSORT_VALGRIND_SUPPRESSIONS "" CACHE STRING "List of suppression files to use with valgrind" )
