// Press 'b' for blackout
// Press 'n' for normal operation (remove blackout)
// Press 'w' for whiteout
// Press return for next cue


import processing.serial.*;
import processing.video.*;
import processing.sound.*;

int windowDimensions[] = {1280, 800}; // was 1280,720
int windowLocation[] = {0, 0}; // was -200, 100, but (-30?) 0, 30 puts 960,540 it middle of 800,600

// adjust 2nd and 4th numbers here for bottom of top mask and top of bottom mask accordingly
int middleLineCoordinates[] = {680, 170, 680, 560}; // was {680, 170, 680, 550} topx, topy, bottomx, bottomy - coordinates of line from top to bottom of middle division

// variables for fade in, fade out, and whether to 
float kayeFadeInTime = 15;
float kayeFadeOutTime = 15;
boolean drawKayeMasks = false; // change this 'false' to 'true' to draw masks on top and bottom of screen, and 

boolean cursorHidden = true;

// all sound files
SoundFile kayeMusic;
String kayeMusicFilename = "kaye/Kaye solo music - 5_1_19.wav";
float kayeMusicVolume = 1;
float kayeMusicVolumeDx = 0.05;
boolean kayeMusicNeedToFadeDown = false;

// serial stuff
Serial myPort;  // Create object from Serial class
boolean failedSerial = false;
String inputFromSerial;      // Data received from the serial port
float serialVal1 = 0;
float serialVal2 = 0;
float serialVal3 = 0;
int serialVal4 = 0;
int serialVal5 = 0;
int serialVal6 = 0;
int serialVal7 = 0;
int serialVal8 = 0;
float sv1 = 0;
float sv2 = 0;
float sv3 = 0;
float sv1a = 0;
float sv2a = 0;
float sv3a = 0;
float sv1offset = 0.41950002;
float sv2offset = 0.498;
float sv3offset = 0.74224997;
float sv1d = 0;
float sv2d = 0;
float sv3d = 0;
float finger1 = 0;
float finger2 = 0;
float finger3 = 0;
float finger4 = 0;

// blackout stuff
boolean masterBlackOut = true;
boolean masterWhiteOut = false;
float masterBlackOutVal = 255; // piece starts blacked out
float masterBlackOutInt = 5;
float masterWhiteOutVal = 0;
float masterWhiteOutInt = 5;
float fadeTime = 1;
float miniBlackOutVal = 0;


// Kaye variables
ParticleSystem2float ps2;
PImage sprite;  
PImage sprite2;  
float accelFactor = 100;
int alphaIndex = 50;
boolean alphaMode = false;
int mouseDX = 0;
int mouseDY = 0;
PVector mouseD = new PVector(0, 0);
float sv3d2 = 0;


int mode = 0;
int cueNumber = 0;



void settings() { // set fullscreen, later set size
    println("settings");
    fullScreen(P2D);
}

void setup() {
  
  // set up window
  rectMode(CORNER);
  noStroke();
 // surface.setSize(windowDimensions[0], windowDimensions[1]);
 // surface.setLocation(windowLocation[0], windowLocation[1]); // set window location
    
  // load serial stuff
  int serialPortNumber = 0;
  println(Serial.list());
  
  // find receiver, error and quit if not found
  while (Serial.list()[serialPortNumber].charAt(8) != 'u') {
    if (Serial.list().length > serialPortNumber + 1) {
      serialPortNumber += 1;
    } else {
      println("connect receiver and restart");
      exit();
      failedSerial = true;
      break;
    }
  }
  
  // load chosen serial port
  String portName = Serial.list()[serialPortNumber]; // load serial
  myPort = new Serial(this, portName, 115200);
   
  // kaye setup
  sprite = loadImage("kaye/sprite.png");
  sprite2 = loadImage("kaye/sprite3b.png");
  ps2 = new ParticleSystem2float(5000);
  mouseD = new PVector(0, 0);
  frameRate(30);
  // Writing to the depth buffer is disabled to avoid rendering
  // artifacts due to the fact that the particles are semi-transparent
  // but not z-sorted.
  hint(DISABLE_DEPTH_MASK);
  
  // load sound files
  kayeMusic = new SoundFile(this, kayeMusicFilename);
  
  println("sounds loaded");
  
  
  println("setup end");
  
}

