module game;

import std.stdio;
import std.string;
import std.file;
import std.exception;
import std.path;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
import derelict.sdl2.net;
import initializer;
import game_state;
import court;
import paddle;
import player_paddle;
import ai_paddle;
import ball;
import collision_detection;
import sounds;

class Game
{
  mixin Initializer;
  mixin CollisionDetection;
  mixin Sounds;

private:
  bool _isRunning = true;
  GameState _gameState;
  Court _court;
  PlayerPaddle _player;
  AiPaddle _ai;
  Ball _ball;
  TTF_Font* _scoreFont;
  TTF_Font* _gameOverFont;
  TTF_Font* _tipFont;
  int _playerScore = 0;
  int _aiScore = 0;
  static const int MAX_POINTS = 8;

public:
  this()
  {
    _gameState = GameState.splash;
    _court = new Court;
    _player = new PlayerPaddle(_court);
    _ai = new AiPaddle(_court);
    _ball = new Ball(_court);
  }

  void run()
  {
    immutable long timeDelta = 1000 / 60;
    long timeAccumulator = 0;
    SDL_Event event;
    long timeForFrame;
    long startTime;

    loadDerelict();
    initEverything();
    initFonts();
    initSounds();

    while (_isRunning)
    {
      timeForFrame = 0;
      startTime = SDL_GetTicks();

      while (timeAccumulator >= timeDelta)
      {
        update(timeDelta);
        timeAccumulator -= timeDelta;
      }

      while (SDL_PollEvent(&event))
      {
        if (event.type == SDL_QUIT) _isRunning = false;

        updatePlayerInput(event);
      }

      draw();
      timeAccumulator += SDL_GetTicks() - startTime;
    }
  }

  private void updatePlayerInput(SDL_Event event)
  {
    if (event.type == SDL_KEYDOWN && SDL_SCANCODE_A == event.key.keysym.scancode)
    {
      _player.velocity().y = -Paddle.MAX_Y_VELOCITY;
    }

    if (event.type == SDL_KEYDOWN && SDL_SCANCODE_D == event.key.keysym.scancode)
    {
      _player.velocity().y = Paddle.MAX_Y_VELOCITY;
    }
    
    if (SDL_KEYDOWN == event.type && SDL_SCANCODE_W == event.key.keysym.scancode)
    {
      _player.velocity().y = 0;
    }
  }

  private void update(long ms)
  {
    switch (_gameState)
    {
      static SDL_Event event;

      case GameState.splash:
        if (SDL_PollEvent(&event))
        {
          if (event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_RETURN)
          {
            _gameState = GameState.playing;
          }
        }
        break;

      case GameState.notReady:
        break;

      case GameState.playing:
        _player.update(ms);
        _ball.update(ms);
        _ai.update(_ball, ms);
        updatePlaying(ms);
        break;

      case GameState.playerPoint:
        ++_playerScore;
        if (_playerScore < MAX_POINTS)
          newPoint();
        else 
          _gameState = GameState.playerWon;
        playPlayerPointSound();
        break;

      case GameState.aiPoint:
        ++_aiScore;
        if (_aiScore < MAX_POINTS)
          newPoint();
        else
          _gameState = GameState.playerLost;
        playAiPointSound();
        break;

      case GameState.playerWon:
        if (SDL_PollEvent(&event))
        {
          if (event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_RETURN)
          {
            resetGame();
          }
        }
        break;

      case GameState.playerLost:
        if (SDL_PollEvent(&event))
        {
          if (event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_RETURN)
          {
            resetGame();
          }
        }
        break;

      case GameState.credits:
        break;

      default:
        break;
    }
  }

