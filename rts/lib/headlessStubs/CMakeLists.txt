SET(headlessStubsSources
		"glewstub"
		"glstub"
		"sdlstub"
	)

IF    (WIN32)
	# We still need these header files,
	# even if we are not going to link with SDL.
	# We have them available anyway (mingwlibs).
	find_vcpkg(SDL2 SDL_LIBRARY_VCPKG)
	INCLUDE_DIRECTORIES(${SDL2_INCLUDE_DIR})
	INCLUDE_DIRECTORIES(BEFORE ${CMAKE_SOURCE_DIR}/include)
ELSE  (WIN32)
	# Use a direct copy of the GL and SDL headers,
	# as these may not be available on headless systems.
	INCLUDE_DIRECTORIES(BEFORE ${CMAKE_SOURCE_DIR}/include)
	INCLUDE_DIRECTORIES(BEFORE ${CMAKE_SOURCE_DIR}/include/SDL2)
ENDIF (WIN32)

ADD_LIBRARY(headlessStubs STATIC EXCLUDE_FROM_ALL ${headlessStubsSources})
SET_TARGET_PROPERTIES(headlessStubs PROPERTIES COMPILE_FLAGS "${PIC_FLAG}")
find_libs_for_vcpkg(headlessStubs)
