int ribbonDetail;
int nVertPerStretch;
int nControl = 0;
BSpline lspline;
BSpline rspline;

float oldX, oldY, oldZ;
float newX, newY, newZ;
float oldVel;
float newVel;
float twist;
float ribbonsWidth;

float pX0, pY0;
float pX, pY;

void initRibbons() {
  ribbonDetail = RIBBON_DETAIL;
  nVertPerStretch = 0;
  for (int ui = 1; ui <= 10; ui ++) {
    if (ui % ribbonDetail == 0) {
      nVertPerStretch += 4;
    }
  }    
  lspline = new BSpline(true);
  rspline = new BSpline(true);
  ribbonsWidth = random(0.7 * RIBBON_WIDTH, 1.3 * RIBBON_WIDTH);  
}

void addPointToRibbon(float x, float y) {
  pX = x;
  pY = y;

  if (currStroke.starting()) {
    // (x, y) is the first position, so initializing the previous position to this one.
    pX0 = pX;
    pY0 = pY;
    nControl = 0;
    return;
  } 

  // Discarding steps that are too small.
  if (abs(pX - pX0) < MIN_POS_CHANGE && abs(pY - pY0) < MIN_POS_CHANGE) return;
  pX0 = pX;
  pY0 = pY;

  if (nControl == 4) {
    lspline.shiftBSplineCPoints();
    rspline.shiftBSplineCPoints();
  } 
  else {
    // Initializing the first 4 control points
    PVector p1 = new PVector(pX, pY, 0);
    PVector p0 = new PVector(pX0, pY0, 0);
    PVector p10 = PVector.sub(p0, p1);
    PVector p_1 = PVector.add(p0, p10); 
    PVector p_2 = PVector.add(p_1, p10);

    lspline.setCPoint(0, p_2);
    lspline.setCPoint(1, p_1);
    lspline.setCPoint(2, p0);
    lspline.setCPoint(3, p1);

    rspline.setCPoint(0, p_2);
    rspline.setCPoint(1, p_1);
    rspline.setCPoint(2, p0);
    rspline.setCPoint(3, p1);

    newX = pX;
    newY = pY;
    newZ = 0;

    nControl = 4;
  }

//  twist[i] = TWO_PI * cos(TWO_PI * millis() / (1000.0 * twistPeriod[i]) + twistPhase[i]); 
  oldX = newX;
  oldY = newY;
  oldZ = newZ;
  newX = SMOOTH_COEFF * oldX + (1 - SMOOTH_COEFF) * pX;
  newY = SMOOTH_COEFF * oldY + (1 - SMOOTH_COEFF) * pY;
  newZ = 0;

  float dX = newX - oldX;
  float dY = newY - oldY;
  float dZ = newZ - oldZ;

  float nX = +dY;
  float nY = -dX;
  float nZ = 0;    

  PVector dir = new PVector(dX, dY, dZ);
  PVector nor = new PVector(nX, nY, nZ);
  oldVel = newVel;
  float l = dir.mag();
  newVel = ribbonsWidth / map(l, 0, 100, 1, NORM_FACTOR + 0.1);

//  dir.normalize();
//    PMatrix3D rmat = new PMatrix3D();
//    rmat.rotate(twist[i], dir.x, dir.y, dir.z);
//    PVector rnor = rmat.mult(nor, null);

  addControlPoint(lspline, newX, newY, newZ, nor, +newVel);
  addControlPoint(rspline, newX, newY, newZ, nor, -newVel);

  drawRibbonStretch(lspline, rspline);
}

boolean addControlPoint(BSpline spline, float newX, float newY, float newZ, PVector nor, float vel) {
  boolean addCP = true;
  PVector cp1 = new PVector(newX - vel * nor.x, newY - vel * nor.y, newZ - vel * nor.z);
  if (1 < nControl) {
    PVector cp0 = new PVector();
    spline.getCPoint(nControl - 2, cp0);
    addCP = MIN_CTRL_CHANGE < cp1.dist(cp0);
  }
  if (addCP) {
    spline.setCPoint(nControl - 1, cp1);
    return true;
  }
  return false;
}

float uTexCoord = 0;
PVector Sid1Point0 = new PVector();
PVector Sid1Point1 = new PVector();
PVector Sid2Point0 = new PVector();
PVector Sid2Point1 = new PVector();
void drawRibbonStretch(BSpline spline1, BSpline spline2) {  
  int ti;
  float t;
  float x, y, z;

  // The initial geometry is generated.
  spline1.feval(0, Sid1Point1);
  spline2.feval(0, Sid2Point1);

  for (ti = 1; ti <= 10; ti++) {    
    if (ti % ribbonDetail == 0) {
      t = 0.1 * ti;

      // The geometry of the previous iteration is saved.
      Sid1Point0.set(Sid1Point1);
      Sid2Point0.set(Sid2Point1);

      // The new geometry is generated.
      spline1.feval(t, Sid1Point1);
      spline2.feval(t, Sid2Point1);
      
      StrokeQuad quad = new StrokeQuad(millis());
      quad.setVertex(0, Sid1Point0.x, Sid1Point0.y, Sid1Point0.z, 0, uTexCoord, 255, 255, 255, 150);
      quad.setVertex(1, Sid2Point0.x, Sid2Point0.y, Sid2Point0.z, 1, uTexCoord, 255, 255, 255, 150);
      updateTexCoordU();
      quad.setVertex(2, Sid2Point1.x, Sid2Point1.y, Sid2Point1.z, 1, uTexCoord, 255, 255, 255, 150);
      quad.setVertex(3, Sid1Point1.x, Sid1Point1.y, Sid1Point1.z, 0, uTexCoord, 255, 255, 255, 150);      
      updateTexCoordU();
      currStroke.addQuad(quad);
    }    
  }
}

void updateTexCoordU() { 
  uTexCoord += TEXCOORDU_INC;
  if (1 < uTexCoord) {
    uTexCoord = 0;
  } 
}
