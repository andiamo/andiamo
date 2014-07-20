// Andiamo 13

import java.io.*;

//import codeanticode.tablet.*;
//Tablet tablet;

ArrayList<Stroke>[] layers;
int currLayer;
ArrayList<PImage> textures;
int currTexture;
Stroke currStroke;
Stroke lastStroke;
boolean looping;
boolean grouping;

void setup() {
  String RENDERER = JAVA2D;
  if (USE_TEXTURES) RENDERER = P2D;
//  size(displayWidth, displayHeight, RENDERER);
  size(800, 600, RENDERER);
  frameRate(180);
  smooth(8);
  startup();
}

void draw() {
  background(0);
  int t = millis();
  for (int i = 0; i < layers.length; i++) {
    for (Stroke stroke: layers[i]) {
      stroke.update(t);
      stroke.draw(g);
    }
  }
  if (currStroke != null) {
    currStroke.update(t);
    currStroke.draw(g);
  }
  cleanup();
  
//  if (frameCount % 600 == 0) {
//    println("fps: " + frameRate);  
//  }
}

void startup() {
  //tablet = new Tablet(this); 
  initRibbons();
  textures = new ArrayList<PImage>();  
  for (int i = 0; i < TEXTURE_FILES.length; i++) {
    textures.add(loadImage(TEXTURE_FILES[i]));    
  }
  
  looping = LOOPING_AT_INIT;
  println("Looping: " +  looping);
  
  grouping = false;
  println("Gouping: " +  grouping);
  
  currTexture = 0;
  textureMode(NORMAL);
 
  layers = new ArrayList[4];
  for (int i = 0; i < 4; i++) {
    layers[i] = new ArrayList<Stroke>();
  }
  loadDrawing();
  currLayer = 0;
  lastStroke = null;
  currStroke = new Stroke(0, currTexture, lastStroke);
  println("Selected stroke layer: " + 1);  
}

void cleanup() {
  for (int i = 0; i < layers.length; i++) {
    for (int j = layers[i].size() - 1; j >= 0; j--) {
      Stroke stroke = (Stroke)layers[i].get(j);
      if (!stroke.isVisible() && !stroke.isLooping()) {
        layers[i].remove(j);
      }
    }
  }
}

void loadDrawing() {
  File file = new File(dataPath(DRAW_FILENAME));
  if (file.exists()) {  
    XML xml = loadXML("drawing.xml");
    if (xml != null) {
      for (int i = 0; i < layers.length; i++) {
        XML layer = xml.getChild("layer" + i);
        XML[] children = layer.getChildren("stroke");
        for (int n = 0; n < children.length; n++) {
          Stroke stroke = new Stroke(children[n]);
          layers[i].add(stroke);
        }         
      }
      println("Loaded drawing from " + DRAW_FILENAME);
    }  
  }
}

void saveDrawing() {  
  String str = "<?xml version=\"1.0\"?>\n";
  str += "<drawing>\n";  
  for (int i = 0; i < layers.length; i++) {
    str += "<layer" + i + ">\n";
    for (Stroke stroke: layers[i]) {
      str += stroke.toXML();
    }
    str += "</layer" + i + ">\n";    
  }
  str += "</drawing>\n";
  String[] lines = split(str, "\n");
  saveStrings("data/" + DRAW_FILENAME, lines);
  println("Saved current drawing to " + DRAW_FILENAME);
}
