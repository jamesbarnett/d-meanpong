module game_state;

enum GameState { 
  splash, 
  clearSplash,
  help, 
  notReady, 
  playing, 
  playerPoint, 
  aiPoint, 
  playerWon, 
  playerLost, 
  credits, 
  closing 
};
