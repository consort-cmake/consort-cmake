cmake_minimum_required(VERSION 3.0.3)
include("${CMAKE_SOURCE_DIR}/../../cmake/consort.cmake")

co_exe( hello
	sources: *.cpp
)

# inform Consort that hello is a test case that should be executed by ctest
co_test( hello )
