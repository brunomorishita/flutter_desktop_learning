#ifndef FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H
#define FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H

#ifdef __cplusplus
extern "C" {
#endif

#define NATIVE_SDL_PUBLIC(type) __declspec(dllexport) type __stdcall

NATIVE_SDL_PUBLIC(void) record_init(char* wavFile);

NATIVE_SDL_PUBLIC(void) record_start();

NATIVE_SDL_PUBLIC(void) record_stop();

NATIVE_SDL_PUBLIC(void) play_init(char* wavFile);

NATIVE_SDL_PUBLIC(void) play_start();

NATIVE_SDL_PUBLIC(void) play_stop();

#ifdef __cplusplus
}
#endif

#endif //FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H
