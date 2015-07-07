## Externals/CONSORT_QT5_LOCATIONS
# Define a list of directories to search for boost, Consort will automatically
# add these directories to locations to search for Boost.
#
# By default, [co_enable_boost](#/co_enable_boost) searches the following locations:
#
### Windows
# * c:/opt/qt5/${CONSORT_PLATFORM_NAME}
# * c:/qt5/${CONSORT_PLATFORM_NAME}
# * c:/opt/qt/${CONSORT_PLATFORM_NAME}
# * c:/qt/${CONSORT_PLATFORM_NAME}
# * c:/opt/qt
# * c:/qt
#
### Linux and Mac OS X
# * /opt/qt5/${CONSORT_PLATFORM_NAME}
# * /opt/qt5
# * /opt/qt/${CONSORT_PLATFORM_NAME}
# * /opt/qt
set(CONSORT_QT5_LOCATIONS "")
if(CONSORT_WINDOWS)
	list(APPEND CONSORT_QT5_LOCATIONS
		"c:/opt/qt5/${CONSORT_PLATFORM_NAME}"
		"c:/qt5/${CONSORT_PLATFORM_NAME}"
		"c:/opt/qt/${CONSORT_PLATFORM_NAME}"
		"c:/qt/${CONSORT_PLATFORM_NAME}"
		"c:/opt/qt"
		"c:/qt"
	)
endif()
if(CONSORT_LINUX OR CONSORT_MACOSX)
	list(APPEND CONSORT_QT5_LOCATIONS
		"/opt/qt5/${CONSORT_PLATFORM_NAME}"
		"/opt/qt5"
		"/opt/qt/${CONSORT_PLATFORM_NAME}"
		"/opt/qt"
	)
endif()

## QT_ROOT
# Set to the root directory of Qt. Consort expects to find the Qt5 CMake files
# in ${QT_ROOT}/lib/cmake. If this is not set, Consort will set it to the
# location it finds Qt in. See also [QT_LIBRARYDIR](#/QT_LIBRARYDIR).

## QT_LIBRARYDIR
# Set to the root directory of Qt. Consort expects to find the Qt5 CMake files
# in ${QT_LIBRARYDIR}/cmake. If this is not set, Consort will set it to the
# location it finds Qt in.

