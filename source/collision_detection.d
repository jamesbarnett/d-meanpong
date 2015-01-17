module collision_detection;

import derelict.sdl2.sdl;

mixin template CollisionDetection()
{
  bool checkCollision(SDL_Rect a, SDL_Rect b)
  {
    SDL_bool result = SDL_HasIntersection(&a, &b);
    if (result is SDL_TRUE) return true;
    else return false;
  } 
}

