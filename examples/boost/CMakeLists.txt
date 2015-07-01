cmake_minimum_required(VERSION 3.0.3)
include("${CMAKE_SOURCE_DIR}/../../cmake/consort.cmake")

co_enable_default_boost()

co_exe( utc
	sources: utc.cpp
	libraries: ${Boost_DATE_TIME_LIBRARY}
)