// get from carrie copy
void drawMasksKarley() {
  fill(0);
  rect(0,0,windowDimensions[0],middleLineCoordinates[1]); // mask above screen
  rect(0,middleLineCoordinates[3],windowDimensions[0],windowDimensions[1]-middleLineCoordinates[3]); // mask below screen
  rect(middleLineCoordinates[0],0,windowDimensions[0]-middleLineCoordinates[0],windowDimensions[1]); // mask right half    
}

void drawMasksHannah() {
  fill(0);
  rect(0,0,windowDimensions[0],middleLineCoordinates[1]); // mask above screen
  rect(0,middleLineCoordinates[3],windowDimensions[0],windowDimensions[1]-middleLineCoordinates[3]); // mask below screen
  rect(0,0,middleLineCoordinates[0],windowDimensions[1]); // mask left half
}

void drawMasksKaye() {
  fill(0);
  rect(0,0,windowDimensions[0],middleLineCoordinates[1]); // mask above screen
  rect(0,middleLineCoordinates[3],windowDimensions[0],windowDimensions[1]-middleLineCoordinates[3]); // mask below screen  
}

void drawMasksKayeWhite() {
  fill(255);
  rect(0,0,windowDimensions[0],middleLineCoordinates[1]); // mask above screen
  rect(0,middleLineCoordinates[3],windowDimensions[0],windowDimensions[1]-middleLineCoordinates[3]); // mask below screen  
}



// main loop
void draw() {

  // clear screen
  fill(0);
  rect(0,0,windowDimensions[0],windowDimensions[1]);
  // draw new frame of particles
  getSerialData();
  updateVariablesByDancer();
  accelCalc();
  ps2.update();
  ps2.display();

  // apply music fading if needed
  if (kayeMusicNeedToFadeDown == true) {
    kayeMusicFadeDown();
  }
  
  // master black out
  runMasterBlackOut();
  
  // masks top and bottom of screen, here since always needed
 
  if (drawKayeMasks) {
    drawMasksKaye(); 
  }
  
}



// stop anything playing
void stopAll(){
  kayeMusicNeedToFadeDown = true;
}


// this is the cue list
void nextCue() {
    println("running cue " + cueNumber);
    switch(cueNumber) {
    case 0:
      // start with Kaye loaded
      // but master blackout engaged
      hideCursor(true);
      mode = 1;
      masterBlackOut = true;

      //redundant stuff
      setMiniBlackOut(false);
      kayeMusic.stop();

      cueNumber += 1;
      break;

    case 1: 
      mode = 1; // redundant
      // bring up Kaye visuals by removing blackout
      fadeTime = kayeFadeInTime;
      masterBlackOut = false;

      //redundant stuff
      setMiniBlackOut(false);
      kayeMusic.stop();

      cueNumber += 1;
      break;

    case 2:
      mode = 1; // redundant
      //start Kaye music
      kayeMusicVolume = 1.0;
      kayeMusic.amp(kayeMusicVolume);
      kayeMusic.play();

      //redundant stuff
      masterBlackOut = false;
      setMiniBlackOut(false);
      //kayeMusic.stop();
      
      cueNumber += 1;
      break;

    case 3:
      mode = 1; // redundant
      //fade out Kaye by fading audio and putting on blackout
      fadeTime = kayeFadeOutTime;
      masterBlackOut = true;
      kayeMusicNeedToFadeDown = true;

      //redundant stuff
      //masterBlackOut = false;
      setMiniBlackOut(false);

      cueNumber += 1;
      break;

      // (Make new cue for loading Karley before starting walking 1) ??? 
  }
}


