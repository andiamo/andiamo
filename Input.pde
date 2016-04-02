int startStrokeTime;

void mousePressed() {
  int t0 = startStrokeTime = millis();
  
  boolean connected = false;
  if (lastStroke != null && grouping && t0 - lastStroke.t1 < 1000 * MAX_GROUP_TIME) {
    t0 = lastStroke.t0;
    connected = true;    
  }
  
  currStroke = new Stroke(t0, dissapearing, fixed, currTexture, lastStroke);
  
  if (connected) {
    lastStroke.next = currStroke;
  }
  
  addPointToRibbon(mouseX, mouseY);
}

void mouseDragged() {
  if (currStroke != null) {
    addPointToRibbon(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (currStroke != null) {
    addPointToRibbon(mouseX, mouseY);
    currStroke.setLooping(looping);
    currStroke.setEndTime(millis());
    if (currStroke.visible) {
      layers[currLayer].add(currStroke);
    }
    lastStroke = currStroke;    
    currStroke = null;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      loopMultiplier[currLayer] += 1;
      if (10 < loopMultiplier[currLayer]) loopMultiplier[currLayer] = 10;
      println("Loop multiplier: " + loopMultiplier[currLayer]);
    } else if (keyCode == DOWN) {
      loopMultiplier[currLayer] -= 1;
      if (loopMultiplier[currLayer] < 1) loopMultiplier[currLayer] = 1;
      println("Loop multiplier: " + loopMultiplier[currLayer]);      
    } else if (keyCode == LEFT) {
      alphaScale[currLayer] -= 0.1;
      if (alphaScale[currLayer] < 0) alphaScale[currLayer] = 0;
      for (Stroke stroke: layers[currLayer]) {
        stroke.setAlphaScale(alphaScale[currLayer]);   
      }
    } else if (keyCode == RIGHT) {
      alphaScale[currLayer] += 0.1;
      if (1 < alphaScale[currLayer]) alphaScale[currLayer] = 1;      
      for (Stroke stroke: layers[currLayer]) {       
        stroke.setAlphaScale(alphaScale[currLayer]);   
      }      
    } else if (keyCode == CONTROL) {
      dissapearing = !dissapearing;
      println("Dissapearing lines: " + dissapearing);
    }
    return;
  }  
  
  if (key == ' ') {
    looping = !looping;
    println("Looping: " + looping);
  } else if (key == ENTER || key == RETURN) {
    grouping = !grouping;
    println("Grouping: " + grouping);
  } else if (key == DELETE || key == BACKSPACE) {      
    for (Stroke stroke: layers[currLayer]) {
      stroke.looping = false;
      stroke.fadeOutFact = DELETE_FACTOR;
    }
    if (currStroke != null) {
      currStroke.looping = false;
      currStroke.fadeOutFact = DELETE_FACTOR;
    }
    println("Delete layer");
  } else if (key == TAB) {
    fixed = !fixed;
    println("Fixed: " + fixed);
  } else if (key == 's') {
   saveDrawing();        
  } else if (key == '1') {
    currLayer = 0;
    println("Selected stroke layer: " + 1);
  } else if (key == '2') {
    currLayer = 1;
    println("Selected stroke layer: " + 2);
  } else if (key == '3') {
    currLayer = 2;
    println("Selected stroke layer: " + 3);
  } else if (key == '4') {
    currLayer = 3;
    println("Selected stroke layer: " + 4);
  } else {
    for (int i = 0; i < TEXTURE_KEYS.length; i++) {
      if (key ==  TEXTURE_KEYS[i]) {
        currTexture = i;
        return;
      }
    } 
  }   
}

void controllerChange(int channel, int number, int value) {
  if (2 <= number && number <= 5) {
     int layer = number - 2;
     loopMultiplier[layer] = int(map(value, 0, 127, 1, 10));
     println("Loop multiplier: " + loopMultiplier[layer]);     
  }
  if (14 <= number && number <= 17) {
    int layer = number - 14;
    float scale = map(value, 0, 127, 1, 0);    
    for (Stroke stroke: layers[layer]) {
      stroke.setAlphaScale(scale);
    }    
  }
  
  if (number == 49) {
    if (value == 127) {
      looping = true;
    } else {
      looping = false;
    }
  }
  
   if (number == 48) {
    if (value == 127) {
      dissapearing = true;
    } else {
      dissapearing = false;
    }
  }    
  
   if (number == 46) {
    if (value == 127) {
      fixed = true;
    } else {
      fixed = false;
    }
  }   
  
   if (number == 44) {
    if (value == 127) {
      grouping = true;
    } else {
      grouping = false;
    }
  }   
}