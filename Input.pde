int startStrokeTime;

void mousePressed() {
  int t0 = startStrokeTime = millis();
  
  boolean connected = false;
  if (lastStroke != null && grouping && t0 - lastStroke.t1 < 1000 * MAX_GROUP_TIME) {
    t0 = lastStroke.t0;
    connected = true;    
  }
  
  currStroke = new Stroke(t0, currTexture, lastStroke);
  
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
      LOOP_MULTIPLIER += 1; 
      println("Loop multiplier: " + LOOP_MULTIPLIER);
    } else if (keyCode == DOWN) {
      LOOP_MULTIPLIER -= 1;
      if (LOOP_MULTIPLIER < 1) LOOP_MULTIPLIER = 1;
      println("Loop multiplier: " + LOOP_MULTIPLIER);      
    } else if (keyCode == LEFT) {
      for (Stroke stroke: layers[currLayer]) {
        float ascale = stroke.getAlphaScale();
        ascale = constrain(ascale - 0.05, 0, 1);
        stroke.setAlphaScale(ascale);   
      }
    } else if (keyCode == RIGHT) {
      for (Stroke stroke: layers[currLayer]) {
        float ascale = stroke.getAlphaScale();
        ascale = constrain(ascale + 0.05, 0, 1);
        stroke.setAlphaScale(ascale);   
      }      
    }
    return;
  }  
  
  if (key == ' ') {
    looping = !looping;
    println("Looping: " + looping);
  } else if (key == ENTER || key == RETURN) {
//    breakStroke();
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
    FIXED_STROKE = !FIXED_STROKE;
    println("Fixed: " + FIXED_STROKE);
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
   
  
  
  /*

  else {
    if (key == 'l') {
      looping = !looping;
      println("Looping: " +  looping);
    } else if (key == 'c') {      
      for (Stroke stroke: layers[currLayer]) {
        stroke.looping = false;
      }
      if (currStroke != null) {
        currStroke.looping = false;
      }
    } else if (key == 's') {
      saveDrawing();    
    } else if (key == 'q') {  
      currTexture = 0;
      println("Selected texture: " + 1);
    } else if (key == 'w') {
      currTexture = 1;
      println("Selected texture: " + 2);
    } else if (key == 'e') {
      currTexture = 2;
      println("Selected texture: " + 3);
    } else if (key == 'r') {  
      currTexture = 3;
      println("Selected texture: " + 4);
    } else if (key == 't') {
      currTexture = 4;
      println("Selected texture: " + 5);
    } else if (key == 'y') {  
      currTexture = 5;
      println("Selected texture: " + 6);
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
    }    
  }
  */
}

//void breakStroke() {
//  if (lastStroke != null) {
//    println("Break stroke");     
//    lastStroke.next = null;
//  }
//  if (currStroke != null) {
//    currStroke.t0 = startStrokeTime;
//  }
//}