  private void updatePlaying(long ms)
  {
    SDL_Rect playerRect = _player.rect();
    SDL_Rect aiRect = _ai.rect();
    SDL_Rect ballRect = _ball.rect();
    immutable double PADDLE_Y_AFFECT = 0.04;

    if (checkCollision(playerRect, ballRect) && _ball.velocity().x < 0)
    {
      _ball.velocity().x = -_ball.velocity().x;

      if (_player.velocity().y != 0)
      {
        _ball.velocity().y += PADDLE_Y_AFFECT * _player.velocity().y * ms;
      }

      playPlayerCollideSound();
    }

    if (checkCollision(aiRect, ballRect) && _ball.velocity().x > 0)
    {
      _ball.velocity().x = -_ball.velocity().x;

      if (_ai.velocity().y != 0)
      {
        _ball.velocity().y += PADDLE_Y_AFFECT * _ai.velocity().y * ms;
      }

      playAiCollideSound(); 
    }

    if (_ball.position().y < _ball.yRange()[0] || _ball.position().y > _ball.yRange()[1])
    {
      if (_ball.position().y < _ball.yRange()[0]) _ball.position().y = _ball.yRange()[0];
      if (_ball.position().y > _ball.yRange()[1]) _ball.position().y = _ball.yRange()[1];

      _ball.velocity().y = -_ball.velocity().y;

      playWallCollideSound();
    }

    if (_ball.position().x > _court.width())
    {
      _gameState = GameState.playerPoint;
    }
    else if (_ball.position().x < 0)
    {
      _gameState = GameState.aiPoint;
      playAiCollideSound();
    }
  }

  private void draw()
  {
    switch (_gameState)
    {
      case GameState.splash:
        drawSplash();
        break;

      case GameState.playing:
      case GameState.aiPoint:
      case GameState.playerPoint:
        drawPlaying();
        break;

      case GameState.playerWon:
        drawPlayerWon();
        break;

      case GameState.playerLost:
        drawPlayerLost();
        break;

      default:
        break;
    }
  }

  private void drawSplash()
  {
    string path = buildPath("assets", "splash.png");
    SDL_Texture* texture = IMG_LoadTexture(_renderer, toStringz(path));
    SDL_RenderClear(_renderer);
    
    immutable char* tip = "Press A for Up, D for Down, and W to stop";
    int w, h;
    SDL_Color white = { 255, 255, 255, 255 };
    if (0 != TTF_SizeText(_tipFont, tip, &w, &h))
    {
      writeln("tip failed to get size!");
    }

    SDL_RenderCopy(_renderer, texture, null, null);
    SDL_Surface* tipSurface = TTF_RenderText_Solid(_tipFont, tip, white);
    SDL_Rect tipRect;
    tipRect.x = _court.width() / 2 - w / 2;
    tipRect.y = 3 * _court.height() / 4 - h / 2;
    tipRect.w = w;
    tipRect.h = h;
    SDL_Texture* tipTexture = SDL_CreateTextureFromSurface(_renderer, tipSurface);
    SDL_RenderCopy(_renderer, tipTexture, null, &tipRect);
    SDL_RenderPresent(_renderer);
  }

  private void drawPlaying()
  {
    drawBackground();
    drawPlayer();
    drawAI();
    drawBall();
    drawScore();
    SDL_RenderPresent(_renderer);
  }

