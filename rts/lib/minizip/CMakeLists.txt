# Spring supplied CMake build file

set(MINIZIP_FIND_QUIETLY TRUE)
FIND_PACKAGE_STATIC(MiniZip)

if     (MINIZIP_FOUND OR MSVC)
	# Use the system supplied MiniZip library
	message(STATUS "Using minizip library: ${MINIZIP_LIBRARY}")

	set_global(SPRING_MINIZIP_INCLUDE_DIR "${MINIZIP_INCLUDE_DIR}")
	set_global(SPRING_MINIZIP_LIBRARY "${MINIZIP_LIBRARY}")
else   (MINIZIP_FOUND)
	# Build our own minizip library
	set(miniZipSources
			"unzip"
			"zip"
			"ioapi"
		)

	add_definitions(-DNOCRYPT -DNOUNCRYPT)
	find_vcpkg(ZLIB ZLIB_LIBRARY_VCPKG)

	add_library(minizip STATIC EXCLUDE_FROM_ALL ${miniZipSources})
	find_libs_for_vcpkg(minizip)
	target_link_libraries(minizip PRIVATE ${ZLIB_LIBRARY})
	set_target_properties(minizip PROPERTIES COMPILE_FLAGS "${PIC_FLAG}")

	set_global(SPRING_MINIZIP_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/rts/lib")
	set_global(SPRING_MINIZIP_LIBRARY minizip)
endif  (MINIZIP_FOUND)
