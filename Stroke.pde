class StrokeQuad {  
  float[] x, y, z;
  float[] u, v;  
  float[] r, g, b, a;
  float[] a0;
  boolean visible;

  int t;

  StrokeQuad(int t) {
    this.t = t;  
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
      if (10 < a[i]) {
        visible = true;
      } 
      else {
        a[i] = 0;
      }
    }
  }

  void draw(PGraphics pg, float ascale) {
    if (visible) {
      for (int i = 0; i < 4; i++) {
        pg.tint(r[i], g[i], b[i], a[i] * ascale);
        pg.vertex(x[i], y[i], z[i], u[i], v[i]);
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
  ArrayList<StrokeQuad> quads;
  int t0;  
  int tex;
  boolean looping;  
  float fadeOutFact;
  float alphaScale;
    
  boolean starting;
  boolean visible;
  int loopTime;
  int lastUpdate;

  Stroke(int t0, int tex, float ff) {
    quads = new ArrayList<StrokeQuad>();
    
    this.t0 = t0;
    this.tex = tex;      
    looping = false;    
    fadeOutFact = ff;
    alphaScale = 1;
    
    starting = true;
    visible = true;
    loopTime = -1;
  }

  Stroke(XML xml) {
    t0 = parseInt(xml.getChild("t0").getContent());  
    tex = parseInt(xml.getChild("tex").getContent());   
    looping = parseBoolean(xml.getChild("looping").getContent());
    fadeOutFact = parseFloat(xml.getChild("fadeOutFact").getContent());
    alphaScale = parseFloat(xml.getChild("alphaScale").getContent());
            
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

  float getAlphaScale() {
    return alphaScale;
  }

  void setAlphaScale(float s) {
    alphaScale = s;
  }

  boolean isVisible() {
    return visible;
  }

  boolean isLooping() {
    return looping;
  }

  void setLooping(boolean loop) {
    looping = loop;
  }

  void addQuad(StrokeQuad quad) {
    quads.add(quad);
  } 

  void update(int t) {
    visible = false;
    int qcount = 0;
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
      if (0 < qcount && !visible) {
        // start/restart loop.
        for (StrokeQuad quad: quads) {
          quad.restoreAlpha();
        }      
        loopTime = 0;
      }
    }
    
    lastUpdate = t;
  }

  void draw(PGraphics pg) {
    if (visible) {
      pg.beginShape(QUADS);
      pg.noStroke();
      pg.texture(textures.get(tex));
      for (StrokeQuad quad: quads) {
        if (loopTime == -1 || quad.t - t0 <= loopTime) {        
          quad.draw(pg, alphaScale);
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
                 "<alphaScale>" + alphaScale + "</alphaScale>\n";
    for (StrokeQuad quad: quads) {
      res += quad.toXML();
    }    
    res += "</stroke>\n";      
    return res;  
  }
}

