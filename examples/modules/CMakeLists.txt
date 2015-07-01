cmake_minimum_required(VERSION 3.0.3)
include("${CMAKE_SOURCE_DIR}/../../cmake/consort.cmake")

# Register all modules in the current directory
co_find_modules(.)

# Explicitly enable module1
co_require_module(module1)

#  Include activated modules
co_include_modules()
