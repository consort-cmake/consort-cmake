# The MIT License (MIT)
# 
# Copyright (c) 2015 Adam Bowen, https://github.com/consort-cmake
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
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
