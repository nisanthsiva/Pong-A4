/*
    Nisanth Sivakumar
    NISANTH_SIVAKUMAR_A4.pde
    May 12, 2023
    ICS3U1 - Assignment 4
    
    An interactive program based on the game "Space Invaders".
    Contains levels that increase in difficulty.
    Left and Right arrows to control the tank.
    Spacebar to shoot lasers.
*/

// Images for sprites
PImage alienA, alienB, alien1A, alien1B, alien2A, alien2B;
PImage UFO;
PImage tank;
PImage shield;
PImage logo;

// Variables for keyboard input
boolean tankLeft = false, tankRight = false;
boolean shootLaser = false;

// Tank variables
int tankXPos = 400, tankYPos = 725;
int tankHeight = 28, tankWidth = 45;

// Laser variables
int laserWidth = 4, laserHeight = 26, alienLaserWidth = 4, alienLaserHeight = 15;
int laserXPos, laserYPos;
boolean laserOnScreen = false;

// Speed variables
int tankSpeed = 5, alienSpeed = 35, laserSpeed = 8, alienLaserSpeed = 2;

// Alien variables
int numOfRows = 5;
int numOfAliensPerRow = 11;
int alienWidth = 30, alienHeight = 22;
int[][] alienXPos = new int[numOfRows][numOfAliensPerRow];
int[][] alienYPos = new int[numOfRows][numOfAliensPerRow];
boolean[][] alienAlive = new boolean[numOfRows][numOfAliensPerRow];

// Alien laser variables
int numOfAlienLasers = 0;
int[] alienLaserXPos = new int[3];
int[] alienLaserYPos = new int[3];
boolean[] alienLaserAlive = new boolean[3];
boolean shootAlienLaser = false;
int alienLaserTimer = 0;

// Shield variables
int shieldYPos = 650;
int[] shieldXPos = new int[4];
int[] shieldHealth = new int[4];
int shieldWidth = 100, shieldHeight = 75;

// State variables
int animationState;
int gameState; // 0 = main menu, 1 = instructions, 2 = game, 3 = endscreen
int gameCondition = 0; // 0 = neutral, 1 = won, 2 = lost

// Alien collision variables
boolean alienHittingLeftWall = false;
boolean alienHittingRightWall = false;
int furthestAlienAliveRightIndex = 10;
int furthestAlienAliveLeftIndex = 0;

// UFO variables
boolean UFOVisible = false;
int UFOWidth = 60, UFOHeight = 26;
int UFOXPos = 0-UFOWidth/2, UFOYPos = 100, UFOSpeed = 2;
int UFOTimer = 0;

// Game control variables
int playerScore = 0;
int numberOfAliensAlive;
int playerLives;
int level = 1;
boolean nextLevel = false;
int currentTime;

// Variable used for storing highscore
int[] highscore = new int[1];

void setup() {
  size(800,800);
  
  rect(400,400,100,100);
  
  // Loading images for sprites
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
  
  // Calls the method to setup all the necessary variables
  initialize();

  // Sets the game state to the "Main Menu"
  gameState = 0;
}

