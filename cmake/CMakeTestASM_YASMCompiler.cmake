# This is used to check whether or not the compiler "works", except for ASM
# all it really does is check whether or not the compiler exists because the
# assembly needed to test the compiler is platform specific.

set(ASM_DIALECT "_YASM")
include(CMakeTestASMCompiler)
set(ASM_DIALECT)
