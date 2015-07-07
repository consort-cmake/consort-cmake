cmake_minimum_required(VERSION 3.0.3)
include("${CMAKE_SOURCE_DIR}/../../cmake/consort.cmake")

co_enable_qt5(Gui Widgets)


co_exe( hello gui automoc
	sources: *.cpp
	ui-sources: *.ui
	translations:
		en_GB.ts
		fr.ts
		de.ts
	qt-modules:
		Core
		Gui
		Widgets
)
