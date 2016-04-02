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
  smooth(8);
  
  canvas = createGraphics(CANVAS_WIDTH, CANVAS_HEIGHT, P2D);  
  
  syphon = new SyphonServer(this, "Andiamo Syphon Server");
  midi = new MidiBus(this, 0, -1);
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
  syphon.sendImage(canvas);
}