// Fix checkAlienHittingWall()
// Wall detection, make aliens reverse direction, change y level

PImage alien;
PImage alien1;
PImage tank;

boolean tankLeft = false, tankRight = false;

int tankXPos = 400, tankYPos = 700;
int tankWidth = 45;
int alienWidth = 30;

int numOfAliensPerRow = 11;

int tankSpeed = 5, alienSpeed = 35;

int[][] alienXPos = {new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow]};
int[][] alienYPos = {new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow], new int[numOfAliensPerRow]};

int currentTime;

int animationState;

boolean alienHittingWall = false;

void setup() {
  size(800,800);
  alien = loadImage("alien.PNG");
  alien1 = loadImage("alien1.PNG");
  tank = loadImage("tank.png");
  textAlign(CENTER,CENTER);
  imageMode(CENTER);
  
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
  //checkAliensHittingWall();
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
      if(animationState == 0) {
        image(alien,alienXPos[i][j],alienYPos[i][j]);
      } 
      else if(animationState == 1) {
        image(alien1,alienXPos[i][j],alienYPos[i][j]);
      }
    }
  }
}

void moveAliens() {
  if(millis()-currentTime > 1000) {
    // checkAliensHittingWall();
    for(int i = 0; i < 5; i++) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienXPos[i][j] += alienSpeed;
        currentTime = millis();
        if(alienHittingWall) {
          alienYPos[i][j] += 35;
          alienSpeed = -alienSpeed;
        }
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

void checkAliensHittingWall() { // <--- fix
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      if(alienXPos[i][j]-alienWidth/2 < 0 || alienXPos[i][j]+alienWidth/2 > 800) {
        alienHittingWall = true;
      }
      else {
        alienHittingWall = false;
      }
    }
  }
}

void keyPressed() {
  if(keyCode == 37) {
    tankLeft = true;
  }
  if(keyCode == 39) {
    tankRight = true;
  }
  // spacebar to shoot (32)
}

void keyReleased() {
  if(keyCode == 37) {
    tankLeft = false;
  }
  if(keyCode == 39) {
    tankRight = false;
  }
}
