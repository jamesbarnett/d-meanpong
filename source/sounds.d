module sounds;

mixin template Sounds()
{
  Mix_Chunk* _aiCollisionSound;
  Mix_Chunk* _playerCollisionSound;
  Mix_Chunk* _wallCollisionSound;
  Mix_Chunk* _aiPointSound;
  Mix_Chunk* _playerPointSound;

  bool initSounds()
  {
    if (Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 4096) == -1)
      return false;

    _aiCollisionSound = Mix_LoadWAV("assets/paddle_collide_ai.wav");
    if (_aiCollisionSound is null) 
    {
      writeln("Failed to ai load collision sound!");
      return false;
    }

    _playerCollisionSound = Mix_LoadWAV("assets/paddle_collide_player.wav");
    if (_playerCollisionSound is null) 
    {
      writeln("Failed to load player collision sound!");
      return false;
    }

    _wallCollisionSound = Mix_LoadWAV("assets/wall_collide.wav");
    if (_wallCollisionSound is null) 
    {
      writeln("Failed to load wall collision sound!");
      return false;
    }

    _aiPointSound = Mix_LoadWAV("assets/disappointed_crowd_idiot.wav");
    if (_aiPointSound is null)
    {
      writeln("Failed to load AI point sound!");
      return false;
    }

    _playerPointSound = Mix_LoadWAV("assets/pleased_crowd_about_time.wav");
    if (_playerPointSound is null)
    {
      writeln("Failed to load Player Point sound!");
      return false;
    }

    return true;
  }

  void playAiCollideSound()
  {
    if (Mix_PlayChannel(-1, _aiCollisionSound, 0) == -1)
    {
      writeln("playAiCollideSound failed: ", Mix_GetError());
    }
  }

  void playPlayerCollideSound()
  {
    if (Mix_PlayChannel(-1, _playerCollisionSound, 0) == -1)
    {
      writeln("playPlayerCollideSound failed: ", Mix_GetError());
    }
  }

  void playWallCollideSound()
  {
    if (Mix_PlayChannel(-1, _wallCollisionSound, 0) == -1)
    {
      writeln("playWallCollideSound failed: ", Mix_GetError());
    }
  }

  void playAiPointSound()
  {
    if (Mix_PlayChannel(-1, _aiPointSound, 0) == -1)
    {
      writeln("playAiPointSound failed: ", Mix_GetError());
    }
  }

  void playPlayerPointSound()
  {
    if (Mix_PlayChannel(-1, _playerPointSound, 0) == -1)
    {
      writeln("playPlayerPointSound failed: ", Mix_GetError());
    }
  }
}

