// Add small delay when aliens hit wall and change y-level
// Alien clipping into wall

// Bug: laser speed increases with more lasers on the screen.

// Add highscore screen
// Shields:
//   - Add way for player to know how much HP shield is at

PImage alienA, alienB, alien1A, alien1B, alien2A, alien2B;
PImage UFO;
PImage tank;
PImage shield;
PImage logo;

boolean tankLeft = false, tankRight = false;
boolean shootLaser = false;

int tankXPos = 400, tankYPos = 725;
int tankHeight = 28, tankWidth = 45;
int alienWidth = 30, alienHeight = 22;

int laserWidth = 4, laserHeight = 26, alienLaserWidth = 4, alienLaserHeight = 15;
int numOfAlienLasers = 0;

int numOfRows = 5;
int numOfAliensPerRow = 11;

int tankSpeed = 5, alienSpeed = 35, laserSpeed = 8, alienLaserSpeed = 1;

int[][] alienXPos = new int[numOfRows][numOfAliensPerRow];
int[][] alienYPos = new int[numOfRows][numOfAliensPerRow];
boolean[][] alienAlive = new boolean[numOfRows][numOfAliensPerRow];

int[] alienLaserXPos = new int[3];
int[] alienLaserYPos = new int[3];
boolean[] alienLaserAlive = new boolean[3];

int shieldYPos = 650;
int[] shieldXPos = new int[4];
int[] shieldHealth = new int[4];
int shieldWidth = 100, shieldHeight = 75;

int laserXPos, laserYPos;

int currentTime;

int animationState;
int gameState;
// 0 = main menu, 1 = instructions, 2 = game, 3 = endscreen

boolean alienHittingLeftWall = false;
boolean alienHittingRightWall = false;
int furthestAlienAliveRightIndex = 10;
int furthestAlienAliveLeftIndex = 0;

boolean laserOnScreen = false;

boolean shootAlienLaser = false;

int playerScore = 0;

int numberOfAliensAlive;

int alienLaserTimer = 0;

int playerLives;

boolean UFOVisible = false;
int UFOWidth = 60, UFOHeight = 26;
int UFOXPos = 0-UFOWidth/2, UFOYPos = 100, UFOSpeed = 2;
int UFOTimer = 0;

int gameCondition = 0;
// 0 = null, 1 = won, 2 = lose

int level = 1;

void setup() {
  size(800,800);
  alienA = loadImage("alienA.png");
  alienB = loadImage("alienB.png");
  alien1A = loadImage("alien1A.png");
  alien1B = loadImage("alien1B.png");
  alien2A = loadImage("alien2A.png");
  alien2B = loadImage("alien2B.png");
  
  UFO = loadImage("UFO.png");
  
  tank = loadImage("tank.png");
  
  shield = loadImage("shield.png");

  logo = loadImage("logo.png");
  
  alienA.resize(30,24);
  alienB.resize(30,24);
  
  textAlign(CENTER,CENTER);
  imageMode(CENTER);
  rectMode(CENTER);
  
  initialize();

  gameState = 0;
}

void draw() {
  if(gameState == 0) {
    mainMenu();
  }
  else if(gameState == 1) {
    instructions();
  }
  else if(gameState == 2) {
    game();
  }
  else if(gameState == 3) {
    endgame();
  }
}

