import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import processing.serial.*;
import processing.sound.*;
import processing.video.*;
import oscP5.*;
import netP5.*;

boolean override = false;
char inputKey;
// if false = facts, if true = pathos
boolean animationType = false;

// wekinator
OscP5 oscP5;
NetAddress dest;

// video and sound
static final int QTY = 7;
final Movie[] movies = new Movie[QTY];
int soundIndex = 0;
int idx;
int output = 1; 

Minim minim;
AudioPlayer audioPlayer1;
AudioPlayer audioPlayer2;
AudioPlayer audioPlayer3;

Movie idle;
Movie nonSustainable;
Movie mediumSustainable;
Movie sustainable;
Movie compare1_2;
Movie compare1_3;
Movie compare2_3;
Movie compare1_2Pathos;
Movie compare1_3Pathos;
Movie compare2_3Pathos;
Movie nonSustainablePathos;
Movie mediumSustainablePathos;
Movie sustainablePathos;
Movie mediumPathos;

// smoothing variables
int[] smoothingArray = {0, 0, 0, 0, 0, 0, 0} ;
// number of samples in the smoothing algorith
final int smoothingSamples = 10;
// number of samples that have to be the same
final int smoothingNumber = 5;
int inputCounter = 0;

void setup()
{
  //size(1280, 720, JAVA2D);
  fullScreen(JAVA2D);
  noSmooth();
  frameRate(30);
  
  idle = new Movie(this, "pause.m4v");
  nonSustainable = new Movie(this, "logos1.m4v");
  mediumSustainable = new Movie(this, "Logos2.m4v");
  sustainable = new Movie(this, "Logos3.m4v");
  nonSustainablePathos = new Movie(this, "patos1.m4v");
  mediumSustainablePathos = new Movie(this, "patos2.m4v");
  sustainablePathos = new Movie(this, "patos3.m4v");
  
  compare1_2 = new Movie(this, "Logos1+2.m4v");
  compare1_3 = new Movie(this, "Logos2+3.m4v");
  compare2_3 = new Movie(this, "Logos1+3.m4v");
  compare1_2Pathos = new Movie(this, "patos1+2.m4v");
  compare1_3Pathos = new Movie(this, "patos2+3.m4v");
  compare2_3Pathos = new Movie(this, "patos178+3.m4v");
  
  movieArrayFill();
  
  minim = new Minim(this);
  audioPlayer1 = minim.loadFile("nonsustainable.mp3");  
  audioPlayer2 = minim.loadFile("mediumsustainable.mp3");
  audioPlayer3 = minim.loadFile("sustainable.mp3");  
  
  // wekinator setup
  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6448);
  
  noLoop();
}

void movieArrayFill(){
  
  if(!animationType){
    //Idle state
    movies[0] = idle;
    //T-shirt 1
    movies[1] = nonSustainable;
    //T-shirt 2
    movies[2] = mediumSustainable;
    //T-shirt 3
    movies[3] = sustainable;
    //Compare 1 & 2
    movies[4] = compare1_2;
    //Compare 2 & 3
    movies[5] = compare1_3;
    //Compare 1 & 3
    movies[6] = compare2_3;
    movies[0].loop();
  }
  else{
    //Idle state
    movies[0] = idle;
    //T-shirt 1
    movies[1] = nonSustainablePathos;
    //T-shirt 2
    movies[2] = mediumSustainablePathos;
    //T-shirt 3
    movies[3] = sustainablePathos;
    //Compare 1 & 2
    movies[4] = compare1_2Pathos;
    //Compare 2 & 3
    movies[5] = compare1_3Pathos;
    //Compare 1 & 3
    movies[6] = compare2_3Pathos;
    movies[0].loop();
  }
}

void draw()
{
  background(0);
  set(0,0,movies[idx] );
  println(override);
  println(output);
  moviePlayer();
  
}

void keyPressed(){
  if(key == ENTER){
    override = !override;
  }
  
  if(key == TAB){
    animationType = !animationType;
    movieArrayFill();
  }
  
  if(override){
    switch(key){
      case '1':
        output = 1;
        break;
      case '2':
        output = 2;
        break;
      case '3':
        output = 3;
        break;
      case '4':
        output = 4;
        break;
      case '5':
        output = 5;
        break;
      case '6':
        output = 6;
        break;
      case '7':
        output = 7;
        break;
      default:
        output = 1;
        break;
    }
  }
}
  
void movieEvent(Movie m) 
{  
  m.read();
  redraw = true;
}

static final int getMovieIndex(int k) {
  switch (k) {
  case 1:
    return 0;
  case 2: 
    return 1;
  case 3: 
    return 2;
  case 4: 
    return 3;
  case 5:
    return 4;
  case 6:
    return 5;
  case 7:
    return 6;
  default: 
    return -1;
  }
}

void moviePlayer() {
  int k = output, n = getMovieIndex(k) ;
 
  if (n >= 0 & n != idx) {
    movies[idx].stop();
    movies[idx = n].loop();
    if(n == 1){
    audioPlayer2.pause();
    audioPlayer2.rewind();
    audioPlayer3.pause();
    audioPlayer3.rewind();
    //audioPlayer1.play(); 
    audioPlayer1.loop();
  }
  else if(n == 2){
    audioPlayer1.pause();
    audioPlayer1.rewind();
    audioPlayer3.pause();
    audioPlayer3.rewind();
    //audioPlayer2.play();
    audioPlayer2.loop();
  }
  else if(n == 3){
    audioPlayer1.pause();
    audioPlayer1.rewind();
    audioPlayer2.pause();
    audioPlayer2.rewind();
    //audioPlayer3.play();
    audioPlayer3.loop();
  }
  else{
    audioPlayer1.pause();
    audioPlayer1.rewind();
    audioPlayer2.pause();
    audioPlayer2.rewind();
    audioPlayer3.pause();
    audioPlayer3.rewind();
  }
  }

}

void oscEvent(OscMessage theOscMessage) 
{
  if (theOscMessage.checkAddrPattern("/wek/outputs") == true) {
    //output = int(theOscMessage.get(0).floatValue());

    // will assign result to output after 10 samples
    if (!override){
      smoothing(int(theOscMessage.get(0).floatValue()));
    }
  }
}

// filters flickering
void smoothing(int input){

  if(input >= 1 && input <= 7){
    smoothingArray[input-1] = smoothingArray[input-1] + 1;
    inputCounter++;
  }
  if(inputCounter >= smoothingSamples){
    for(int i = 0; i < 7; i++){
      if(smoothingArray[i] >= smoothingNumber){
        output = i+1;
      }
    }
    inputCounter = 0; 
    for(int i = 0; i < 7; i++){
      smoothingArray[i] = 0;
    }
  }
}
