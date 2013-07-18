float RIBBON_WIDTH = 1.0; // Average ribbon width
float SMOOTH_COEFF = 0.7; // Smoothing coefficient used to ease the jumps in the tracking data.
int RIBBON_DETAIL = 5;
float MIN_POS_CHANGE = 2;
float NORM_FACTOR = 5; // This factor allows to normalize ribbon width with respect to the speed of the 
                       // drawing, so that all ribbons have approximately same width.
float MIN_CTRL_CHANGE = 5;
float TEXCOORDU_INC = 0.1;

boolean LOOPING_AT_INIT = true;
float FADEOUT_FACTOR = 0.995; // 1 = no fade-out.
float INVISIBLE_ALPHA = 1; // Alpha at which a stroke is considered invisible

String DRAW_FILENAME = "drawing.xml";

String TEXTURE_FILE1 = "line00/02.png";
String TEXTURE_FILE2 = "line02/01.png";
String TEXTURE_FILE3 = "line02/02.png";
String TEXTURE_FILE4 = "line03/01.png";
String TEXTURE_FILE5 = "line03/02.png";
String TEXTURE_FILE6 = "line04/01.png";

