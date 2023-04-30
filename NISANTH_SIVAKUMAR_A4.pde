// Add small delay when aliens hit wall and change y-level
// Make variable init method for game restart, reset score
// Fix dimensions of tank

// Use if else for game state conditionals

PImage alien;
PImage alien1;
PImage tank;

boolean tankLeft = false, tankRight = false;
boolean shootLaser = false;

int tankXPos = 400, tankYPos = 700;
int tankHeight = 28, tankWidth = 45;
int alienWidth = 30, alienHeight = 22;

int laserWidth = 4, laserHeight = 26;

int numOfAliensPerRow = 11;

int tankSpeed = 5, alienSpeed = 35, laserSpeed = 5;

int[][] alienXPos = {new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow]};
int[][] alienYPos = {new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow]};
boolean[][] alienAlive = {new boolean[numOfAliensPerRow], new boolean[numOfAliensPerRow], new boolean[numOfAliensPerRow], new boolean[numOfAliensPerRow], new boolean[numOfAliensPerRow]};

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

int playerScore = 0;

int numberOfAliensAlive;

void setup() {
  size(800,800);
  alien = loadImage("alien.PNG");
  alien1 = loadImage("alien1.PNG");
  tank = loadImage("tank.png");
  textAlign(CENTER,CENTER);
  imageMode(CENTER);
  rectMode(CENTER);
    
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
  // Add SpaceInvaders logo PImage
  // image()
  
  background(#000000);
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
  
  if(numberOfAliensAlive <= 0) {
    gameState = 3;
    //win condition
  }
  
  //if(alienYPos reaches end of y-cutoff leve) {
  //  gameState = 3;
  //  lose condition
  //}
  
  //println(playerScore);
  println(numberOfAliensAlive);
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
          image(alien,alienXPos[i][j],alienYPos[i][j]);
        } 
        else if(animationState == 1) {
          image(alien1,alienXPos[i][j],alienYPos[i][j]);
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
    //println(furthestAlienAliveLeftIndex);
    //println(alienXPos[i][furthestAlienAliveRightIndex]);
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

void checkLaserCollision() {
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      //if(alienAlive[i][j] && (laserXPos-laserWidth/2 > alienXPos[i][j]-alienWidth/2 && laserXPos+laserWidth/2 < alienXPos[i][j]+alienWidth/2) && (laserYPos > alienYPos[i][j]-alienHeight/2 && laserYPos < alienYPos[i][j]+alienHeight/2)) {
      if(alienAlive[i][j] && abs(laserXPos-alienXPos[i][j]) < 25 && abs(laserYPos-alienYPos[i][j]) < 15) {
        //println("hit");
        laserOnScreen = false;
        alienAlive[i][j] = false;
        numberOfAliensAlive--;
        //switch(i) {
        //  case 0:
        //    playerScore += 30;
        //    break;
        //  case 1:
        //    playerScore += 20;
        //    break;
        //  case 2:
        //    playerScore += 20;
        //    break;
        //  case 3:
        //    playerScore += 10;
        //    break;
        //  case 4:
        //    playerScore += 10;
        //    break;
        //}
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

//void shootLaser() { 
//  shootLaser = false;
//}

void keyPressed() {
  //if(keyCode == 37) {
  //  tankLeft = true;
  //}
  //if(keyCode == 39) {
  //  tankRight = true;
  //}
  //if(keyCode == 32) {
  //  shootLaser = true;
  //}
  
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
  //if(keyCode == 10 && gameState == 0) { // Press enter to start game
  //  gameState = 2;
  //}
  //println(keyCode);

  // For testing:
  if(keyCode == 9) {
    gameState = 3;
  }
}

void keyReleased() {
  //if(keyCode == 37) {
  //  tankLeft = false;
  //}
  //if(keyCode == 39) {
  //  tankRight = false;
  //}
  //if(keyCode == 32) {
  //  shootLaser = false;
  //}
  
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
    gameState = 2;
  }
  if(gameState == 0 && mouseX > 350 && mouseX < 450 && mouseY > 435 && mouseY < 465) { // "Instructions" to go to instructions 
    gameState = 1;
  }
  if(gameState == 1 && mouseX > 340 && mouseX < 460 && mouseY > 585 && mouseY < 615) { // "Return to main menu" from instructions to go back to menu
    gameState = 0;
  }
  if(gameState == 3 && mouseX > 340 && mouseX < 460 && mouseY > 485 && mouseY < 515) { // "Play again" to restart game
    gameState = 2;
  }
  if(gameState == 3 && mouseX > 340 && mouseX < 460 && mouseY > 435 && mouseY < 565) { // "Return to main menu" to return to menu after game ends
    gameState = 0;
  }
}
