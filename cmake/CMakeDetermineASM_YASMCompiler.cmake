# This file basically finds the compiler to use, Cotire only support yasm
# because yasm is the most capable "cross platform" assembler (as far as an
# assembler can be cross platform) assembler I have encountered.

set(CMAKE_ASM_YASM_COMPILER_LIST yasm)

if(NOT CMAKE_ASM_YASM_COMPILER)
	find_program(CMAKE_ASM_YASM_COMPILER yasm
		HINTS $ENV{YASM_ROOT} "$ENV{ProgramFiles}/YASM" ${YASM_ROOT}
		PATH_SUFFIXES bin
	)
endif()

set(CMAKE_ASM_YASM_COMPILER_ID yasm)
if(CMAKE_ASM_YASM_COMPILER)
	execute_process(
		COMMAND "${CMAKE_ASM_YASM_COMPILER}" --version
		OUTPUT_VARIABLE _yasm_version
		ERROR_QUIET
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	if(_yasm_version MATCHES "^(yasm ([0-9.]+))")
		set(CMAKE_ASM_YASM_COMPILER_ID "${CMAKE_MATCH_1}")
		set(CMAKE_ASM_YASM_COMPILER_VERSION "${CMAKE_MATCH_2}")
	else()
		set(CMAKE_ASM_YASM_COMPILER_ID "unknown")
	endif()
endif()

set(ASM_DIALECT "_YASM")
include(CMakeDetermineASMCompiler)
set(ASM_DIALECT)