void draw() {
  // Call appropriate method based on the game state variable
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
  // Draws the main menu with the logo sprite
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
  background(#000000);
  
  // Draws the instructions
  fill(#FFFFFF);
  textSize(28);
  text("How To Play",400,100);
  textSize(20);
  text("Use Left Arrow and Right Arrow control the tank.",400,200);
  text("Use spacebar to shoot the aliens. ",400,250);
  text("The goal of the game is to stop the aliens from reaching the bottom of the screen.",400,300);
  text("Once all aliens have been cleared from the screen, you can move on to the next level",400,350);
  text("Each level will increase in difficulty",400,400);
  textSize(12);
  
  // Return to menu button
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
  drawShields();
  drawShieldHealths();
  
  drawScores();
  drawLives();
  drawLevel();

  // Checks if the variable that is set to true when the space bar is pressed
  // and if the laser is not already on the screen
  if(shootLaser && !laserOnScreen) {
    laserOnScreen = true;
    laserXPos = tankXPos;
    laserYPos = tankYPos-tankHeight;
  } 
  
  // Draws, moves and checks the laser's collision is the associated variable is set to true
  if(laserOnScreen) {
    drawLaser(laserXPos,laserYPos,laserWidth,laserHeight);
    moveLaser();
    checkLaserCollision();
  }
  
  // Increments through each alien laser
  for(int i = 0; i < 3; i++) {
    // Timer to make them spawn at a random time between 2-6s, decreasing with the level
    if(millis() - alienLaserTimer > int(random(2,6))*1000-(level*50)) {
      // Check if there are less than 3 lasers as this is the max that should be on the screen at once
      // and checks if that specific alien laser is not already on the screen
      if(numOfAlienLasers < 3 && !alienLaserAlive[i]) {
        // Sets the x and y positions of the laser to a random alien's position if the alien is alive
        int randomX = int(random(0,numOfRows));
        int randomY = int(random(0,numOfAliensPerRow));
        if(alienAlive[randomX][randomY]) {
          alienLaserXPos[i] = alienXPos[randomX][randomY];
          alienLaserYPos[i] = alienYPos[randomX][randomY];
          
          alienLaserAlive[i] = true;
          numOfAlienLasers++;
          alienLaserTimer = millis();
        }
      }
    }
  }
  
  // Calls the methods to draw, move and check the alien laser's collisions
  drawAlienLasers();
  moveAlienLasers();
  checkAlienLaserCollision();

  // Checks if the UFO is on the screen
  if(UFOVisible) {
    // Calls the methods to draw, move and check the UFO's collisions
    drawUFO();
    moveUFO();
    checkUFOCollision();
  }
  
  // Makes the UFO cross the screen at a random time between 20-30s
  if(millis() - UFOTimer > int(random(20,30))*1000) {
    UFOVisible = true;
  }
  
  // Checks if all the aliens have been eliminated
  if(numberOfAliensAlive <= 0) {
    // Sets the game state to the "endgame"
    gameState = 3;
    // Sets the game condition to "win"
    gameCondition = 1;
  }
  
  // Checks if the aliens have hit the max y-level before the player loses 
  // or player has run out of lives 
  if(alienHittingMaxYLevel() || playerLives <= 0) {
    // Sets the game state to the "endgame"
    gameState = 3;
    // Sets the game condition to "lose"
    gameCondition = 2;
  }
}

void endgame() {
  // Calls the win() method if the game condition is set to "win" state
  if(gameCondition == 1) {
    win();  
  }
  // Calls the lose() method if the game condition is set to the "lose" state
  else if(gameCondition == 2) {
    lose();
  }
}

void win() {
  background(#000000);
  // Button to move onto next level
  fill(#FFFFFF);
  textSize(28);
  text("Level Cleared",400,300);
  rect(400,500,100,30);
  fill(#000000);
  textSize(12);
  text("Next Level",400,500);
}

void lose() {
  // Updates the highscore file if the player's current score is higher than the
  // previously set highscore
  if(playerScore > highscore[0]) {
    highscore[0] = playerScore;
    saveStrings("highscore.txt",str(highscore));
  }
  
  background(#000000);
  
  // Draws the "Play Again" and "Return To Main Menu" buttons 
  fill(#FFFFFF);
  textSize(28);
  text("Game Over",400,400);
  rect(400,500,100,30);
  rect(400,550,120,30);
  fill(#000000);
  textSize(12);
  text("Play Again",400,500);
  text("Return To Main Menu",400,550);
}

// Method to reset/set the appropriate variables at the start of the game or when
// moving to the next level
void initialize() {
  // Increases the level if the player clears the level
  // nextLevel variable is set to true when the player clicks the next level button
  if(nextLevel) {
    level++; 
  }
  // Sets the level to 1 and score to 0 if the player is playing for the first time
  // or playing again after losing
  else if(!nextLevel) {
    level = 1;
    playerScore = 0; 
  }
  
  // Variable reset:
  tankXPos = 400;
  alienSpeed = 35;
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
  
  // Switches the nextLevel variable to false after all the necessary variables
  // have been reset
  nextLevel = false;
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
  // Moves the tank if it not at the edges of the screen
  // tankLeft is set to true when the left arrow is pressed
  // tankRight is set to true when the right arrow is pressed
  if(tankLeft && tankXPos-tankWidth/2 > 0) {
    tankXPos -= tankSpeed;
  }
  if(tankRight && tankXPos+tankWidth/2 < 800) {
    tankXPos += tankSpeed;
  }
}

void drawAliens() {
  // Increments through the 2d arrays for x and y position of the aliens
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      // Draws the alien if it is alive
      if(alienAlive[i][j]) {
        // Makes the aliens swap between the two animations
        if(animationState == 0) {
          // Draws a different alien depending on which row it is drawing
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
        // Makes the aliens swap between the two animations
        else if(animationState == 1) {
          // Draws a different alien depending on which row it is drawing
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
  // Moves the aliens periodically
  // The time between movements decreases as the level increases
  if(millis()-currentTime > 1000-(level*50)) {
    // Checks the aliens wall collision
    checkAlienHittingWall();
    // Loops through the 2d array for aliens x positions
    for(int i = 0; i < 5; i++) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienXPos[i][j] += alienSpeed;
        // Resets the timer used to make the aliens move periodically
        currentTime = millis();
      }
    }
    // Switches the animations state variable in order to animate the aliens
    if(animationState == 0) {
      animationState = 1;
    }
    else {
      animationState = 0;
    }
  }
}

void checkNumberOfAliensAlive() {
  // Starts with a local variable at 0
  int num = 0;
  // Loops through the 2d boolean array, alienAlive[][]
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      // Checks if the alien is alive
      if(alienAlive[i][j]) {
        // Increases the local variable by 1
        num++;
      }
    }
  }
  // Sets the global numberOfAliensAlive variable to the value of the local variable
  numberOfAliensAlive = num;
}

boolean alienHittingMaxYLevel() {
  // Loops through the 2d arrays
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      // Checks if the furthest aliens that are alive are below the max y-level
      if(alienAlive[i][j] && alienYPos[i][j] > 600) {
        return(true);
      } 
    }
  }
  return(false);
}

void checkAlienHittingWall() {
  // Starts each variable at the opposite side
  int currentFurthestRight = 0;
  int currentFurthestLeft = numOfAliensPerRow-1;
  // Loops through the 2d arrays
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      // Checks if the alien currently selected is further than the 
      // previously known furthest alien on the right
      if(alienAlive[i][j] && j > currentFurthestRight) {
        // Sets it to the new furthest
        currentFurthestRight = j;
      }
      // Checks if the alien currently selected is further than the 
      // previously known furthest alien on the left
      if(alienAlive[i][j] && j < currentFurthestLeft) {
        // Sets it to the new furthest
        currentFurthestLeft = j;
      }
      // Sets the global variables to the local variables
      furthestAlienAliveRightIndex = currentFurthestRight;
      furthestAlienAliveLeftIndex = currentFurthestLeft;
    }
  }
  
  // Loops through each row of aliens
  for(int i = 0; i < 5; i++) {
    // Checks if the aliens are hitting the left edge
    if(alienXPos[i][furthestAlienAliveLeftIndex]-alienWidth/2 < 0) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienYPos[i][j] += 35;
        alienSpeed = abs(alienSpeed);
      }
    }
    
    // Checks if the aliens are hitting the right edge
    if(alienXPos[i][furthestAlienAliveRightIndex]+alienWidth/2 > width) {
      for(int j = 0; j < numOfAliensPerRow; j++) {
        alienYPos[i][j] += 35;
        alienSpeed = -abs(alienSpeed);
      }
    }
  }
}

void drawLaser(int x, int y, int w, int h) {
  // Draws the laser
  fill(#FFFFFF);
  rect(x,y,w,h);
}

void moveLaser() {
  // Moves the laser based on the speed variable
  laserYPos -= laserSpeed;
}

void drawAlienLasers() {
  // Draws the alien lasers
  for(int i = 0; i < 3; i++) {
    if(alienLaserAlive[i]) {
      fill(#1CFF62);
      rect(alienLaserXPos[i],alienLaserYPos[i],alienLaserWidth,alienLaserHeight);
    }
  }
}

void moveAlienLasers() {
  // Moves the alien lasers based on the speed variable
  for(int i = 0; i < 3; i++) {
    if(alienLaserAlive[i]) {
      alienLaserYPos[i] += alienLaserSpeed;
    }
  }
}

void checkLaserCollision() {
  // Loops through the rows and columns of aliens
  for(int i = 0; i < 5; i++) {
    for(int j = 0; j < numOfAliensPerRow; j++) {
      // Checks if the laser is touching the alien at the selected index using x and y positions
      if(alienAlive[i][j] && abs(laserXPos-alienXPos[i][j]) < 25 && abs(laserYPos-alienYPos[i][j]) < 15) {
        // Updates the laser boolean variable, allowing the player to fire another laser
        laserOnScreen = false;
        // Updates the boolean array checking if the alien is alive at the selected index to false
        alienAlive[i][j] = false;
        // Decreases the variable that shows the number of aliens that are still alive
        numberOfAliensAlive--;

        // Awards the player different points based on which row the eliminated alien was from
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
  
  // Increments through each shield
  for(int i = 0; i < 4; i++) {
    // Checks if the player's laser hit a shield
    if(shieldHealth[i] > 0 && abs(laserXPos-shieldXPos[i]) < shieldWidth/2 && abs(laserYPos-shieldYPos) < shieldHeight/2) {
      // Updates the laser boolean variable, allowing the player to fire another laser
      laserOnScreen = false;
    }
  }
  
  // Checks if the laser hits the top of the screen
  if(laserYPos-laserHeight/2 < 0) {
    // Updates the laser boolean variable, allowing the player to fire another laser
    laserOnScreen = false;
  }
}

void checkAlienLaserCollision() {
  // Increments through the alien lasers
  for(int i = 0; i < 3; i++) {
    // Checks if the alien laser is hitting the tank
    if(alienLaserAlive[i] && alienLaserXPos[i] > tankXPos-tankWidth/2 && alienLaserXPos[i] < tankXPos+tankWidth/2 && alienLaserYPos[i]-alienLaserHeight/2 > tankYPos-tankHeight/2 && alienLaserYPos[i]+alienLaserHeight/2 < tankYPos+tankHeight/2) {
      // Updates the alien laser boolean variable, allowing another alien laser to be fired
      alienLaserAlive[i] = false;
      // Updates variable that stores the number of alien lasers, allowing another alien laser to be fired
      numOfAlienLasers--;
      // Decreases the player's lives by one
      playerLives--;  
    }
    
    // Checks if the alien laser hits the bottom of the screen
    if(alienLaserAlive[i] && alienLaserYPos[i] > height) {
      // Updates the alien laser boolean variable, allowing another alien laser to be fired
      alienLaserAlive[i] = false;
      // Updates variable that stores the number of alien lasers, allowing another alien laser to be fired
      numOfAlienLasers--;
    }
    
    // Increments through the shields
    for(int j = 0; j < 4; j++) {
      // Checks if the alien laser hits the shield using x and y positions
      if(alienLaserAlive[i] && shieldHealth[j] > 0 && abs(alienLaserXPos[i]-shieldXPos[j]) < shieldWidth/2 && abs(alienLaserYPos[i]-shieldYPos) < shieldHeight/2) {
        // Updates the alien laser boolean variable, allowing another alien laser to be fired
        alienLaserAlive[i] = false;
        // Updates variable that stores the number of alien lasers, allowing another alien laser to be fired
        numOfAlienLasers--;
        // Decreases the shield's health by one
        shieldHealth[j]--;
      }
    }
  }
}

void drawUFO() {
  // Draws the UFO
  image(UFO,UFOXPos,UFOYPos);
}

void moveUFO() {
  // Moves the UFO with it's speed variable
  UFOXPos += UFOSpeed;
}

void checkUFOCollision() {
  // Waits for entire UFO to leave the screen
  if(UFOXPos-UFOWidth/2 > width) {
    // Updates the UFO boolean variable that determines if the UFO is on the screen or not
    UFOVisible = false;
    // Updates the timer used to make the UFO spawn at a random time
    UFOTimer = millis();
    // Resets the UFO's x position
    UFOXPos = 0-UFOWidth/2;
  }
  
  // Array of the possible points awarded when a UFO is shot
  int[] UFOScore = {50,100,150,200,300};
  
  // Checks if the player's laser hits the UFO using x and y positions
  if(laserXPos > UFOXPos-UFOWidth/2 && laserXPos < UFOXPos+UFOWidth/2 && laserYPos > UFOYPos-UFOHeight/2 && laserYPos < UFOYPos+UFOHeight/2) {
    // Updates the UFO boolean variable that determines if the UFO is on the screen or not
    UFOVisible = false;
    // Updates the timer used to make the UFO spawn at a random time
    UFOTimer = millis();
    // Resets the UFO's x position
    UFOXPos = 0-UFOWidth/2;
    // Awards the player a random score from the array of possible UFO scores
    playerScore += UFOScore[int(random(0,5))];
    // Updates the laser boolean variable, allowing another laser to be fired
    laserOnScreen = false;
  }
}

void drawShields() {
  // Increments through the shieldXPos array
  for(int i = 0; i < 4; i++) {
    // Checks if the shield's health is greater than 0
    if(shieldHealth[i] > 0) {
      // Draws the shield at the selected index of the shieldXPos array
      image(shield,shieldXPos[i],shieldYPos);
    }
  }
}

void drawShieldHealths() {
  // Dimensions of the shield's healthbar
  int healthBarWidth = 40;
  int healthBarHeight = 10;
  
  // Increments through each shield
  for(int i = 0; i < 4; i++) {
    fill(#000000);
    // Draws the outline of the health bar
    rect(shieldXPos[i],shieldYPos,healthBarWidth,healthBarHeight);
    // Draws the individual health indicators based on how much health the shield has
    for(int j = 0; j < shieldHealth[i]; j++) {
      fill(#FA0000);
      rect(shieldXPos[i]-healthBarWidth/2 + 10*j + 5,shieldYPos,healthBarWidth/4,healthBarHeight);
    }
  }
}

void drawScores() {
  // Loads the highscore from the text file
  highscore = int(loadStrings("highscore.txt"));

  // Displays the current score and high score
  fill(#FFFFFF);
  textSize(30);
  text("Score: " + playerScore,75,25);
  text("Highscore: " + highscore[0],400,25);
  textSize(12);
}

void drawLives() {
  // Displays the number of lives the player has
  fill(#FFFFFF);
  textSize(30);
  text("Lives: " + playerLives,75,750);
  textSize(12);
}

void drawLevel() {
  // Displays which level the player is currently on
  fill(#FFFFFF);
  textSize(30);
  text("Level: " + level,725,25);
  textSize(12);
}

void keyPressed() {
  // Check for keyboard input and updates the associated boolean variable
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
  // Check for keyboard input and updates the associated boolean variable
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
  if(gameState == 3 && gameCondition == 2 && mouseX > 340 && mouseX < 460 && mouseY > 485 && mouseY < 515) { // "Play again" to restart game after game ends
    initialize();
    gameState = 2;
  }
  if(gameState == 3 && gameCondition == 2 && mouseX > 340 && mouseX < 460 && mouseY > 535 && mouseY < 565) { // "Return to main menu" to return to menu after game ends
    gameState = 0;
  }
  if(gameState == 3 && gameCondition == 1 && mouseX > 350 && mouseX < 450 && mouseY > 485 && mouseY < 515) { // "Next Level" if player won
    nextLevel = true;
    initialize();
    gameState = 2;
  }
}