/// Kaye stuff
void kayeMusicFadeDown() {
  if (kayeMusicVolume > 0) {
    kayeMusicVolume -= kayeMusicVolumeDx;
  } else {
    kayeMusicVolume = 0;
    kayeMusicNeedToFadeDown = false;
    kayeMusic.stop();
  }
  kayeMusic.amp(kayeMusicVolume);
}

void mouseCalc2() {
  mouseD = new PVector(mouseX - mouseDX, mouseY - mouseDY);
  mouseDX = mouseX;
  mouseDY = mouseY;
  
}

void accelCalc() {
  mouseD = new PVector(accelFactor*(sv1d - sv1), accelFactor*(sv2d - sv2)); // 50 is factor
  sv1d = sv1;
  sv2d = sv2;
  sv3d2 = sv3d - sv3;
  sv3d = sv3;  
}

void updateVariablesByDancer() {
  if (abs(serialVal1) < 20) {
    sv1a = map(serialVal1, -20, 20, 0, 1.0);
  }
  if (abs(serialVal2) < 20) {
    sv2a = map(serialVal2, -20, 20, 0, 1.0);
  }
  if (abs(serialVal3) < 20) {
    sv3a = map(serialVal3, -20, 20, 0, 1.0);
  }
  sv1 = sv1a - sv1offset;
  sv2 = sv2a - sv2offset;
  sv3 = sv3a - sv3offset;
}





void runMasterBlackOut() {
  // calculate how much to change blackout depending on current frameRate
  masterBlackOutInt = 255/(frameRate*fadeTime);
  
  // logic for masterBlackOut
  if (masterBlackOut) {
    if (masterBlackOutVal < 255) {
      masterBlackOutVal = masterBlackOutVal + masterBlackOutInt; 
    } else {
      masterBlackOutVal = 255;
    }
  } else {
    if (masterBlackOutVal > 0) {
      masterBlackOutVal = masterBlackOutVal - masterBlackOutInt; 
    } else {
      masterBlackOutVal = 0;
    }
  }
  
  // logic for whiteout
  if (masterWhiteOut) {
    if (masterWhiteOutVal < 255) {
      masterWhiteOutVal = masterWhiteOutVal + masterWhiteOutInt; 
    } else {
      masterWhiteOutVal = 255;
    }
  } else {
    if (masterWhiteOutVal > 0) {
      masterWhiteOutVal = masterWhiteOutVal - masterWhiteOutInt; 
    } else {
      masterWhiteOutVal = 0;
    }
  }
  
  // draw the masterBlackOut/whiteout
  applyMasterBlackoutWhiteout(); 
}

void applyMasterBlackoutWhiteout() {
  fill(0, 0, 0, masterBlackOutVal);
  rect(0, 0, windowDimensions[0], windowDimensions[1]);
  fill(255, 255, 255, masterWhiteOutVal);
  rect(0, 0, windowDimensions[0], windowDimensions[1]);
}

void applyMiniBlackOut() {
  fill(0,0,0,miniBlackOutVal);
  rect(0,0, windowDimensions[0], windowDimensions[1]); 
}

// simpler way to apply mini black out
void setMiniBlackOut(boolean input) {
  if (input) {
    miniBlackOutVal = 255;
  } else {
    miniBlackOutVal = 0;
  }
}

void hideCursor(boolean input) {
  cursorHidden = input;
  if (cursorHidden) {
    noCursor();
  }
  else {
    cursor();
  }
}

// little utility function
int fitIn255(float input) {
  input = min(input, 255);
  input = max(input, 0);
  return int(input);
}


