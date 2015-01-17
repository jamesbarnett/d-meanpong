module paddle;

import std.conv;
import derelict.sdl2.sdl;
import vector2;
import court;

class Paddle
{
  static immutable double MAX_Y_VELOCITY = 0.4;

private:
  int _width;
  int _height;
  Vector2 _position;
  Vector2 _velocity;
  int[2] _yRange;

public:

  this(Court court, double x)
  {
    _width = court.width() / 64;
    _height = court.height() / 8;
    _yRange = [0, court.height() - _height];
    _position.x = x;
    startingPosition();
  }

  ref Vector2 position() { return _position; }
  ref Vector2 velocity() { return _velocity; }

  SDL_Rect rect()
  {
    static SDL_Rect r;

    r.x = to!int(_position.x);
    r.y = to!int(_position.y);
    r.w = _width;
    r.h = _height;

    return r;
  }

  void update(long ms)
  {
    _position.y += _velocity.y * ms;

    if (_position.y < _yRange[0]) 
    {
      _position.y = _yRange[0];
      _velocity.y = 0;
    }
    
    if (_position.y > _yRange[1]) 
    {
      _position.y = _yRange[1];
      _velocity.y = 0;
    }
  }

  int width() { return _width; }
  int height() { return _height; }
  int[2] yRange() { return _yRange; }

  void startingPosition()
  {
    _position.y = _yRange[1] / 2;
    _velocity.x = 0.0;
    _velocity.y = 0.0;
  }
}
