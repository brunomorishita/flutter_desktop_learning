#include "AudioPlayManager.h"

#include <iostream>

#define IS_WIN32 defined(WIN32) || defined(_WIN32) || defined(__WIN32)

#ifdef IS_WIN32
#include <windows.h>
#endif

static void audioPlayCallback(void* userdata, Uint8* stream, int len )
{
    AudioPlayManager* playManager = (AudioPlayManager*) userdata;
    playManager->processReceivedSpec(stream, len);
}

void AudioPlayManager::init(const char* wavFile) {
    std::cout << "==> AudioPlayManager::init ==" << std::endl;

    if (SDL_Init(SDL_INIT_AUDIO) < 0)
	    return;

	Uint32 wavLength = 0;
    Uint8 *wavBuffer = NULL;

	if (SDL_LoadWAV(wavFile, &m_desiredSpec, &wavBuffer, &wavLength) == NULL ) {
		printf("Failed to load wav! SDL Error: %s", SDL_GetError() );
		return;
	}

    m_desiredSpec.callback = audioPlayCallback;
    m_desiredSpec.userdata = this;
    m_audioPos = wavBuffer;
    m_audioLen = wavLength;

    m_deviceCount = SDL_GetNumAudioDevices(SDL_TRUE);

    if(m_deviceCount < 1)
    {
        printf( "Unable to get audio device! SDL Error: %s\n", SDL_GetError() );
        return;
    }

    // pick the first audio device
    int audioIndex = 1;

    const char *device = SDL_GetAudioDeviceName(audioIndex, SDL_FALSE);
    printf( "device is %s\n", device );

    m_deviceId = SDL_OpenAudioDevice(device, 0, &m_desiredSpec, &m_receivedSpec,
                                     SDL_AUDIO_ALLOW_ANY_CHANGE);
    if(m_deviceId == 0)
    {
        printf("Failed to open playing device! SDL Error: %s", SDL_GetError() );
        return;
    }
}

void AudioPlayManager::start() {
    SDL_PauseAudioDevice(m_deviceId, SDL_FALSE);
}

void AudioPlayManager::stop() {
	SDL_LockAudioDevice(m_deviceId  );
	SDL_PauseAudioDevice( m_deviceId, SDL_TRUE );
	SDL_UnlockAudioDevice(m_deviceId  );

	SDL_CloseAudioDevice( m_deviceId );
	SDL_Quit();
	SDL_FreeWAV(m_audioPos);
}

void AudioPlayManager::processReceivedSpec(Uint8* stream, int len ) {
    if (m_audioLen == 0) {
        SDL_LockAudioDevice(m_deviceId  );
        SDL_PauseAudioDevice( m_deviceId, SDL_TRUE );
        SDL_UnlockAudioDevice(m_deviceId  );
        return;
    }

    len = ( len > m_audioLen ? m_audioLen : len );
    SDL_memset(stream, 0, len);
    SDL_MixAudioFormat(stream, m_audioPos, m_receivedSpec.format, len, SDL_MIX_MAXVOLUME);
    m_audioPos += len;
    m_audioLen -= len;
}