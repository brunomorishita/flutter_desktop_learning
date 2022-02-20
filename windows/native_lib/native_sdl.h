#ifndef FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H
#define FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H

#ifdef __cplusplus
extern "C" {
#endif

#define NATIVE_SDL_PUBLIC(type) __declspec(dllexport) type __stdcall

NATIVE_SDL_PUBLIC(void) init(char* wavFile);

NATIVE_SDL_PUBLIC(void) start();

NATIVE_SDL_PUBLIC(void) stop();

#ifdef __cplusplus
}
#endif

#endif //FLUTTER_DESKTOP_LEARNING_NATIVE_SDL_H
