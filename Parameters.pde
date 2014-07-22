float RIBBON_WIDTH = 0.8; // Average ribbon width
float SMOOTH_COEFF = 0.7; // Smoothing coefficient used to ease the jumps in the tracking data.
int RIBBON_DETAIL = 5;
float MIN_POS_CHANGE = 2;
float NORM_FACTOR = 5; // This factor allows to normalize ribbon width with respect to the speed of the 
                       // drawing, so that all ribbons have approximately same width.
float MIN_CTRL_CHANGE = 5;
float TEXCOORDU_INC = 0.1;

boolean LOOPING_AT_INIT = true;       // Looping on/off when the program starts
boolean DISSAPEARING_AT_INIT = false; // Dissapearing stroke (while drawing) on/off when the program starts
boolean FIXED_STROKE_AT_INIT = false; // The strokes don't fade out if true.

float INVISIBLE_ALPHA = 1;    // Alpha at which a stroke is considered invisible
float MAX_GROUP_TIME = 5;     // Maximum between two consecutive strokes to be considered within the same loop
int LOOP_MULTIPLIER = 1;      // How many times slower the loop is with respect to the original stroke
float DELETE_FACTOR = 0.9;

String DRAW_FILENAME = "drawing.xml";

boolean USE_TEXTURES = true;

String[] TEXTURE_FILES = {
  "line00/01.png",
  "line00/02.png",
  "line01/01.png",
  "line01/02.png",    
  "line02/01.png",
  "line02/02.png",
  "line03/01.png",
  "line03/02.png",
  "line04/01.png",
  "line04/02.png"
};

char[] TEXTURE_KEYS = {
  'q',
  'Q',
  'w',
  'W',    
  'e',
  'E',
  'r',
  'R',
  't',
  'T'  
};
