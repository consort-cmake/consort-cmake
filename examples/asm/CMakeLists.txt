cmake_minimum_required(VERSION 3.0.3)
include("${CMAKE_SOURCE_DIR}/../../cmake/consort.cmake")

co_exe( consort_has_asm
	sources: *.cpp
	asm-sources: *.asm
	generic-sources: *.c
)

if(CONSORT_ASM_ENABLED)
	# if Consort reports ASM is enabled, this program should succeed
	co_test(consort_has_asm)
endif()