void mainMenu() {
  background(#000000);
  image(logo,400,200);
  
  fill(#FFFFFF);
  rect(400,400,100,30);
  rect(400,450,100,30);
  fill(#000000);
  text("Play",400,400); 
  text("Instructions",400,450);
}

void instructions() {
  // Add instructions/how to play, rules
  background(#000000);
  fill(#FFFFFF);
  textSize(28);
  text("How To Play",400,100);
  textSize(12);
  text("Use Left Arrow and Right Arrow control the tank.",400,200);
  text("Use spacebar to shoot the aliens. The goal of the game is to",400,250);
  text("stop the aliens from reaching the bottom of the screen.",400,300);
  text("Once all aliens have been cleared from the screen,",400,350);
  text("you can move on to the next level which will have increasing difficulty.",400,400);
  text("",400,450);
  
  // Return to menu:
  fill(#FFFFFF);
  rect(400,600,120,30);
  fill(#000000);
  text("Return To Main Menu",400,600);
}

void game() {  
  println(shieldHealth);
  
  background(#000000);
  image(tank,tankXPos,tankYPos);
  drawAliens();
  moveTank();
  moveAliens();
  checkNumberOfAliensAlive();
  drawShields();
  
  drawScore();
  drawLives();
  drawLevel();

  if(shootLaser && !laserOnScreen) {
    laserOnScreen = true;
    laserXPos = tankXPos;
    laserYPos = tankYPos-tankHeight;
  } 
  
  if(laserOnScreen) {
    drawLaser(laserXPos,laserYPos,laserWidth,laserHeight);
    moveLaser();
    checkLaserCollision();
  }
  
  for(int i = 0; i < 3; i++) {
    if(millis() - alienLaserTimer > int(random(2,6))*1000-(level*50)) {
      if(numOfAlienLasers < 3 && !alienLaserAlive[i]) {
        alienLaserXPos[i] = alienXPos[int(random(0,numOfRows))][int(random(0,numOfAliensPerRow))];
        alienLaserYPos[i] = alienYPos[int(random(0,numOfRows))][int(random(0,numOfAliensPerRow))];
        //drawAlienLaser(alienLaserXPos[i],alienLaserYPos[i],alienLaserWidth,alienLaserHeight);
        alienLaserAlive[i] = true;
        numOfAlienLasers++;
        alienLaserTimer = millis();
      }
    }
  }
  
  for(int i = 0; i < 3; i++) {
    if(alienLaserAlive[i]) {
      drawAlienLaser(alienLaserXPos[i],alienLaserYPos[i],alienLaserWidth,alienLaserHeight);
      moveAlienLaser();
      checkAlienLaserCollision();
    }
  }

  if(UFOVisible) {
    drawUFO();
    moveUFO();
    checkUFOCollision();
  }
  
  //println(millis()-UFOTimer);
  if(millis() - UFOTimer > int(random(20,30))*1000) {
  //if(millis() - UFOTimer > int(random(5,10))*1000) {
    UFOVisible = true;
    //UFOTimer = millis();
  }
  
  // win condition
  if(numberOfAliensAlive <= 0) {
    gameState = 3;
    gameCondition = 1;
  }
  
  // lose condition
  if(alienHittingMaxYLevel() || playerLives <= 0) {
    gameState = 3;
    gameCondition = 2;
  }
}

void endgame() {
  background(#000000);
  fill(#FFFFFF);
  text("Game Over",400,400);

  if(gameCondition == 1) {
    win();  
  }
  else if(gameCondition == 2) {
    lose();
    
  }
}

void win() {
  background(#000000);
  fill(#FFFFFF);
  text("Level Cleared",400,300);
  rect(400,500,100,30);
  fill(#000000);
  text("Next Level",400,500);
}

void lose() {
  background(#000000);
  fill(#FFFFFF);
  text("Game Over",400,400);
  rect(400,500,100,30);
  rect(400,550,120,30);
  fill(#000000);
  text("Play Again",400,500);
  text("Return To Main Menu",400,550);
}

void initialize() {
  // Variable reset:
  level = 1;
  alienSpeed = 35;
  playerScore = 0; 
  playerLives = 3;
  gameCondition = 0;
  numOfAlienLasers = 0;
  UFOTimer = millis(); 
  alienLaserTimer = millis();
  UFOXPos = 0-UFOWidth/2;
  laserOnScreen = false;
  
  // Alien Laser Reset:
  for(int i = 0; i < 3; i++) {
    alienLaserAlive[i] = false;
  }
  
  // Alien Reset:
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienAlive[i][j] = true;
    }
  }
  
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienXPos[i][j] = j*50 + 150;
    }
  }
  
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienYPos[i][j] = i*35 + 100;
    }
  }
  
  // Shield Reset:
  for(int i = 0; i < 4; i++) {
    shieldXPos[i] = i*200 + 100;
    shieldHealth[i] = 4;
  }
}

void nextLevel() {
  level++;
  alienSpeed = 35;
  gameCondition = 0; 
  numOfAlienLasers = 0;
  UFOTimer = millis(); 
  alienLaserTimer = millis(); 
  UFOXPos = 0-UFOWidth/2; 
  laserOnScreen = false;
  
  // Alien Laser Reset:
  for(int i = 0; i < 3; i++) {
    alienLaserAlive[i] = false;
  }
  
  // Alien Reset:
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienAlive[i][j] = true;
    }
  }
  
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienXPos[i][j] = j*50 + 150;
    }
  }
  
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      alienYPos[i][j] = i*35 + 100; 
    }
  }
  
  // Shield Reset:
  for(int i = 0; i < 4; i++) {
    shieldXPos[i] = i*200 + 100;
    shieldHealth[i] = 4;
  }
}

void moveTank() {
  if(tankLeft && tankXPos-tankWidth/2 > 0) {
    tankXPos -= tankSpeed;
  }
  if(tankRight && tankXPos+tankWidth/2 < 800) {
    tankXPos += tankSpeed;
  }
}

void drawAliens() {
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      if(alienAlive[i][j]) {
        if(animationState == 0) {
          if(i == 0) {
            image(alienA,alienXPos[i][j],alienYPos[i][j]);
          }
          if(i == 1 || i == 2) {
            image(alien1A,alienXPos[i][j],alienYPos[i][j]);
          }
          if(i == 3 || i == 4) {
            image(alien2A,alienXPos[i][j],alienYPos[i][j]);
          }
        } 
        else if(animationState == 1) {
          if(i == 0) {
            image(alienB,alienXPos[i][j],alienYPos[i][j]);
          }
          if(i == 1 || i == 2) {
            image(alien1B,alienXPos[i][j],alienYPos[i][j]);
          }
          if(i == 3 || i == 4) {
            image(alien2B,alienXPos[i][j],alienYPos[i][j]);
          }        
        }
      }
    }
  }
}

void moveAliens() {
  if(millis()-currentTime > 1000-(level*50)) {
    checkAlienHittingWall();
    for(int i = 0; i < 5; i++) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienXPos[i][j] += alienSpeed;
        currentTime = millis();
      }
    }
    if(animationState == 0) {
      animationState = 1;
    }
    else {
      animationState = 0;
    }
  }
}

