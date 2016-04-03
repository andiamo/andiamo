// Andiamo 14 with Syphon+MIDI support
// Compatible with Processing 3.x
// Uses P2D by default

import themidibus.*;
import codeanticode.syphon.*;
import java.io.*;

//import codeanticode.tablet.*;
//Tablet tablet;

// Devices
MidiBus midi;
SyphonServer syphon;

PGraphics canvas;
ArrayList<Stroke>[] layers;
//float[] loopMultiplier; // How many times faster the loop is with respect to the original stroke
//float[] alphaScale; // Alpha scaling for each layer
float maxAlpha; // maximum alpha for current stroke 
float fadeoutMult; // speed multiplier for stroke fadeout
int currLayer;
ArrayList<PImage> textures;
int currTexture;
Stroke currStroke;
Stroke lastStroke;
boolean looping;
boolean fixed;
boolean dissapearing;
boolean grouping;

void settings() {
  if (FULL_SCREEN) fullScreen(P2D, DISPLAY_SCREEN);
  else size(WIN_WIDTH, WIN_HEIGHT, P2D);
  PJOGL.profile=1;
}

void setup() {
  frameRate(60);
  noCursor();  
  smooth(2);
  
  startup();
}

void draw() {
  canvas.beginDraw();
  canvas.background(0);
  int t = millis();
  for (int i = 0; i < layers.length; i++) {
   for (Stroke stroke: layers[i]) {
     stroke.update(t);
     stroke.draw(canvas);
   }
  }
  if (currStroke != null) {
   currStroke.update(t);
   currStroke.draw(canvas);
  }
  cleanup();
  canvas.endDraw();  
  image(canvas, 0, 0, WIN_WIDTH, WIN_HEIGHT);
  stroke(255, 150);
  line(mouseX, 0, mouseX, height);
  line(0, mouseY, width, mouseY);
  fill(255, 150);
  text("LAYER " + (currLayer + 1), 10, 24);
  for (int i = 0; i < textures.size(); i++) {
    image(textures.get(i), 5, 40 + 35 * i, 30, 30);
  }
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0, 150);
  rect(5, 40 + 35 * currTexture, 30, 30);
  strokeWeight(1);
  syphon.sendImage(canvas);
}