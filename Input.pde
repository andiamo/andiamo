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
  //if (key == CODED) {
  //  if (keyCode == UP) {
  //    loopMultiplier[currLayer] += 1;
  //    if (10 < loopMultiplier[currLayer]) loopMultiplier[currLayer] = 10;
  //    println("Loop multiplier: " + loopMultiplier[currLayer]);
  //  } else if (keyCode == DOWN) {
  //    loopMultiplier[currLayer] -= 1;
  //    if (loopMultiplier[currLayer] < 1) loopMultiplier[currLayer] = 1;
  //    println("Loop multiplier: " + loopMultiplier[currLayer]);      
  //  } else if (keyCode == LEFT) {
  //    alphaScale[currLayer] -= 0.1;
  //    if (alphaScale[currLayer] < 0) alphaScale[currLayer] = 0;
  //    for (Stroke stroke: layers[currLayer]) {
  //      stroke.setAlphaScale(alphaScale[currLayer]);   
  //    }
  //  } else if (keyCode == RIGHT) {
  //    alphaScale[currLayer] += 0.1;
  //    if (1 < alphaScale[currLayer]) alphaScale[currLayer] = 1;      
  //    for (Stroke stroke: layers[currLayer]) {       
  //      stroke.setAlphaScale(alphaScale[currLayer]);   
  //    }      
  //  } else if (keyCode == CONTROL) {
  //    dissapearing = !dissapearing;
  //    println("Dissapearing lines: " + dissapearing);
  //  }
  //  return;
  //}  
  
  //if (key == ' ') {
  //  looping = !looping;
  //  println("Looping: " + looping);
  //} else if (key == ENTER || key == RETURN) {
  //  grouping = !grouping;
  //  println("Grouping: " + grouping);
  //} else 
  
  if (key == DELETE || key == BACKSPACE) {      
    for (Stroke stroke: layers[currLayer]) {
      stroke.looping = false;
      stroke.fadeOutFact = DELETE_FACTOR;
    }
    if (currStroke != null) {
      currStroke.looping = false;
      currStroke.fadeOutFact = DELETE_FACTOR;
    }
    println("Delete layer");
  } 
  //else if (key == TAB) {
  //  fixed = !fixed;
  //  println("Fixed: " + fixed);
  //} 
  //else if (key == 's') {
  // saveDrawing();        
  //} else 
  
  if (key == '1') {
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
        println("Selected texture: " + (i + 1));
        return;
      }
    } 
  }   
}

void controllerChange(int channel, int number, int value) {
  // First slider, controls alpha of all strokes in current layer
  if (number == 2) {
    int layer = currLayer;
    float scale = map(value, 0, 127, 0, 1);    
    for (Stroke stroke: layers[layer]) {
      stroke.setAlphaScale(scale);
    }    
  }

  // First knob, controls speed of all strokes in current layer
  if (number == 14) {    
    int layer = currLayer;
    float mult = map(value, 0, 127, 1, 0.1);
    for (Stroke stroke: layers[layer]) {
      stroke.setSpeedMult(mult);
    } 
  }
  
  // Loop switch: enables/disables looping
  if (number == 49) {
    if (value == 127) {
      looping = true;
    } else {
      looping = false;
    }
  }

  // Stop switch: enables/disables fixed lines, when enabled
  // lines don't animate at all after being created
  if (number == 46) {
    if (value == 127) {
      fixed = true;
    } else {
      fixed = false;
    }
  }  
  
  // Fast-forward switch: enables/disables dissapearing line when in loop mode,
  // meaning that lines start fading out from the startint point before the 
  // drawing animation ends.
  if (number == 48) {
    if (value == 127) {
      dissapearing = true;
    } else {
      dissapearing = false;
    }
  }    
  
  // Record switch: enables/disables line grouping, when enabled consecutive
  // lines are animated together. 
  if (number == 44) {
   if (value == 127) {
     grouping = true;
   } else {
     grouping = false;
   }
  }   
}