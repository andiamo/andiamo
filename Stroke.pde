class StrokeQuad {  
  float[] x, y, z;
  float[] u, v;  
  float[] r, g, b, a;
  float[] a0;
  boolean visible;

  int t, srct;

  StrokeQuad(int t) {
    this.t = t;
    this.srct = t;
    x = new float[4];
    y = new float[4];
    z = new float[4];
    u = new float[4];
    v = new float[4];    
    r = new float[4];
    g = new float[4];
    b = new float[4];
    a = new float[4];
    a0 = new float[4];
    visible = true;
  }
  
  StrokeQuad(XML xml) {
    t = parseInt(xml.getChild("t").getContent());
    srct = t;
    x = new float[4];
    y = new float[4];
    z = new float[4];
    u = new float[4];
    v = new float[4];    
    r = new float[4];
    g = new float[4];
    b = new float[4];
    a = new float[4];
    a0 = new float[4];
    for (int i = 0; i < 4; i++) {
      String vert = xml.getChild("v" + i).getContent();
      String[] parts = split(vert, ",");
      x[i] = parseFloat(parts[0]);
      y[i] = parseFloat(parts[1]);
      z[i] = parseFloat(parts[2]);
      
      u[i] = parseFloat(parts[3]);
      v[i] = parseFloat(parts[4]);
   
      r[i] = parseFloat(parts[5]);
      g[i] = parseFloat(parts[6]);

      b[i] = parseFloat(parts[7]);
      a[i] = parseFloat(parts[8]);
      a0[i] = parseFloat(parts[9]);
    }
  }

  void setVertex(int i, float x, float y, float z, float u, float v, float r, float g, float b, float a) {
    this.x[i] = x;
    this.y[i] = y;
    this.z[i] = z;

    this.u[i] = u;
    this.v[i] = v;

    this.r[i] = r;
    this.g[i] = g;
    this.b[i] = b;
    this.a[i] = a;

    a0[i] = a;
  }

  void restoreAlpha() {
    for (int i = 0; i < 4; i++) {
      a[i] = a0[i];
    }
  }

  void update(float ff) {
    visible = false;
    for (int i = 0; i < 4; i++) {
      a[i] *= ff;
      if (INVISIBLE_ALPHA < a[i]) {        
        visible = true;
      } else {
        a[i] = 0;
      }
    }     
  }

  void draw(PGraphics pg, float ascale) {
    if (visible) {      
      for (int i = 0; i < 4; i++) {        
       if (USE_TEXTURES) {
         pg.tint(r[i], g[i], b[i], a[i] * ascale);
         pg.vertex(x[i], y[i], u[i], v[i]);
       } else {
         pg.fill(r[i], g[i], b[i], a[i] * ascale);
         pg.vertex(x[i], y[i]);          
       } 
      }
    }
  }
  
  String toXML() {
    String res = "<quad>\n" +
                 "<t>" + t + "</t>\n";    
    for (int i = 0; i < 4; i++) {
      res += "<v" + i + ">" + x[i] + "," + y[i] + "," + z[i] + "," +
                              u[i] + "," + v[i] + "," + 
                              r[i] + "," + g[i] + "," + b[i] + "," + a[i] + "," + a0[i] +
             "</v" + i + ">\n";
    }
    res += "</quad>\n";
    return res;
  }
}

class Stroke {
  Stroke prev, next;
  ArrayList<StrokeQuad> quads;
  float speedMult;
  int t0, t1, srct1;  
  int tex;
  boolean looping;
  float fadeOutFact0;  
  float fadeOutFact;
  float alphaScale;
  float maxAlpha;
  float fadeoutMult;
  
  int qcount;
  boolean starting;
  boolean visible;
  int loopTime;
  int lastUpdate;
  
  boolean fixed;
  boolean dissapearing;

  Stroke(int t0, boolean dissapearing, boolean fixed, int tex, Stroke prev) {
    this.prev = prev;
    next = null;
    quads = new ArrayList<StrokeQuad>();
    
    speedMult = 1;
    this.t0 = t0;
    this.tex = tex;      
    
    looping = false;    
    alphaScale = 1;
    maxAlpha = 1;
    fadeoutMult = 1;
    
    starting = true;
    visible = true;
    loopTime = -1;
    fadeOutFact = 1;
    
    this.dissapearing = dissapearing;
    this.fixed = fixed;
  }

