
# only one of the two targets needs this
remove_definitions(-DNO_SOUND)

# Dummy Sound implementaiton
set(noSoundSources
		IAudioChannel.cpp
		ISound.cpp
		Null/SoundChannels.cpp
		Null/NullSound.cpp
	)

add_library(no-sound STATIC EXCLUDE_FROM_ALL ${noSoundSources})
set_target_properties(no-sound PROPERTIES COMPILE_FLAGS "-DNO_SOUND")


# Define default sound implementation
if    (NO_SOUND)
	set(sound-impl no-sound PARENT_SCOPE)
else  (NO_SOUND)
	set(sound-impl sound PARENT_SCOPE)
endif (NO_SOUND)


# Real Sound implementaiton
if    (NOT NO_SOUND)
	set(soundSources
			ISound.cpp
			IAudioChannel.cpp
			Null/NullSound.cpp
			OpenAL/ALShared.cpp
			OpenAL/EFX.cpp
			OpenAL/EFXfuncs.cpp
			OpenAL/EFXPresets.cpp
			OpenAL/AudioChannel.cpp
			OpenAL/OggStream.cpp
			OpenAL/Sound.cpp
			OpenAL/SoundChannels.cpp
			OpenAL/SoundBuffer.cpp
			OpenAL/SoundItem.cpp
			OpenAL/SoundSource.cpp
			OpenAL/VorbisShared.cpp
		)

	find_vcpkg_static(OpenAL OPENAL_LIBRARY_VCPKG)
	include_directories(${OPENAL_INCLUDE_DIR})
	if (NOT MSVC)
		find_package_static(OggVorbis)
	endif()

	if(NOT OGGVORBIS_FOUND)
		find_vcpkg_static(Vorbis VORBIS_LIBRARY_VCPKG)
		find_vcpkg_static(Ogg OGG_LIBRARY_VCPKG)
	endif()
	include_directories(${OGG_INCLUDE_DIR} ${VORBIS_INCLUDE_DIR})

	find_vcpkg(SDL2 SDL_LIBRARY_VCPKG)
	include_directories(${SDL2_INCLUDE_DIR})

	include_directories(${CMAKE_SOURCE_DIR}/include/)
	include_directories(${CMAKE_SOURCE_DIR}/include/AL)

	add_library(sound STATIC EXCLUDE_FROM_ALL ${soundSources})
	find_libs_for_vcpkg(sound)
	target_link_libraries(sound PRIVATE ${VORBISFILE_LIBRARY} ${VORBIS_LIBRARY} ${OGG_LIBRARY})
	target_link_libraries(sound PRIVATE ${OPENAL_LIBRARY})
endif (NOT NO_SOUND)