void checkNumberOfAliensAlive() {
  int num = 0;
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      if(alienAlive[i][j]) {
        num++;
      }
    }
  }
  numberOfAliensAlive = num;
}

boolean alienHittingMaxYLevel() {
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      if(alienAlive[i][j] && alienYPos[i][j] > 600) {
        return(true);
      } 
    }
  }
  return(false);
}

void checkAlienHittingWall() {
  int currentFurthestRight = 0;
  int currentFurthestLeft = numOfAliensPerRow-1;
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      if(alienAlive[i][j] && j > currentFurthestRight) {
        currentFurthestRight = j;
      }
      if(alienAlive[i][j] && j < currentFurthestLeft) {
        currentFurthestLeft = j;
      }
      furthestAlienAliveRightIndex = currentFurthestRight;
      furthestAlienAliveLeftIndex = currentFurthestLeft;
    }
  }
  
  for(int i = 0; i < 5; i++) {
    if(alienXPos[i][furthestAlienAliveLeftIndex]-alienWidth/2 < 0) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienYPos[i][j] += 35;
        alienSpeed = abs(alienSpeed);
      }
    }
    if(alienXPos[i][furthestAlienAliveRightIndex]+alienWidth/2 > width) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienYPos[i][j] += 35;
        alienSpeed = -abs(alienSpeed);
      }
    }
  }
}

void drawLaser(int x, int y, int w, int h) {
  fill(#FFFFFF);
  rect(x,y,w,h);
}

void moveLaser() {
  laserYPos -= laserSpeed;
}

void drawAlienLaser(int x, int y, int w, int h) {
  fill(#1CFF62);
  rect(x,y,w,h);
}

// Bug: laser speed increases with more lasers on screen.
void moveAlienLaser() { // <-- fix  
  //if(numOfAlienLasers == 1) {
  //  alienLaserSpeed = 3;
  //}
  //else if(numOfAlienLasers == 2) {
  //  alienLaserSpeed = 2;
  //}
  //else if(numOfAlienLasers == 3) {
  //  alienLaserSpeed = 1;
  //}
  for(int i = 0; i < 3; i++) {
    alienLaserYPos[i] += alienLaserSpeed;
  }
}
 
void checkLaserCollision() {
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      //if(alienAlive[i][j] && (laserXPos-laserWidth/2 > alienXPos[i][j]-alienWidth/2 && laserXPos+laserWidth/2 < alienXPos[i][j]+alienWidth/2) && (laserYPos > alienYPos[i][j]-alienHeight/2 && laserYPos < alienYPos[i][j]+alienHeight/2)) {
      if(alienAlive[i][j] && abs(laserXPos-alienXPos[i][j]) < 25 && abs(laserYPos-alienYPos[i][j]) < 15) {
        laserOnScreen = false;
        alienAlive[i][j] = false;
        numberOfAliensAlive--;

        if(i == 0) {
          playerScore += 30;
        }
        else if(i == 1 || i == 2) {
          playerScore += 20;
        }
        else if(i == 3 || i == 4) {
          playerScore += 10;
        }
      }
    }
  }
  
  for(int i = 0; i < 4; i++) {
    if(shieldHealth[i] > 0 && abs(laserXPos-shieldXPos[i]) < shieldWidth/2 && abs(laserYPos-shieldYPos) < shieldHeight/2) {
      laserOnScreen = false;
    }
  }
  
  if(laserYPos-laserHeight/2 < 0) {
    laserOnScreen = false;
  }
}