## Externals/co_enable_qt5
# ```
# co_enable_qt5(module module...)
# ```
#
# Find and enable support for Qt5. You should specify the Qt modules you
# want (in addition to Core). For example
#
# ```
# co_enable_qt5(Gui Widgets)
# ```
#
# will find QtCore, QtGui and QtWidgets. Libraries can then be linked to targets
# through the use of the [qt-modules](#/CONSORT_COMMON_GROUPS) group.
#
# Consort will search the paths in [qt-CONSORT_QT5_LOCATIONS](#/CONSORT_QT5_LOCATIONS)
# for Qt by default, you can modify the list of search paths or manually
# specify [QT_ROOT](#/QT_ROOT). You can further override where Consort will look
# for Qt using [QT_LIBRARYDIR](#/QT_LIBRARYDIR).
#
# Consort will automatically copy or symlink Qt binaries into the build (bin)
# directory to ensure that Qt programs can be launched directly from the build
# output. Consort also sets [CMAKE_AUTORCC](http://www.cmake.org/cmake/help/v3.3/variable/CMAKE_AUTORCC.html)
# to enable automatic compilation of resources.
#
# If Qt is found, the `QT_FOUND` and `QT5_FOUND` flags will be set to 1.
macro(co_enable_qt5)
	if(NOT QT_ROOT)
		if(CONSORT_GCC AND CONSORT_64BIT)
			set(_qt_suffix gcc_64)
		elseif(CONSORT_GCC)
			set(_qt_suffix gcc)
		elseif(CONSORT_CLANG AND CONSORT_64BIT)
			set(_qt_suffix clang_64)
		elseif(CONSORT_CLANG)
			set(_qt_suffix clang)
		elseif(CONSORT_MSVC2013)
			set(_qt_suffix msvc2013)
		elseif(CONSORT_MSVC2012)
			set(_qt_suffix msvc2012)
		elseif(CONSORT_MSVC2010)
			set(_qt_suffix msvc2010)
		else()
			set(_qt_suffix *)
			message(SEND_ERROR "Compiler not supported by co_enable_qt.")
		endif()

		set(_search_dirs)
		foreach(_dir ${CONSORT_QT5_LOCATIONS})
			if(EXISTS "${_dir}")
				file( GLOB _dirs "${_dir}/5.*/${_qt_suffix}")
				list( SORT _dirs )
				list( REVERSE _dirs )
				list(APPEND _search_dirs ${_dirs})
			endif()
		endforeach()

		find_path(
			QT_ROOT
			NAMES lib/cmake/Qt5/Qt5Config.cmake
			HINTS ${_search_dirs}
			NO_DEFAULT_PATH
		)
	endif()

	if( QT_ROOT )
		if( NOT EXISTS "${QT_ROOT}" )
			message( SEND_ERROR "Qt5 directory ${QT_ROOT} does not exist" )
		endif()

		if( NOT QT_LIBRARYDIR )
			set( QT_LIBRARYDIR "${QT_ROOT}/lib" )
		endif()

		if( NOT EXISTS "${QT_LIBRARYDIR}" )
			message( SEND_ERROR "Qt5 library directory ${QT_LIBRARYDIR} does not exist" )
		endif()

		file( GLOB _qt_modules ${QT_LIBRARYDIR}/cmake/* )

		foreach( _qt_module ${_qt_modules})
			get_filename_component(_name ${_qt_module} NAME)
			set("${_name}_DIR" "${_qt_module}")
		endforeach()

		find_package(Qt5Core REQUIRED)
		find_package(Qt5LinguistTools REQUIRED)
		find_package(Qt5Designer REQUIRED)
		if( UNIX )
			find_package(Qt5DBus)
		endif()

		set(_modules ${ARGN})
		if(Qt5Core_VERSION_STRING VERSION_LESS "5.4" AND _modules)
			list(REMOVE_ITEM _modules WebChannel)
		endif()

		foreach(m ${_modules})
			find_package(Qt5${m} REQUIRED)
		endforeach()

		# Some distributions don't find the SVG plugin correctly
		if (Qt5Svg_FOUND AND NOT Qt5Svg_PLUGINS MATCHES ".*Qt5::QSvgPlugin.*")
			add_library(Qt5::QSvgPlugin MODULE IMPORTED)
			_populate_Gui_plugin_properties(QSvgPlugin RELEASE "imageformats/${CMAKE_SHARED_LIBRARY_PREFIX}qsvg${CMAKE_SHARED_LIBRARY_SUFFIX}")
			_populate_Gui_plugin_properties(QSvgPlugin DEBUG "imageformats/${CMAKE_SHARED_LIBRARY_PREFIX}qsvg${CMAKE_SHARED_LIBRARY_SUFFIX}")
			list(APPEND Qt5Svg_PLUGINS Qt5::QSvgPlugin)
		endif()

		if(Qt5Core_FOUND)
			set( QT5_FOUND 1 )
			set( QT_FOUND 1 )
			set( CMAKE_AUTORCC 1 )

			message(STATUS "Qt version: ${Qt5Core_VERSION_STRING} (${QT_ROOT})")

			# Some versions of Qt reference invalid include directories
			foreach(m Core ${_modules})
				foreach(d ${Qt5${m}_INCLUDE_DIRS})
					if(NOT IS_DIRECTORY "${d}")
						list(REMOVE_ITEM Qt5${m}_INCLUDE_DIRS "${d}")
					endif()
				endforeach()
			endforeach()

			if(CONSORT_CLANG AND NOT APPLE)
				# Clang seems to be generating warnings from Qt headers, even though
				# -isystem is used
				find_path(_qt_include_dir QtCore PATHS ${Qt5Core_INCLUDE_DIRS} NO_DEFAULT_PATH)
				get_filename_component(_qt_include_dir "${_qt_include_dir}/.." ABSOLUTE)
				list(APPEND CONSORT_COMPILE_FLAGS "-isystem-prefix=${_qt_include_dir}")
			endif()

			if( NOT QT_TRANSLATIONS_DIR)
				get_target_property(QT_QMAKE_EXECUTABLE Qt5::qmake IMPORTED_LOCATION)
				exec_program(
					${QT_QMAKE_EXECUTABLE} ARGS "-query QT_INSTALL_TRANSLATIONS"
					OUTPUT_VARIABLE QT_TRANSLATIONS_DIR
				)
				file(TO_CMAKE_PATH "${QT_TRANSLATIONS_DIR}" QT_TRANSLATIONS_DIR)
				set(QT_TRANSLATIONS_DIR ${QT_TRANSLATIONS_DIR} CACHE PATH "The location of qt translations")
			endif()

			# Ensure these are always set
			if(NOT Qt5PrintSupportPluginsLocation AND _qt5PrintSupport_install_prefix)
				set(Qt5PrintSupportPluginsLocation "${_qt5PrintSupport_install_prefix}/plugins/printsupport" )
			endif()
			if(NOT Qt5ImageFormatPluginsLocation AND _qt5Gui_install_prefix)
				set(Qt5ImageFormatPluginsLocation "${_qt5Gui_install_prefix}/plugins/imageformats" )
			endif()
			if(NOT Qt5PlatformsPluginsLocation AND _qt5Gui_install_prefix)
				set(Qt5PlatformsPluginsLocation "${_qt5Gui_install_prefix}/plugins/platforms" )
			endif()
			if(NOT Qt5SqlPluginsLocation AND _qt5Sql_install_prefix)
				set(Qt5SqlPluginsLocation "${_qt5Sql_install_prefix}/plugins/sqldrivers" )
			endif()

			# Link plugin directories into the runtime directory
			if(Qt5PrintSupportPluginsLocation)
				co_runtime_link("${Qt5PrintSupportPluginsLocation}" printsupport)
			endif()
			if(Qt5ImageFormatPluginsLocation)
				co_runtime_link("${Qt5ImageFormatPluginsLocation}" imageformats)
			endif()
			if(Qt5PlatformsPluginsLocation)
				co_runtime_link("${Qt5PlatformsPluginsLocation}" platforms)
			endif()
			if(Qt5SqlPluginsLocation)
				co_runtime_link("${Qt5SqlPluginsLocation}" sqldrivers)
			endif()

			# Some versions of Qt don't set this
			if(NOT Qt5PrintSupport_PLUGINS AND Qt5PrintSupportPluginsLocation)
				file(GLOB
					Qt5PrintSupport_PLUGINS
					"${Qt5PrintSupportPluginsLocation}/${CMAKE_SHARED_LIBRARY_PREFIX}*${CMAKE_SHARED_LIBRARY_SUFFIX}"
				)
				file(GLOB
					Qt5PrintSupport_PLUGINS_DEBUG
					"${Qt5PrintSupportPluginsLocation}/${CMAKE_SHARED_LIBRARY_PREFIX}*_debug${CMAKE_SHARED_LIBRARY_SUFFIX}"
				)
				list(REMOVE_ITEM Qt5PrintSupport_PLUGINS ${Qt5PrintSupport_PLUGINS_DEBUG})
			endif()

			set( QT_REDISTRIBUTABLES "" )
			if( WIN32 )
				file(GLOB _icu "${_qt5Core_install_prefix}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}icu*${CMAKE_SHARED_LIBRARY_SUFFIX}")
				co_runtime_dll(${_icu})

				foreach( _lib Core ${_modules})
					string(TOUPPER "${_lib}" _LIB)

					get_target_property("QT_QT${_LIB}_SHARED_LIBRARY" "Qt5::${_lib}" LOCATION)
					co_runtime_dll("${QT_QT${_LIB}_SHARED_LIBRARY}")

					get_filename_component(_path "${QT_QT${_LIB}_SHARED_LIBRARY}" PATH)
					get_filename_component(_name "${QT_QT${_LIB}_SHARED_LIBRARY}" NAME_WE)
					co_runtime_dll("${_path}/${_name}d.dll")
				endforeach()
			endif()

			add_definitions(-DCONSORT_QT5)

			if(APPLE)
				find_program(MACDEPLOYQT NAMES macdeployqt PATHS "${QT_ROOT}/bin")
			endif()
		endif()
	endif()
endmacro()

## Externals/co_enable_default_qt5
# ```
# co_enable_default_qt5(module module...)
# ```
#
# Find and enable support for Qt5. This macro will use the default list of
# modules provided by Consort, you can add additional modules if necessary.
#
# The default modules are:
#
# * Gui
# * Widgets
# * Network
# * WebKit
# * WebKitWidgets
# * WebChannel
# * Sql
# * Svg
# * OpenGL
# * Concurrent
# * Multimedia
# * PrintSupport
# * MultimediaWidgets
# * Positioning
# * Qml
# * Quick
# * Sensors
macro(co_enable_default_qt5)
	co_enable_qt5(
		Gui
		Widgets
		Network
		WebKit
		WebKitWidgets
		WebChannel
		Sql
		Svg
		OpenGL
		Concurrent
		Multimedia
		PrintSupport
		MultimediaWidgets
		Positioning
		Qml
		Quick
		Sensors
		${ARGN}
	)
endmacro()

## Utilities/co_write_file_if_changed
# ```
# co_write_file_if_changed( filename content )
# ```
#
# Ensure "filename" contains "content", but do not touch the file if it is not
# necessary. Useful for generating output files, without triggering rebuilds
# when cmake is run. Equivalent to `file(WRITE "${filename}" "${content}")`.
#
function( co_write_file_if_changed filename content )
	if( EXISTS "${filename}" )
		file(READ "${filename}" _current)

		if( NOT _current STREQUAL content )
			file(WRITE "${filename}" "${content}")
		endif()
	else()
		file(WRITE "${filename}" "${content}")
	endif()
endfunction()


function(co_add_resources outfiles )
	# This function is adapted from QT5_CREATE_TRANSLATION in
	# Qt5CoreMacros.cmake, it is subject to the following licence:
	#
	#=============================================================================
	# Copyright 2005-2011 Kitware, Inc.
	# All rights reserved.
	#
	# Redistribution and use in source and binary forms, with or without
	# modification, are permitted provided that the following conditions
	# are met:
	#
	# * Redistributions of source code must retain the above copyright
	#   notice, this list of conditions and the following disclaimer.
	#
	# * Redistributions in binary form must reproduce the above copyright
	#   notice, this list of conditions and the following disclaimer in the
	#   documentation and/or other materials provided with the distribution.
	#
	# * Neither the name of Kitware, Inc. nor the names of its
	#   contributors may be used to endorse or promote products derived
	#   from this software without specific prior written permission.
	#
	# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#=============================================================================
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(_RCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(rcc_files ${_RCC_UNPARSED_ARGUMENTS})
    set(rcc_options ${_RCC_OPTIONS})

    foreach(it ${rcc_files})
        get_filename_component(outfilename ${it} NAME_WE)
        get_filename_component(infile ${it} ABSOLUTE)
        get_filename_component(rc_path ${infile} PATH)
        set(outfile ${CMAKE_CURRENT_BINARY_DIR}/qrc_${outfilename}.cpp)

        set(_RC_DEPENDS)
        if(EXISTS "${infile}")
            #  parse file for dependencies
            #  all files are absolute paths or relative to the location of the qrc file
            file(READ "${infile}" _RC_FILE_CONTENTS)
            string(REGEX MATCHALL "<file[^<]+" _RC_FILES "${_RC_FILE_CONTENTS}")
            foreach(_RC_FILE ${_RC_FILES})
                string(REGEX REPLACE "^<file[^>]*>" "" _RC_FILE "${_RC_FILE}")
                if(NOT IS_ABSOLUTE "${_RC_FILE}")
                    set(_RC_FILE "${rc_path}/${_RC_FILE}")
                endif()
                set(_RC_DEPENDS ${_RC_DEPENDS} "${_RC_FILE}")
            endforeach()
            # Since this cmake macro is doing the dependency scanning for these files,
            # let's make a configured file and add it as a dependency so cmake is run
            # again when dependencies need to be recomputed.
            qt5_make_output_file("${infile}" "" "qrc.depends" out_depends)
            # The only change is here, my version of Qt uses COPY_ONLY which is
            # incorrect!
            configure_file("${infile}" "${out_depends}" COPYONLY)
        else()
            # The .qrc file does not exist (yet). Let's add a dependency and hope
            # that it will be generated later
            set(out_depends)
        endif()

        add_custom_command(OUTPUT ${outfile}
                           COMMAND ${Qt5Core_RCC_EXECUTABLE}
                           ARGS ${rcc_options} -name ${outfilename} -o ${outfile} ${infile}
                           MAIN_DEPENDENCY ${infile}
                           DEPENDS ${_RC_DEPENDS} "${out_depends}" VERBATIM)
        list(APPEND ${outfiles} ${outfile})
    endforeach()
    set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()

function(co_create_translation _qm_files)
	# This function is adapted from QT5_CREATE_TRANSLATION in
	# Qt5LinguistToolsMacros.cmake, it is subject to the following licence:
	#
	#=============================================================================
	# Copyright 2005-2011 Kitware, Inc.
	# All rights reserved.
	#
	# Redistribution and use in source and binary forms, with or without
	# modification, are permitted provided that the following conditions
	# are met:
	#
	# * Redistributions of source code must retain the above copyright
	#   notice, this list of conditions and the following disclaimer.
	#
	# * Redistributions in binary form must reproduce the above copyright
	#   notice, this list of conditions and the following disclaimer in the
	#   documentation and/or other materials provided with the distribution.
	#
	# * Neither the name of Kitware, Inc. nor the names of its
	#   contributors may be used to endorse or promote products derived
	#   from this software without specific prior written permission.
	#
	# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#=============================================================================
    set(options)
    set(oneValueArgs)
    set(multiValueArgs OPTIONS)

    cmake_parse_arguments(_LUPDATE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(_lupdate_files ${_LUPDATE_UNPARSED_ARGUMENTS})
    set(_lupdate_options ${_LUPDATE_OPTIONS})

    set(_my_sources)
    set(_my_tsfiles)
    foreach(_file ${_lupdate_files})
        get_filename_component(_ext ${_file} EXT)
        get_filename_component(_abs_FILE ${_file} ABSOLUTE)
        if(_ext MATCHES "ts")
            list(APPEND _my_tsfiles ${_abs_FILE})
        else()
            list(APPEND _my_sources ${_abs_FILE})
        endif()
    endforeach()
    foreach(_ts_file ${_my_tsfiles})
        if(_my_sources)
          # make a list file to call lupdate on, so we don't make our commands too
          # long for some systems
          get_filename_component(_ts_name ${_ts_file} NAME_WE)
          set(_ts_lst_file "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_ts_name}_lst_file")
          set(_lst_file_srcs)
          foreach(_lst_file_src ${_my_sources})
              set(_lst_file_srcs "${_lst_file_src}\n${_lst_file_srcs}")
          endforeach()

          get_directory_property(_inc_DIRS INCLUDE_DIRECTORIES)
          foreach(_pro_include ${_inc_DIRS})
              get_filename_component(_abs_include "${_pro_include}" ABSOLUTE)
              set(_lst_file_srcs "-I${_pro_include}\n${_lst_file_srcs}")
          endforeach()

          # The only change is to use co_write_file_if_changed to write the file
          # to ensure running cmake doesn't trigger unnecessary rebuilds.
          co_write_file_if_changed(${_ts_lst_file} "${_lst_file_srcs}")
        endif()
        add_custom_command(OUTPUT ${_ts_file}
            COMMAND ${Qt5_LUPDATE_EXECUTABLE}
            ARGS ${_lupdate_options} "@${_ts_lst_file}" -ts ${_ts_file}
            DEPENDS ${_my_sources} ${_ts_lst_file} VERBATIM)
    endforeach()
    qt5_add_translation(${_qm_files} ${_my_tsfiles})
    set(${_qm_files} ${${_qm_files}} PARENT_SCOPE)
endfunction()

macro( QT_WRAP_UI )
	QT5_WRAP_UI(${ARGN})
endmacro()

macro( QT_WRAP_CPP )
	QT5_WRAP_CPP(${ARGN})
endmacro()

macro( QT_WRAP_CPP )
	QT5_WRAP_CPP(${ARGN})
endmacro()

macro( QT_CREATE_TRANSLATION )
	QT5_CREATE_TRANSLATION(${ARGN})
endmacro()

macro( QT_ADD_TRANSLATION )
	QT5_ADD_TRANSLATION(${ARGN})
endmacro()

macro( QT_ADD_RESOURCES )
	QT5_ADD_RESOURCES(${ARGN})
endmacro()

macro( QT_USE_MODULES )
	foreach( m ${THIS_QT_MODULES} )
		target_link_libraries(${name} "Qt5::${m}")

		# Qt before 5.1 didn't automatically add these
		if( Qt5Core_VERSION_STRING VERSION_LESS "5.1" )
			target_include_directories(${name} SYSTEM BEFORE PRIVATE ${Qt5${m}_INCLUDE_DIRS})
		endif()
	endforeach()
endmacro()

## Externals/co_process_qt_args
# ```
# co_process_qt_args(target)
# ```
#
# Adjust properties of target as necessary to add Qt support. Note that this
# macro needs to be called before target is declared. This macro is analogous
# to [co_process_common_args](#/co_process_common_args), but for Qt specific
# functionality. This is normally called for you by Consort, however, you
# can use it to process the common Qt arguments for your targets if necessary.
#
#     function(my_target name)
#         co_parse_args(THIS "${CONSORT_COMMON_GROUPS}" "${CONSORT_COMMON_FLAGS}" ${ARGN})
#
#         co_safe_glob(THIS_SOURCES ${THIS_SOURCES})
#         co_process_qt_args(${name})
#         add_executable(${name} ${THIS_SOURCES} ${THIS_GENERATED_SOURCES})
#
#         co_process_common_args(${name})
#     endfunction()
#
macro(co_process_qt_args target)
	set(THIS_TRANSLATION_SOURCES
		${THIS_SOURCES}
		${THIS_GENERATED_SOURCES}
	)

	if( THIS_MOC_SOURCES )
		co_safe_glob( THIS_MOC_SOURCES ${THIS_MOC_SOURCES} )
		QT_WRAP_CPP( THIS_GENERATED_MOC_SOURCES ${THIS_MOC_SOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_MOC_SOURCES})
	endif()

	if( THIS_UI_SOURCES )
		co_safe_glob( THIS_UI_SOURCES ${THIS_UI_SOURCES} )
		QT_WRAP_UI( THIS_GENERATED_UI_SOURCES ${THIS_UI_SOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_UI_SOURCES})
		list(APPEND THIS_TRANSLATION_SOURCES ${THIS_UI_SOURCES})
	endif()

	if( THIS_TRANSLATIONS AND THIS_TRANSLATION_SOURCES )
		co_create_translation( _files ${THIS_TRANSLATIONS} ${THIS_TRANSLATION_SOURCES} OPTIONS -silent )
		list(APPEND THIS_QM_SOURCES ${_files})
		list(APPEND THIS_GENERATED_SOURCES ${_files})
	endif()

	if( THIS_TR_SOURCES )
		QT_ADD_TRANSLATION( _files ${THIS_TR_SOURCES} )
		list(APPEND THIS_QM_SOURCES ${_files})
		list(APPEND THIS_GENERATED_SOURCES ${_files})
	endif()

	if( THIS_QM_SOURCES )
		set( _resource_file "<RCC><qresource prefix=\"/translations\">" )
		foreach( qm ${THIS_QM_SOURCES} )
			get_filename_component(qm_file ${qm} NAME)
			set( _resource_file "${_resource_file}<file alias=\"${qm_file}\">${qm}</file>")
		endforeach()
		set( _resource_file "${_resource_file}</qresource></RCC>")

		co_write_file_if_changed(${CMAKE_CURRENT_BINARY_DIR}/${target}_translations.qrc "${_resource_file}")

		list(APPEND THIS_RESOURCES ${CMAKE_CURRENT_BINARY_DIR}/${target}_translations.qrc)
	endif()

	if( THIS_RESOURCES )
		co_safe_glob( THIS_RESOURCES ${THIS_RESOURCES} )
		co_add_resources( THIS_GENERATED_RESOURCES ${THIS_RESOURCES} )
		list(APPEND THIS_GENERATED_SOURCES ${THIS_GENERATED_RESOURCES})
	endif()

endmacro()
