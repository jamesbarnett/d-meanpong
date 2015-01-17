module ai_paddle;

import std.random;
import std.stdio;
import court;
import paddle;
import ball;
import vector2;

class AiPaddle : Paddle
{
  this(Court court)
  {
    super(court, court.width() / 64 * 20 * 3.0);
  }

  void think(Ball ball)
  {
    int x = uniform(0, 9);

    switch (x)
    {
      case 0: .. case 8:
        realThink(ball);
        break;

      // Make the AI indecisive every once in a while
      case 9:
        velocity().y = 0;
        break;

      default:
        break;

    }
  }

  public Vector2 midpoint()
  {
    static Vector2 m;

    m.x = position().x + width() / 2;
    m.y = position().y + height() / 2;

    return m;
  }

  private void realThink(Ball ball)
  {
    if (ball.midpoint().y < midpoint().y)
    {
      velocity().y = -MAX_Y_VELOCITY;
    }
    else if (ball.midpoint().y > midpoint().y)
    {
      velocity().y = MAX_Y_VELOCITY;
    }
    else
    {
      velocity().y = 0;
    }
  }

  public void update(Ball ball, long ms)
  {
    think(ball);
    position().y += velocity().y * ms;

    if (position().y < yRange()[0])
    {
      position().y = yRange()[0];
      velocity().y = MAX_Y_VELOCITY;
    }

    if (position().y > yRange()[1])
    {
      position().y = yRange()[1];
      velocity().y = -MAX_Y_VELOCITY;
    }
  }
}

