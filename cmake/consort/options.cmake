
# options for configuring consort, override these settings before you include
# consort.cmake or on the command line


## Configuration/CONSORT_ENABLE_ASM
# Enable yasm support, if yasm is found any targets which use `asm-sources` will
# use the assembler rather than the generic sources. Set to OFF to prevent the
# assembler being used even if yasm is found. Defaults to ON.
option(CONSORT_ENABLE_ASM "Enable assembler" ON)

## Configuration/CONSORT_REQUIRE_ASM
# Require yasm to build (if [CONSORT_ENABLE_ASM](#/CONSORT_ENABLE_ASM) is ON).
# If yasm is not found and  [CONSORT_ENABLE_ASM](#/CONSORT_ENABLE_ASM) is ON
# Consort will error. Defaults to OFF.
option(CONSORT_REQUIRE_ASM "Require assembler (if enabled)" OFF)

## Configuration/CONSORT_PERMIT_INSOURCE_BUILDS
# In-source builds pollute the source tree with build artefacts and prevent
# multiple build trees (for example for cross-compilation) from being associated
# with a single source tree. You usually don't want this, so by default consort
# disables them. If you must you can set CONSORT_PERMIT_INSOURCE_BUILDS to ON
# before including consort.cmake to permit in-source builds.
option(CONSORT_PERMIT_INSOURCE_BUILDS "Enable in-source builds" OFF)

## Configuration/CONSORT_PERMIT_NFS_BUILDS
# Builds on NFS partitions will be slow, consort stops you from doing it by
# default. You can set CONSORT_PERMIT_NFS_BUILDS to ON to enable it.
option(CONSORT_PERMIT_NFS_BUILDS "Enable network builds" OFF)

## Configuration/CONSORT_SUPPORT_WINDOWS_XP
# Visual Studio 2013 and later use a version of the Windows runtime incompatible
# with Windows XP. Set this flag to ON to cause them to use an earlier version
# compatible with XP. Defaults to OFF.
option(CONSORT_SUPPORT_WINDOWS_XP "Enable support for Windows XP" OFF)

## Configuration/CONSORT_VALGRIND_TESTS
# Run tests added with [co_test](#/co_test) to be run under valgrind. Useful for
# detecting invalid memory accesses and leaks in test cases.
option(CONSORT_VALGRIND_TESTS "Run tests under valgrind on supported platforms" OFF)

## Configuration/CONSORT_CXX11
# Enable C++11 support. Set to ON to set the necessary options and compiler flags
# to enable C++11 code. Defaults to OFF, except on OS X Mavericks and later,
# where it defaults to ON.
if( CONSORT_MACOSX AND CONSORT_CLANG AND CMAKE_SYSTEM_VERSION VERSION_GREATER 12 )
	# For modern versions of OSX default C++11 on to ensure we link to the right
	# C++ runtime.
	option(CONSORT_CXX11 "Enable support for C++11" ON)
else()
	option(CONSORT_CXX11 "Enable support for C++11" OFF)
endif()

## Configuration/CONSORT_VALGRIND_SUPPRESSIONS
# List of suppression files to pass to valgrind when [CONSORT_VALGRIND_TESTS](#/CONSORT_VALGRIND_TESTS)
# is ON.
set(CONSORT_VALGRIND_SUPPRESSIONS "" CACHE STRING "List of suppression files to use with valgrind" )
