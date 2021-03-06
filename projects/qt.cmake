# Building Qt 5.6 within the superbuild does not work at the moment and is unsupported.
# This defaults to using a system installed Qt for now.  Use common-superbuild or
# Qt's binary installers to get the system Qt 5.6.


set (qt_depends)
set (qt_options)
if (APPLE)
  list (APPEND qt_options
    -sdk ${CMAKE_OSX_SDK}
    -qt-libpng)
elseif (UNIX)
  list (APPEND qt_depends freetype fontconfig png)
  list (APPEND qt_options
    -qt-xcb
    -system-libpng
    -I <INSTALL_DIR>/include/freetype2
    -I <INSTALL_DIR>/include/fontconfig)
endif()

if (NOT WIN32)
  list(APPEND qt_depends
    zlib)
  list(APPEND qt_options
    -no-alsa
    -no-pulseaudio
    -system-zlib)
else ()
  list(APPEND qt_options
    -qt-zlib)
endif ()

set(qt_EXTRA_CONFIGURATION_OPTIONS ""
    CACHE STRING "Extra arguments to be passed to Qt when configuring.")

set(qt_configure_command <SOURCE_DIR>/configure)
if (WIN32)
  set(qt_configure_command <SOURCE_DIR>/configure.bat)
endif ()

set(qt_build_commands)
if (WIN32)
  list(APPEND qt_build_commands
    BUILD_COMMAND ${NMAKE_PATH}
    INSTALL_COMMAND ${NMAKE_PATH} install)
endif ()

add_external_project_or_use_system(
    qt
    DEFAULT_TO_USE_SYSTEM
    DEPENDS zlib ${qt_depends}
    CONFIGURE_COMMAND
      ${qt_configure_command}
      -prefix <INSTALL_DIR>
      -opensource
      -release
      -confirm-license
      -nomake examples
      -skip qtconnectivity
      -skip qtlocation
      -skip qtmultimedia
      -skip qtsensors
      -skip qtserialport
      -skip qtsvg
      -skip qtwayland
      -skip qtwebchannel
      -skip qtwebengine
      -skip qtwebsockets
      -no-dbus
      -no-openssl
      -qt-libjpeg
      -qt-pcre
      -I <INSTALL_DIR>/include
      -L <INSTALL_DIR>/lib
      ${qt_options}
      ${qt_EXTRA_CONFIGURATION_OPTIONS}
    ${qt_build_commands}
)

add_extra_cmake_args(
  -DPARAVIEW_QT_VERSION:STRING=5
  -DQt5_DIR:PATH=<INSTALL_DIR>/lib/cmake/Qt5
)

if (NOT USE_SYSTEM_qt)
  message(FATAL_ERROR "tomviz superbuild does not currently support building Qt 5.6 from source.  Please install your own Qt, turn on USE_SYSTEM_qt and provide the superbuild with the path to that Qt install")
  set(Qt5_DIR "<INSTALL_DIR>/lib/cmake/Qt5")
endif()
