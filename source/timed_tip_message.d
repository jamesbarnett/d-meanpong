module timed_tip_message;

import std.stdio;
import std.string;
import std.path;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import court;

class TimedTipMessage
{
  SDL_Renderer* _renderer;
  Court _court;
  SDL_Color _color;
  immutable(char*) _msg;
  long _msecs;
  long _start;
  long _end;
  TTF_Font* _tipFont;
  bool _isInitialized = false;

  this(SDL_Renderer* renderer, Court court, string msg, long msecs)
  {
    _renderer = renderer;
    _court = court;
    _msg = toStringz(msg);
    _msecs = msecs;
    _color.r = 255;
    _color.g = 255;
    _color.b = 255;
    _color.a = 255;
    _start = SDL_GetTicks();
    _end = _start + msecs;
    _isInitialized = false;
  }

  void draw()
  {
    static int w, h;

    if (!_isInitialized) 
    {
      SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 255);
      /*writeln("Timed tip calling render clear");*/
      /*SDL_RenderClear(_renderer);*/
      init();
    }

    if (SDL_GetTicks() < _end)
    {
      if (0 != TTF_SizeText(_tipFont, _msg, &w, &h))
      {
        throw new Exception(format("TTF_SizeText failed: %s", TTF_GetError()));
      }

      SDL_Surface* surface = TTF_RenderText_Solid(_tipFont, _msg, _color);
      SDL_Texture* texture = SDL_CreateTextureFromSurface(_renderer, surface);

      static SDL_Rect rect;
      rect.x = _court.width() / 2 - w / 2;
      rect.y = 3 * _court.height() / 4;
      rect.w = w;
      rect.h = h;
      static SDL_Rect sourceRect;
      sourceRect.x = 0;
      sourceRect.y = 0;
      sourceRect.w = w;
      sourceRect.h = h;

      SDL_RenderCopy(_renderer, texture, &sourceRect, &rect);
      SDL_DestroyTexture(texture);
      SDL_FreeSurface(surface);
      SDL_RenderPresent(_renderer);
      fadeColor();
    }
  }

  private void init()
  {
    if (!_isInitialized)
    {
      immutable char* fontPath = toStringz(buildPath("assets", "Verdana.ttf"));
      _tipFont = TTF_OpenFont(fontPath, 24);
      _isInitialized = true;
    }
  }

  private void fadeColor()
  {
    _color.r -= 5;
    _color.g -= 5;
    _color.b -= 5;
    _color.a -= 5;
  }
}