  Stroke(XML xml) {
    t0 = parseInt(xml.getChild("t0").getContent());  
    tex = parseInt(xml.getChild("tex").getContent());   
    looping = parseBoolean(xml.getChild("looping").getContent());
    fadeOutFact = parseFloat(xml.getChild("fadeOutFact").getContent());
    maxAlpha = parseFloat(xml.getChild("maxAlpha").getContent());
    
    quads = new ArrayList<StrokeQuad>();  
    XML[] children = xml.getChildren("quad");
    for (int i = 0; i < children.length; i++) {
      StrokeQuad quad = new StrokeQuad(children[i]); 
      quads.add(quad);  
    }
      
    starting = false;
    visible = true;
    loopTime = -1;      
  }

  void clear() {
    quads.clear();    
  }
 
  boolean starting() {
    if (starting) {
      starting = false;
      return true;
    } 
    else {
      return false;
    }
  }

  //float getAlphaScale() {
  //  return alphaScale;
  //}

  boolean isVisible() {
    return visible;
  }

  boolean isLooping() {
    return looping;
  }

  void setLooping(boolean loop) {
    looping = loop;
  }

  void setAlphaScale(float s) {
    alphaScale = s;
  }

  void setSpeedMult(float mult) {
    speedMult = mult;
    updateTimes();
  }

  void setFadeoutMult(float mult) {
    fadeoutMult = mult;
  }

  void setMaxAlpha(float maxa) {
    maxAlpha = maxa;
  }

  void setEndTime(int t1) {
    srct1 = t1;
    updateTimes();
    
    if (fixed) {
      fadeOutFact = 1;
    } else {    
      float millisPerFrame =  1000.0 / frameRate;
      float dt = t1 - t0;
      int nframes = int(fadeoutMult * dt / millisPerFrame);
      fadeOutFact = exp(log(INVISIBLE_ALPHA/255) / nframes);
      fadeOutFact0 = fadeOutFact;
    }
  } 
  
  void updateTimes() {
    if (speedMult < 1) {
      // Rescaling time 
      int slen = int(speedMult * (srct1 - t0));
      for (StrokeQuad quad: quads) {
        int qlen = int(speedMult * (quad.srct - t0));
        quad.t = t0 + qlen;
      }    
      this.t1 = t0 + slen;
    } else {
      this.t1 = srct1;
    } 
  }

  void addQuad(StrokeQuad quad) {
    quads.add(quad);
  } 

  void update(int t) {
    visible = false;
    qcount = 0;
    for (StrokeQuad quad: quads) {
      if (loopTime == -1 || quad.t - t0 <= loopTime) {  
        quad.update(fadeOutFact);
        qcount++;
        if (quad.visible) {
          visible = true;
        }
      }
    } 
     
    if (looping) {
      if (-1 < loopTime) {
        loopTime += t - lastUpdate;
      }      
      if (isDrawn()) {
        // start/restart loop.
        if (!dissapearing) fadeOutFact = 1;
        for (StrokeQuad quad: quads) {
          quad.restoreAlpha();
        }      
        loopTime = 0;
      }
      if (t1 - t0 < loopTime) {
        fadeOutFact = fadeOutFact0;
      }
    }
    
    lastUpdate = t;
  }
  
  boolean isDrawn() {
    return 0 < qcount && !visible && (next == null || next.isDrawn());
  }

  void draw(PGraphics pg) {
    if (visible) {
      pg.beginShape(QUADS);
      pg.noStroke();
      if (USE_TEXTURES) {
        pg.texture(textures.get(tex));
      }
      for (StrokeQuad quad: quads) {
        if (loopTime == -1 || quad.t - t0 <= loopTime) {        
          quad.draw(pg, alphaScale * maxAlpha);
        }
      }  
      pg.endShape();
    }
  }
  
  String toXML() {
    String res = "<stroke>\n" +  
                 "<t0>" + t0 + "</t0>\n" +
                 "<tex>" + tex + "</tex>\n" +
                 "<looping>" + looping + "</looping>\n" +
                 "<fadeOutFact>" + fadeOutFact + "</fadeOutFact>\n" +
                 "<maxAlpha>" + maxAlpha + "</maxAlpha>\n";
    for (StrokeQuad quad: quads) {
      res += quad.toXML();
    }    
    res += "</stroke>\n";      
    return res;  
  }
}