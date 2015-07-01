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
# This file teaches CMake how to build with YASM.

set(CMAKE_ASM_YASM_SOURCE_FILE_EXTENSIONS asm)

if(NOT CMAKE_ASM_YASM_OBJECT_FORMAT)
	if(CONSORT_WINDOWS_X86_64)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT win64)
	elseif(CONSORT_WINDOWS_X86)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT win32)
	elseif(CONSORT_MACOSX_X86_64)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT macho64)
	elseif(CONSORT_MACOSX_X86)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT macho)
	elseif(CONSORT_LINUX_X86_64)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT elf64)
	elseif(CONSORT_LINUX_X86)
		set(CMAKE_ASM_YASM_OBJECT_FORMAT elf)
	endif()
endif()

if(NOT CMAKE_ASM_YASM_COMPILE_OBJECT)
	set(CMAKE_ASM_YASM_COMPILE_OBJECT "<CMAKE_ASM_YASM_COMPILER> -f ${CMAKE_ASM_YASM_OBJECT_FORMAT} <FLAGS> <DEFINES> -o <OBJECT> <SOURCE>")
endif()

# Load the generic ASMInformation file:
set(ASM_DIALECT "_YASM")
include(CMakeASMInformation)
set(ASM_DIALECT)
