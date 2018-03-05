void startup() {
  //tablet = new Tablet(this); 
  syphon = new SyphonServer(this, "Andiamo Syphon Server");
  
  if (-1 < INPUT_MIDI_DEVICE) {
    MidiBus.list();
    midi = new MidiBus(this, INPUT_MIDI_DEVICE, -1);
  }
    
  canvas = createGraphics(CANVAS_WIDTH, CANVAS_HEIGHT, P2D);
  
  initRibbons();
  textures = new ArrayList<PImage>();  
  for (int i = 0; i < TEXTURE_FILES.length; i++) {
    textures.add(loadImage(TEXTURE_FILES[i]));    
  }
  
  looping = LOOPING_AT_INIT;
  println("Looping: " +  looping);
  
  fixed = FIXED_STROKE_AT_INIT;
  println("Fixed: " +  fixed);
  
  dissapearing = DISSAPEARING_AT_INIT;
  println("Dissapearing: " +  looping);
  
  grouping = false;
  println("Gouping: " +  grouping);
  
  currTexture = 0;
  textureMode(NORMAL);
  canvas.beginDraw();
  canvas.textureMode(NORMAL);
  canvas.endDraw();
 
  layers = new ArrayList[4];
  for (int i = 0; i < 4; i++) {
    layers[i] = new ArrayList<Stroke>();
  }
  loadDrawing();
  currLayer = 0;
  lastStroke = null;
  currStroke = new Stroke(0, dissapearing, fixed, currTexture, lastStroke);
  println("Selected stroke layer: " + 1);
  
  loopMultiplier = new int[4];
  for (int i = 0; i < 4; i++) {
    loopMultiplier[i] = 0;
  }
  
  alphaScale = new int[4];
  for (int i = 0; i < 4; i++) {
    alphaScale[i] = 127;
  }
  
  maxAlpha = 1;
  fadeoutMult = 1;
  
  PFont font = createFont("Helvetica", 24);
  textFont(font);
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