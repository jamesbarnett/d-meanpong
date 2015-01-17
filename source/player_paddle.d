module player_paddle;

import paddle;
import court;

class PlayerPaddle : Paddle
{
  this(Court court)
  {
    super(court, court.width() / 64 * 3.0); 
  }
}
