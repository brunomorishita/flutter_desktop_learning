#include "AudioRecordingManager.h"

#include <iostream>
#include <functional>

#define IS_WIN32 defined(WIN32) || defined(_WIN32) || defined(__WIN32)

#ifdef IS_WIN32
#include <windows.h>
#endif

void platform_log(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
#if defined(IS_WIN32)
    char *buf = new char[4096];
    std::fill_n(buf, 4096, '\0');
    _vsprintf_p(buf, 4096, fmt, args);
    OutputDebugStringA(buf);
    delete[] buf;
#else
    vprintf(fmt, args);
#endif
    va_end(args);
}

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

AudioRecordingManager::~AudioRecordingManager() {
    if(t0.joinable())
        t0.join();
}

void AudioRecordingManager::init(const char* wavFile) {
    std::cout << "==> AudioRecordingManager::init" << std::endl;

    if (SDL_Init(SDL_INIT_AUDIO) != 0) {
        std::cout << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return;
    }

    createWavFile(wavFile);

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

    t0 = std::thread([&]() { consumeAudio(); });
}

void AudioRecordingManager::start() {
    SDL_PauseAudioDevice( m_deviceId, SDL_FALSE );
}

void AudioRecordingManager::stop() {
	SDL_LockAudioDevice( m_deviceId );
	SDL_PauseAudioDevice( m_deviceId, SDL_TRUE );
	SDL_CloseAudioDevice( m_deviceId );
	SDL_UnlockAudioDevice( m_deviceId );

	SDL_Quit();

	m_finished = true;
	m_cv.notify_one();
	if(t0.joinable())
	    t0.join();
}

void AudioRecordingManager::processReceivedSpec(Uint8* stream, int len ) {
    std::cout << "==> AudioRecordingManager::processReceivedSpec ==, len = "<< len << std::endl;

    //Copy audio from stream
	std::memcpy(&m_buffer[ m_bufferWritePosition ], stream, len);

	//Move along buffer
	m_bufferWritePosition += len;

	m_cv.notify_one();
}

void AudioRecordingManager::createWavFile(const std::string& fileName) {
    m_wavFile.open(fileName, std::ios::out | std::ios::binary);

    wav_hdr wav;

    // for now
    wav.ChunkSize = 0;
    wav.Subchunk2Size = 0;
    m_wavFile.write(reinterpret_cast<const char *>(&wav), sizeof(wav));
}

void AudioRecordingManager::consumeAudio() {
    do {
        std::unique_lock<std::mutex> lock(m_mutex);
        while (m_bufferWritePosition == m_bufferReadPosition && !m_finished )
        {
                m_cv.wait(lock, [&](){ return (m_bufferWritePosition > m_bufferReadPosition) || m_finished; });
        }

        int len =  m_bufferWritePosition - m_bufferReadPosition;

        std::cout << "==> writing " << len << " bytes into wav file" << std::endl;
        m_wavFile.write(reinterpret_cast<const char *>(&m_buffer[ m_bufferWritePosition ]), sizeof(Uint8) * len);

        //Move along buffer
        m_bufferReadPosition += len;

    } while(!m_finished);

    std::cout << "finished" << std::endl;

    m_wavFile.close();

    wav_hdr wav;
    wav.ChunkSize = m_bufferWritePosition + sizeof(wav_hdr) - 8;
    wav.Subchunk2Size = m_bufferWritePosition + sizeof(wav_hdr) - 44;
}