void checkAlienLaserCollision() {
  for(int i = 0; i < 3; i++) {
    if(alienLaserAlive[i] && alienLaserXPos[i] > tankXPos-tankWidth/2 && alienLaserXPos[i] < tankXPos+tankWidth/2 && alienLaserYPos[i]-alienLaserHeight/2 > tankYPos-tankHeight/2 && alienLaserYPos[i]+alienLaserHeight/2 < tankYPos+tankHeight/2) {
      alienLaserAlive[i] = false;
      numOfAlienLasers--;
      playerLives--;  
      println("tank hit");
    }
    
    if(alienLaserAlive[i] && alienLaserYPos[i] > height) {
      alienLaserAlive[i] = false;
      numOfAlienLasers--;
    }
    
    for(int j = 0; j < 4; j++) {
      if(alienLaserAlive[i] && shieldHealth[j] > 0 && abs(alienLaserXPos[i]-shieldXPos[j]) < shieldWidth/2 && abs(alienLaserYPos[i]-shieldYPos) < shieldHeight/2) {
        alienLaserAlive[i] = false;
        numOfAlienLasers--;
        shieldHealth[j]--;
      }
    }
  }
}

void drawUFO() {
  image(UFO,UFOXPos,UFOYPos);
}

void moveUFO() {
  UFOXPos += UFOSpeed;
}

void checkUFOCollision() {
  // Waits for entire UFO to leave the screen
  if(UFOXPos-UFOWidth/2 > width) {
    UFOVisible = false;
    UFOTimer = millis();
    UFOXPos = 0-UFOWidth/2;
  }
  
  // Laser collision with UFO
  int[] UFOScore = {50,100,150,200,300};
  
  if(laserXPos > UFOXPos-UFOWidth/2 && laserXPos < UFOXPos+UFOWidth/2 && laserYPos > UFOYPos-UFOHeight/2 && laserYPos < UFOYPos+UFOHeight/2) {
    UFOVisible = false;
    UFOTimer = millis();
    UFOXPos = 0-UFOWidth/2;
    playerScore += UFOScore[int(random(0,5))];
    laserOnScreen = false;
  }
}

void drawShields() {
  for(int i = 0; i < 4; i++) {
    if(shieldHealth[i] > 0) {
      image(shield,shieldXPos[i],shieldYPos);
    }
  }
}

void drawScore() {
  fill(#FFFFFF);
  text("Score: " + playerScore,50,50);
}

void drawLives() {
  fill(#FFFFFF);
  text("Lives: " + playerLives,50,750);
}

void drawLevel() {
  fill(#FFFFFF);
  text("Level: " + level,700,50);
}

//void shootLaser() { 
//  shootLaser = false;
//}

void keyPressed() {
  switch(keyCode) {
    case 37:
      tankLeft = true;
      break;
    case 39:
      tankRight = true;
      break;
    case 32:
      shootLaser = true;
      break;
  }

  // For testing:
  if(keyCode == 9) {
    gameState = 3;
    gameCondition = 1;
  }
}

void keyReleased() {
  switch(keyCode) {
    case 37:
      tankLeft = false;
      break;
    case 39:
      tankRight = false;
      break;
    case 32:
      shootLaser = false;
      break;
  }
}

void mousePressed() {
  if(gameState == 0 && mouseX > 350 && mouseX < 450 && mouseY > 385 && mouseY < 415) { // "Play" to start
    initialize();
    gameState = 2;
  }
  if(gameState == 0 && mouseX > 350 && mouseX < 450 && mouseY > 435 && mouseY < 465) { // "Instructions" to go to instructions 
    gameState = 1;
  }
  if(gameState == 1 && mouseX > 340 && mouseX < 460 && mouseY > 585 && mouseY < 615) { // "Return to main menu" from instructions to go back to menu
    gameState = 0;
  }
  if(gameState == 3 && gameCondition == 2 && mouseX > 340 && mouseX < 460 && mouseY > 485 && mouseY < 515) { // "Play again" to restart game
    initialize();
    gameState = 2;
  }
  if(gameState == 3 && gameCondition == 2 && mouseX > 340 && mouseX < 460 && mouseY > 435 && mouseY < 565) { // "Return to main menu" to return to menu after game ends
    gameState = 0;
  }
  if(gameState == 3 && gameCondition == 1 && mouseX > 350 && mouseX < 450 && mouseY > 485 && mouseY < 515) { // "Next Level" if player won
    nextLevel();
    gameState = 2;
  }
}