  private void drawBackground()
  {
    SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 255);
    SDL_RenderClear(_renderer);
  }

  private void drawPaddle(Paddle paddle)
  {
    SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 255);
    SDL_Rect rect = paddle.rect();
    SDL_RenderFillRect(_renderer, &rect);
  }

  private void drawPlayer()
  {
    drawPaddle(_player);
  }

  private void drawAI()
  {
    drawPaddle(_ai);
  }

  private void drawBall()
  {
    SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 255);
    SDL_Rect rect = _ball.rect();
    SDL_RenderFillRect(_renderer, &rect);
  }

  private void drawScore()
  {
    static SDL_Color scoreColor = {0x80, 0x80, 0x80, 0x80};
    drawStringSolid(_court.width() / 16, 40, format("%s", _playerScore), _scoreFont, scoreColor);
    drawStringSolid(_court.width() / 16, 40, format("%s", _aiScore), _scoreFont, scoreColor, true);
  }

  private void drawStringSolid(int x, int y, string str, TTF_Font* font, SDL_Color color, bool isRightAligned = false)
  {
    static int w, h;
    immutable char* sz = toStringz(str);

    if (0 != TTF_SizeText(font, sz, &w, &h))
    {
      throw new Exception(format("TTF_SizeText failed: %s", TTF_GetError()));
    }

    SDL_Surface* surface = TTF_RenderText_Solid(font, sz, color);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(_renderer, surface);

    static SDL_Rect stringRect;
    stringRect.x = isRightAligned ? _court.width() - w - x : x;
    stringRect.y = y;
    stringRect.w = w;
    stringRect.h = h;

    SDL_RenderCopy(_renderer, texture, null, &stringRect);
    SDL_DestroyTexture(texture);
    SDL_FreeSurface(surface);
  }

  private void drawGameOverMessage(string msg)
  {
    static int w, h;
    static SDL_Color gameOverColor = {255, 255, 255, 255};
    immutable char* sz = toStringz(msg);

    SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 255);
    SDL_RenderClear(_renderer);

    if (0 != TTF_SizeText(_gameOverFont, sz, &w, &h))
    {
      throw new Exception(format("TTF_SizeText failed: %s", TTF_GetError()));
    }

    SDL_Surface* surface = TTF_RenderText_Solid(_gameOverFont, sz, gameOverColor);

    static SDL_Rect rect;
    rect.x = _court.width() / 2 - w / 2;
    rect.y = _court.height() / 2 - h / 2;
    rect.w = w;
    rect.h = h;

    immutable char* tip = "Press Enter to play again";
    
    if (0 != TTF_SizeText(_tipFont, tip, &w, &h))
    {
      writeln("tips failed to get size!");
    }

    SDL_Surface* tipSurface = TTF_RenderText_Solid(_tipFont, tip, gameOverColor);

    static SDL_Rect tipRect;
    tipRect.x = _court.width() / 2 - w / 2;
    tipRect.y = 3 * _court.height() / 4 - h / 2;
    tipRect.w = w;
    tipRect.h = h;
    SDL_Texture* tipTexture = SDL_CreateTextureFromSurface(_renderer, tipSurface);
    SDL_Texture* texture = SDL_CreateTextureFromSurface(_renderer, surface);
    SDL_RenderCopy(_renderer, texture, null, &rect);
    SDL_RenderCopy(_renderer, tipTexture, null, &tipRect);

    SDL_RenderPresent(_renderer);
    SDL_DestroyTexture(tipTexture);
    SDL_DestroyTexture(texture);
    SDL_FreeSurface(surface);
    SDL_FreeSurface(tipSurface);
  }

  private void drawPlayerWon()
  {
    string msg = "I'M SOOO IMPRESSED";
    drawGameOverMessage(msg);
  }

  private void drawPlayerLost()
  {
    string msg = "YOU SUCK!";
    drawGameOverMessage(msg);
  }

  private void newPoint()
  {
    _player.startingPosition();
    _ai.startingPosition();
    _ball.startingPosition();
    _gameState = GameState.playing;
  }

  private void resetGame()
  {
    _playerScore = 0;
    _aiScore = 0;
    _ball.startingPosition();
    _ai.startingPosition();
    _player.startingPosition();
    _gameState = GameState.playing;
  }

  private bool initFonts()
  {
    immutable char* fontPath = toStringz(buildPath("assets", "Verdana.ttf"));
    _scoreFont = TTF_OpenFont(fontPath, 60);
    if (_scoreFont is null)
    {
      writeln("Failed to open score font: ", TTF_GetError());
      return false;
    }

    _gameOverFont = TTF_OpenFont(fontPath, 88);
    if (_gameOverFont is null)
    {
      writeln("Failed to open game over font: ", TTF_GetError());
      return false;
    }

    _tipFont = TTF_OpenFont(fontPath, 24);
    if (_tipFont is null)
    {
      writeln("Failed to open tip font: ", TTF_GetError());
      return false;
    }

    return true;
  }
}

