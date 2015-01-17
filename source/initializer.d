module initializer;

import sounds;

mixin template Initializer()
{
  SDL_Window* _mainWindow;
  SDL_Renderer* _renderer;

  void loadDerelict()
  {
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2Mixer.load();
    DerelictSDL2ttf.load();
    DerelictSDL2Net.load();
  }

  bool initSDL()
  {
    if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
    {
      writeln("Failed to initialize SDL2: ", SDL_GetError());
      return false;
    }

    return true;
  }

  bool initEverything()
  {
    if (!initSDL()) return false;
    if (!initFont()) return false;
    if (!createWindow()) return false;
    if (!createRenderer()) return false;
    if (!initImage()) return false;

    return true;
  }

  bool initFont()
  {
    if (-1 == TTF_Init())
    {
      writeln("Failed to initialize SDL_TTF: ", TTF_GetError());
      return false;
    }

    return true;
  }

  bool initImage()
  {
    int imageFlags = IMG_INIT_PNG;

    if (!(IMG_Init(imageFlags) & imageFlags))
    {
      writeln("Failed to initialize SDL_IMG: ", IMG_GetError());
      return false;
    }

    return true;
  }

  bool createWindow()
  {
    _mainWindow = SDL_CreateWindow(
        "MeanPong in D",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        1024,
        768,
        SDL_WINDOW_OPENGL);

    if (_mainWindow is null)
    {
      writeln("Failed to create window: ", SDL_GetError());
      return false;
    }

    return true;
  }

  bool createRenderer()
  {
    _renderer = SDL_CreateRenderer(_mainWindow, -1,
      SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

    if (_renderer is null)
    {
      writeln("Failed to create renderer: ", SDL_GetError());
      return false;
    }
    
    return true;
  }
}

