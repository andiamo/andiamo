int startStrokeTime;

void mousePressed() {
  int t0 = startStrokeTime = millis();
  
  boolean connected = false;
  if (lastStroke != null && grouping && t0 - lastStroke.t1 < 1000 * MAX_GROUP_TIME) {
    t0 = lastStroke.t0;
    connected = true;    
  }
  
  currStroke = new Stroke(t0, dissapearing, fixed, currTexture, lastStroke);
  currStroke.setMaxAlpha(maxAlpha);
  currStroke.setFadeoutMult(fadeoutMult);
  
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
  handleBasicKeyboardInput();
  if (INPUT_MIDI_DEVICE == -1) {
    // Don't have MIDI controller, using keyboard for everything
    handleFullKeyboardInput();
  }
}

void handleBasicKeyboardInput() {
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

  // Layer selection
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
  }
  
  // Texture selection
  for (int i = 0; i < TEXTURE_KEYS.length; i++) {
    if (key ==  TEXTURE_KEYS[i]) {
      currTexture = i;
      println("Selected texture: " + (i + 1));
      return;
    }
  }  
  
  if (key == 's') {
    saveDrawing();        
  }  
}

void handleFullKeyboardInput() {
  if (key == ' ') {
    // SPACE key: enables/disables looping
    looping = !looping;
    println("Looping: " + looping);
  } else if (key == ENTER || key == RETURN) {
    // ENTER key: enables/disables line grouping, when enabled consecutive
    // lines are animated together.    
    grouping = !grouping;
    println("Grouping: " + grouping);
  } else if (key == TAB) {
    // TAB key: enables/disables fixed lines, when enabled
    // lines don't animate at all after being created    
    fixed = !fixed;
    println("Fixed: " + fixed);
  }
  
  if (key == CODED) {
    if (keyCode == UP || keyCode == DOWN) {
      // UP and DOWN keys, control speed of all strokes in current layer
      if (keyCode == UP && loopMultiplier[currLayer] < 127) loopMultiplier[currLayer] += 4;
      if (keyCode == DOWN && 0 < loopMultiplier[currLayer]) loopMultiplier[currLayer] -= 4;
      float mult = map(loopMultiplier[currLayer], 0, 127, 1, 0.1);
      int layer = currLayer;
      for (Stroke stroke: layers[layer]) {
        stroke.setSpeedMult(mult);
      } 
    } else if (keyCode == LEFT || keyCode == RIGHT) {
      // RIGTH and LEFT keys, control alpha of all strokes in current layer
      if (keyCode == RIGHT && alphaScale[currLayer] < 127) alphaScale[currLayer] += 4;
      if (keyCode == LEFT && 0 < alphaScale[currLayer]) alphaScale[currLayer] -= 4;    
      float scale = map(alphaScale[currLayer], 0, 127, 0, 1);
      int layer = currLayer;
      for (Stroke stroke: layers[layer]) {
        stroke.setAlphaScale(scale);
      }
    } else if (keyCode == CONTROL) {
      // CONTROL key: enables/disables dissapearing line when in loop mode,
      // meaning that lines start fading out from the startint point before the 
      // drawing animation ends.  
      dissapearing = !dissapearing;
      println("Dissapearing lines: " + dissapearing);
    }
    return;
  }
}

void controllerChange(int channel, int number, int value) {
  // First slider, controls alpha of stroke being drawn
  if (number == 2) {
    maxAlpha = map(value, 0, 127, 0, 1);
    if (currStroke != null) {
      currStroke.setMaxAlpha(maxAlpha);
    }
  }  
  
  // First knob, controls fadeout speed of stroke being drawn
  if (number == 14) {
    fadeoutMult = map(value, 0, 127, 1, 0.1);
    if (currStroke != null) {
      currStroke.setFadeoutMult(fadeoutMult);
    }    
  }  
  
  // Sliders from second through fifth, control alpha of all strokes in corresponding layer
  if (3 <= number && number <= 8) {
    int layer = number - 3;
    float scale = map(value, 0, 127, 0, 1);    
    for (Stroke stroke: layers[layer]) {
      stroke.setAlphaScale(scale);
    }    
  }

  // Knob from second through fifth, control speed of all strokes in corresponding layer
  if (15 <= number && number <= 19) {
    int layer = number - 15;
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
    println("Looping: " + looping);
  }

  // Stop switch: enables/disables fixed lines, when enabled
  // lines don't animate at all after being created
  if (number == 46) {
    if (value == 127) {
      fixed = true;
    } else {
      fixed = false;
    }
    println("Fixed: " + fixed);
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
    println("Dissapearing lines: " + dissapearing);
  }    
  
  // Record switch: enables/disables line grouping, when enabled consecutive
  // lines are animated together. 
  if (number == 44) {
    if (value == 127) {
      grouping = true;
    } else {
      grouping = false;
    }
    println("Grouping: " + grouping);
  }   
}