// serial stuff
void getSerialData() {
  if ( myPort.available() > 0) {  // If data is available,
    // read it and store it in inputFromSerial
    inputFromSerial = myPort.readString(); 
    
    // if its a real message and not empty, go forward
    if (inputFromSerial.length() > 1) {
      String[] valuesA = split(inputFromSerial, 'a');
      String[] valuesB = split(inputFromSerial, 'b');
      String[] valuesC = split(inputFromSerial, 'c');
      String[] valuesD = split(inputFromSerial, 'd');
      String[] valuesE = split(inputFromSerial, 'e');
      String[] valuesF = split(inputFromSerial, 'f');
      String[] valuesG = split(inputFromSerial, 'g');
      String[] valuesH = split(inputFromSerial, 'h');
      
      // check if it is one of Kaye's transmitters
      if (inputFromSerial.charAt(0) == 'K') {
        if (valuesA.length > 1) {
          serialVal1 = float(valuesA[1]); // accelerometer x
        }
        if (valuesB.length > 1) {    
          serialVal2 = float(valuesB[1]); // accelerometer y
        }
        if (valuesC.length > 1) {    
          serialVal3 = float(valuesC[1]); // accelerometer z
        }
     //   println("Kaye found");
      }
      
    }
  }
}


void keyPressed() {

  switch(key) {

    case 10: // enter key 
      nextCue();
      break;

    case '0':
      mode = 0;
      break;
    case '1':
      mode = 1;
      break;
    case '2':
      mode = 2;
      break;
    case '3':
      mode = 3;
      break;
    case '4':
      mode = 4;
      break;
    case '5':
      mode = 5;
      break;
    case '6':
      mode = 6;
      break;
    case '7':
      mode = 7;
      break;
    case '8':
      mode = 8;
      break;
    case '9':
      mode = 9;
      break;
      

    
    // blackout stuff
    case 'n': // "n" for normal (turns off blackout and whiteout)
      masterBlackOut = false;
      masterWhiteOut = false;
    break;
    case 'b': // "b" for blackout 
      masterBlackOut = true;
      masterWhiteOut = false;
      break;
    case 'w': // "w" for whiteout
      masterWhiteOut = true;
      masterBlackOut = false;
      break;
    
    
    // cue stuff
    case 'Q': // cue 00
      cueNumber = 0;
      break;
    case 'W': // cue 01
      cueNumber = 1;
      break;
    case 'E': // cue 02
      cueNumber = 2;
      break;
    case 'R': // cue 03
      cueNumber = 3;
      break;
    case 'T': // cue 04
      cueNumber = 4;
      break;
    case 'Y': // cue 05
      cueNumber = 5;
      break;
    case 'U': // cue 06
      cueNumber = 6;
      break;
    case 'I': // cue 07
      cueNumber = 7;
      break;
    case 'O': // cue 08
      cueNumber = 8;
      break;
    case 'P': // cue 09
      cueNumber = 9;
      break;
    case 'A': // cue 10
      cueNumber = 10;
      break;
    case 'S': // cue 11
      cueNumber = 11;
      break;
    case 'D': // cue 12
      cueNumber = 12;
      break;
    case 'F': // cue 13
      cueNumber = 13;
      break;
    case 'G': // cue 14
      cueNumber = 14;
      break;
    case 'H': // cue 15
      cueNumber = 15;
      break;
    case 'J': // cue 16
      cueNumber = 16;
      break;
    case 'K': // cue 17
      cueNumber = 17;
      break;
    case 'L': // cue 18
      cueNumber = 18;
      break;
    case ':': // cue 19
      cueNumber = 19;
      break;
    case 'Z': // cue 20
      cueNumber = 20;
      break;
    case 'X': // cue 21
      cueNumber = 21;
      break;
    case 'C': // cue 22
      cueNumber = 22;
      break;
    case 'V': // cue 23
      cueNumber = 23;
      break;
    case 'B': // cue 24
      cueNumber = 24;
      break;
    case 'N': // cue 25
      cueNumber = 25;
      break;
    case 'M': // cue 26
      cueNumber = 26;
      break;
    case '<': // cue 27
      cueNumber = 27;
      break;
    case '>': // cue 28
      cueNumber = 28;
      break;
    case '?': // cue 29
      cueNumber = 29;
      break;
      
  //  case 'm': // m for hide mouse
    //  hideCursor(true);
  //    break;
  }
}
