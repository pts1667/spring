# Place executables and shared libs under "build-dir/",
# instead of under "build-dir/rts/"
# This way, we have the build-dir structure more like the install-dir one,
# which makes testing spring in the builddir easier, eg. like this:
# cd build-dir
# SPRING_DATADIR=$(pwd) ./spring
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

### Assemble libraries
find_vcpkg(SDL2)
set(engineIncludes ${SDL2_INCLUDE_DIR})
set(engineLibraries ${SDL2_LIBRARY})
if(NOT VCPKG_TOOLCHAIN AND "${SDL2_VERSION_STRING}" VERSION_LESS "2")
	message(FATAL_ERROR "Found SDL v${SDL2_VERSION_STRING} while 2 is required!")
endif()


set(OpenGL_GL_PREFERENCE LEGACY)
find_package_static(OpenGL REQUIRED)
find_vcpkg_static_ver(GLEW 1.5.1 GLEW_LIBRARY_VCPKG)
if (NOT GLEW_FOUND)
	find_vcpkg_static(GLEW GLEW_LIBRARY_VCPKG)
endif()
list(APPEND engineLibraries ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} ${GLEW_LIBRARIES})
list(APPEND engineIncludes ${GLEW_INCLUDE_DIR})

find_vcpkg_static(FontConfig FONTCONFIG_LIBRARY_VCPKG)
if ((NOT VCPKG_TOOLCHAIN) AND (NOT FONTCONFIG_FOUND))
	find_package_static(unofficial-fontconfig)
endif()
if    (FONTCONFIG_FOUND)
	list(APPEND engineIncludes ${FONTCONFIG_INCLUDE_DIR})
	list(APPEND engineLibraries ${FONTCONFIG_LIBRARIES})
	add_definitions(-DUSE_FONTCONFIG)
	if    (PREFER_STATIC_LIBS)
		prefer_static_libs()
		find_library(EXPAT_LIBRARY expat)
		unprefer_static_libs()
		list(APPEND engineLibraries ${EXPAT_LIBRARY})
	endif (PREFER_STATIC_LIBS)
endif (FONTCONFIG_FOUND)

#find_freetype_hack() # hack to find different named freetype.dll
find_vcpkg_static(Freetype FREETYPE_LIBRARY_VCPKG)
if ((NOT VCPKG_TOOLCHAIN) AND (NOT FREETYPE_FOUND))
	find_package_static(freetype CONFIG REQUIRED)
endif()
foreach(f ${FREETYPE_INCLUDE_DIRS})
	list(APPEND engineIncludes ${f})
endforeach(f)
list(APPEND engineLibraries ${FREETYPE_LIBRARY})

if    (PREFER_STATIC_LIBS)
	# dependencies of FreeType
	find_package_static(BZip2 REQUIRED)
	list(APPEND engineLibraries ${BZIP2_LIBRARIES})
endif (PREFER_STATIC_LIBS)

if    (UNIX)
	find_package(X11 REQUIRED)
	list(APPEND engineLibraries ${X11_Xcursor_LIB} ${X11_X11_LIB})
endif (UNIX)

if (APPLE)
	find_library(COREFOUNDATION_LIBRARY Foundation)
	list(APPEND engineLibraries ${COREFOUNDATION_LIBRARY})
endif (APPLE)

list(APPEND engineLibraries ${sound-impl})
list(APPEND engineLibraries engineSystemNet)
list(APPEND engineLibraries ${engineCommonLibraries})
list(APPEND engineLibraries engineaGui)
list(APPEND engineLibraries ${SPRING_SIM_LIBRARIES})
list(APPEND engineLibraries engineSim)
list(APPEND engineLibraries pr-downloader_static)

### Assemble external incude dirs
find_vcpkg_static(OpenAL OPENAL_LIBRARY_VCPKG)
list(APPEND engineIncludes ${OPENAL_INCLUDE_DIR})
list(APPEND engineIncludes ${ENGINE_SRC_ROOT_DIR}/lib/asio/include)
list(APPEND engineIncludes ${ENGINE_SRC_ROOT_DIR}/lib/slimsig/include)

include_directories(${engineIncludes})

### Build the executable
add_executable(engine-legacy ${EXE_FLAGS} ${engineSources} ${ENGINE_ICON} ${engineHeaders})
find_libs_for_vcpkg(engine-legacy)
target_link_libraries(engine-legacy PUBLIC ${engineLibraries})


### Install the executable
install(TARGETS engine-legacy DESTINATION ${BINDIR})

create_engine_build_and_install_target(legacy)
