#include "AudioRecordingManager.h"

#include <iostream>
#include <functional>

typedef struct WAV_HEADER {
  /* RIFF Chunk Descriptor */
  uint8_t RIFF[4] = {'R', 'I', 'F', 'F'}; // RIFF Header Magic header
  uint32_t ChunkSize;                     // RIFF Chunk Size
  uint8_t WAVE[4] = {'W', 'A', 'V', 'E'}; // WAVE Header
  /* "fmt" sub-chunk */
  uint8_t fmt[4] = {'f', 'm', 't', ' '}; // FMT header
  uint32_t Subchunk1Size = 16;           // Size of the fmt chunk
  uint16_t AudioFormat = 1; // Audio format 1=PCM,6=mulaw,7=alaw,     257=IBM
                            // Mu-Law, 258=IBM A-Law, 259=ADPCM
  uint16_t NumOfChan = 1;   // Number of channels 1=Mono 2=Sterio
  uint32_t SamplesPerSec = 16000;   // Sampling Frequency in Hz
  uint32_t bytesPerSec = 16000 * 2; // bytes per second
  uint16_t blockAlign = 2;          // 2=16-bit mono, 4=16-bit stereo
  uint16_t bitsPerSample = 16;      // Number of bits per sample
  /* "data" sub-chunk */
  uint8_t Subchunk2ID[4] = {'d', 'a', 't', 'a'}; // "data"  string
  uint32_t Subchunk2Size;                        // Sampled data length
} wav_hdr;

static void audioRecordingCallback(void* userdata, Uint8* stream, int len )
{
    AudioRecordingManager* recordManager = (AudioRecordingManager*) userdata;
    recordManager->processReceivedSpec(stream, len);
}

AudioRecordingManager::AudioRecordingManager(AudioConfig audioConfig) {
  m_audioConfig = audioConfig;
}

void AudioRecordingManager::init(char* wavFile) {
    using namespace std::placeholders;

    if (SDL_Init(SDL_INIT_AUDIO) != 0) {
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return;
    }

    SDL_AudioDeviceID playbackDeviceId = 0;

    SDL_zero(m_desiredSpec);
    m_desiredSpec.freq = m_audioConfig.frequency;
    m_desiredSpec.format = AUDIO_S16;
    m_desiredSpec.channels = m_audioConfig.channels;
    m_desiredSpec.samples = m_audioConfig.samples;
    m_desiredSpec.userdata = this;
    m_desiredSpec.callback = audioRecordingCallback;

    m_deviceCount = SDL_GetNumAudioDevices(SDL_TRUE);

    if(m_deviceCount < 1)
    {
        printf( "Unable to get audio capture device! SDL Error: %s\n", SDL_GetError() );
        return;
    }

    // pick the first audio device
    int audioIndex = 0;

    //Open recording device
    m_deviceId = SDL_OpenAudioDevice(SDL_GetAudioDeviceName(audioIndex, SDL_TRUE), SDL_TRUE,
                                     &m_desiredSpec, &m_receivedSpec, SDL_AUDIO_ALLOW_FORMAT_CHANGE);

    // Device failed to open
    if(m_deviceId == 0)
    {
        // Report error
        printf("Failed to open recording device! SDL Error: %s", SDL_GetError() );
        return;
    }

    //Calculate per sample bytes
    int bytesPerSample = m_receivedSpec.channels * (SDL_AUDIO_BITSIZE(m_receivedSpec.format) / 8);

    //Calculate bytes per second
    int bytesPerSecond = m_receivedSpec.freq * bytesPerSample;

    //Calculate buffer size
    m_bufferByteSize = m_bufferSeconds * bytesPerSecond;

    //Allocate and initialize byte buffer
    m_buffer = std::make_unique<Uint8[]>(m_bufferByteSize);
    std::memset(m_buffer.get(), 0, m_bufferByteSize);
}

void AudioRecordingManager::start() {
}

void AudioRecordingManager::stop() {
}

void AudioRecordingManager::processReceivedSpec(Uint8* stream, int len ) {
    //Copy audio from stream
	std::memcpy(&m_buffer[ m_bufferWritePosition ], stream, len);

	//Move along buffer
	m_bufferWritePosition += len;
}