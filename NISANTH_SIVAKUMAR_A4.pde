// Add small delay when aliens hit wall and change y-level
// Fix dimensions of tank

// Bug: laser speed increeases with more lasers on the screen.

// Make alien laser collision better

PImage alienA, alienB, alien1A, alien1B, alien2A, alien2B;
PImage tank;
PImage logo;

boolean tankLeft = false, tankRight = false;
boolean shootLaser = false;

int tankXPos = 400, tankYPos = 700;
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

void setup() {
  size(800,800);
  alienA = loadImage("alienA.png");
  alienB = loadImage("alienB.png");
  alien1A = loadImage("alien1A.png");
  alien1B = loadImage("alien1B.png");
  alien2A = loadImage("alien2A.png");
  alien2B = loadImage("alien2B.png");
  
  tank = loadImage("tank.png");
  
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
  text("instructions",400,400);
  
  // Return to menu:
  fill(#FFFFFF);
  rect(400,600,120,30);
  fill(#000000);
  text("Return To Main Menu",400,600);
}

void game() {
  background(#000000);
  image(tank,tankXPos,tankYPos);
  drawAliens();
  moveTank();
  moveAliens();
  checkNumberOfAliensAlive();
  
  drawScore();
  drawLives();
  
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
    if(millis() - alienLaserTimer > int(random(2,6))*1000) {
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

  //println(numOfAlienLasers);
  
  if(numberOfAliensAlive <= 0) {
    gameState = 3;
    //win condition
  }
  
  if(alienHittingMaxYLevel() || playerLives <= 0) {
    gameState = 3;
    //lose condition
  }
}

void endgame() {
  background(#000000);
  fill(#FFFFFF);
  text("Game Over",400,400);

  // if(won) {}
  // else if(lose) {}

  fill(#FFFFFF);
  rect(400,500,100,30);
  rect(400,550,120,30);
  fill(#000000);
  text("Play Again",400,500);
  text("Return To Main Menu",400,550);
}

void initialize() {
  // Variable reset:
  alienSpeed = 35;
  playerScore = 0;
  playerLives = 3;
  
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
      alienYPos[i][j] = i*35 + 50; //i*35 instead of j*35
    }
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
  if(millis()-currentTime > 1000) {
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
      if(alienAlive[i][j] && alienYPos[i][j] > 500) {
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
  if(gameState == 3 && mouseX > 340 && mouseX < 460 && mouseY > 485 && mouseY < 515) { // "Play again" to restart game
    initialize();
    gameState = 2;
  }
  if(gameState == 3 && mouseX > 340 && mouseX < 460 && mouseY > 435 && mouseY < 565) { // "Return to main menu" to return to menu after game ends
    gameState = 0;
  }
}
