macro(find_libs_for_vcpkg)
	if (${ZLIB_LIBRARY_VCPKG})
		find_package(ZLIB REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE ZLIB::ZLIB)
		unset(ZLIB_LIBRARIES)
	endif()
	if (${IL_LIBRARY_VCPKG})
		find_package(DevIL REQUIRED)
		if(NOT DEFINED VCPKG_ROOT)
			message(FATAL_ERROR "To fix vcpkg shenanigans, you must specify your VCPKG folder in -DVCPKG_ROOT (no extra / at ending)")
		endif()
		#see https://github.com/microsoft/vcpkg/pull/7524
		if (CMAKE_BUILD_TYPE MATCHES "Release")
			set(IL_LIBRARIES ${VCPKG_ROOT}/installed/x64-windows-static/lib/DevIL.lib)
		elseif(CMAKE_BUILD_TYPE MATCHES "Debug")
			set(IL_LIBRARIES ${VCPKG_ROOT}/installed/x64-windows-static/debug/lib/DevIL.lib)
		endif()
		target_link_libraries(${ARGV0} PRIVATE ${IL_LIBRARIES})
		unset(IL_LIBRARIES)
	endif()
	if (${SDL_LIBRARY_VCPKG})
		find_package(SDL2 CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE SDL2::SDL2main SDL2::SDL2-static)
		unset(SDL_LIBRARIES)
	endif()
	if (${GLEW_LIBRARY_VCPKG})
		find_package(GLEW 1.5.1 REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE GLEW::GLEW)
		unset(GLEW_LIBRARIES)
	endif()
	if (${FREETYPE_LIBRARY_VCPKG})
		find_package(freetype CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE freetype)
		unset(FREETYPE_LIBRARY)
	endif()
	if (${FONTCONFIG_LIBRARY_VCPKG})
		find_package(unofficial-fontconfig CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE unofficial::fontconfig::fontconfig)
		unset(FONTCONFIG_LIBRARIES)
	endif()
	if (${OPENAL_LIBRARY_VCPKG})
		find_package(OpenAL CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PUBLIC OpenAL::OpenAL)
		unset(OPENAL_LIBRARY)
	endif()
	if (${VORBIS_LIBRARY_VCPKG})
		find_package(Vorbis CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE Vorbis::vorbis Vorbis::vorbisenc Vorbis::vorbisfile)
		unset(VORBISFILE_LIBRARY)
		unset(VORBIS_LIBRARY)
	endif()
	if (${OGG_LIBRARY_VCPKG})
		find_package(Ogg CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE Ogg::ogg)
		unset(OGG_LIBRARY)
	endif()
	if (${MINIZIP_LIBRARY_VCPKG})
		find_package(minizip CONFIG REQUIRED)
		target_link_libraries(${ARGV0} PRIVATE minizip::minizip)
	endif()
endmacro()