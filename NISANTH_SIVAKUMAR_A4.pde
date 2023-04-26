PImage alien;
PImage tank;

boolean tankLeft = false, tankRight = false;

int tankXPos, tankYPos;

int numOfAliens = 11;

int[] alienXPos = new int[numOfAliens];
int[] alienYPos = new int[numOfAliens];

void setup() {
  size(800,800);
  alien = loadImage("invader.png");
  tank = loadImage("tank.png");
  textAlign(CENTER,CENTER);
  imageMode(CENTER);

  //for(int i = 0; i < numOfAliens; i++) {
  //  for(int j = 0; j < numOfAliens; j++) {
  //    alienXPos[i] = i*50 + 175;
  //    alienYPos[i] = j*10 + 10;
  //  }
  //}
  for(int i = 0; i < numOfAliens; i++) {
    alienXPos[i] = i*50 + 150;
    alienYPos[i] = 50;
  }
}

void draw() {
  background(#000000);
  image(tank,400,700);

  for(int i = 0; i < numOfAliens; i++) {
    image(alien,alienXPos[i],alienYPos[i]);
  }
}

void keyPressed() {
  if(keyCode == 37) {
    tankLeft = true;
  }
  if(keyCode == 39) {
    tankRight = true;
  }
}

void keyReleased() {
  if(keyCode == 37) {
    tankLeft = false;
  }
  if(keyCode == 39) {
    tankRight = false;
  }
}
