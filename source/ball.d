module ball;

import std.conv;
import derelict.sdl2.sdl;
import vector2;
import court;

class Ball
{
private:
  int _diameter;
  int[2] _yRange;
  Vector2 _position;
  Vector2 _velocity;
  Court _court;

public:
  this(Court court)
  {
    _diameter = to!int(court.height() / 48);
    _yRange = [0, court.height() - _diameter];
    _court = court;
    startingPosition();
  }

  void startingPosition()
  {
    _position.x = _court.width() / 2 - _diameter / 2;
    _position.y = _court.height() / 2 - _diameter / 2;
    _velocity.x = _court.width() / 1024.0 * 0.3;
    _velocity.y = 0;
  }
 
  void update(long ms)
  {
    _position.x += _velocity.x * ms;
    _position.y += _velocity.y * ms;
  }

  SDL_Rect rect()
  {
    static SDL_Rect r;

    r.x = to!int(_position.x);
    r.y = to!int(_position.y);
    r.w = _diameter;
    r.h = _diameter;

    return r;
  }

  Vector2 midpoint()
  {
    static Vector2 m;

    m.x = _position.x + _diameter / 2;
    m.y = _position.y + _diameter / 2;

    return m;
  }

  ref Vector2 velocity() { return _velocity; }
  ref Vector2 position() { return _position; }
  int[2] yRange() { return _yRange; }
}
