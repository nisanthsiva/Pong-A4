// Add small delay when aliens hit wall and change y-level
// Make variable init method
// Fix dimensions of tank
// Collision detection for laser
//   - Fix alternate method for laser collision detection


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

boolean alienHittingLeftWall = false;
boolean alienHittingRightWall = false;
int furthestAlienAliveRightIndex = 10;
int furthestAlienAliveLeftIndex = 0;

boolean laserOnScreen = false;

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
}

void draw() {
  background(#000000);
  image(tank,tankXPos,tankYPos);
  drawAliens();
  moveTank();
  moveAliens();
  
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
    println(furthestAlienAliveLeftIndex);
    println(alienXPos[i][furthestAlienAliveRightIndex]);
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
  // if hitting alien: change alienAlive to false, change laserOnScreen to false
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      //if((laserXPos-laserWidth/2 > alienXPos[i][j]-alienWidth/2 && laserXPos+laserWidth/2 < alienXPos[i][j]+alienWidth/2) && (laserYPos-laserHeight/2 > alienYPos[i][j]-alienHeight/2 && laserYPos+laserHeight/2 < alienYPos[i][j]+alienHeight/2)) {
      if(alienAlive[i][j] && abs(laserXPos-alienXPos[i][j]) < 30 && abs(laserYPos-alienYPos[i][j]) < 15) {
        //println("hit");
        laserOnScreen = false;
        alienAlive[i][j] = false; 
      }
    }
  }
  // if laserY < 0, change laserOnScreen to false
  if(laserYPos-laserHeight/2 < 0) {
    //println("off map");
    laserOnScreen = false;
  }
}

void shootLaser() { 
  shootLaser = false;
}

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
