int R, G, B, A; 
import processing.video.*;
PImage myMap;
Capture ourVideo;          // variable to hold the video

void setup() {
  size(1280, 800);
  frameRate(50);
  String videoList[] = Capture.list();
  ourVideo = new Capture(this, width, height, videoList[0]);   // open default video in the size of window
  ourVideo.start();                                  // start the video
  myMap = loadImage("map.png");
  myMap.resize(width,height);
}

void draw() {
  loadPixels();
  flashlight();
  updatePixels();
}

void flashlight() {
  myMap.loadPixels();
  if (ourVideo.available())  ourVideo.read();       // get a fresh frame of video as often as we can
  ourVideo.loadPixels();  // load the pixels array of the video 
  int recordHolderX=0, recordHolderY=0;              //these wil hold the location of the record holder
  int record= 0;                                      //this will hold the best value weve seen so far
  for (int x = 0; x<width; x++) {
    for (int y = 0; y<height; y++) {
      PxPGetPixel(x, y, ourVideo.pixels, width);    // Get the RGB of each pixel
      int thisBrightness=R+G+B;                     //adding up RGB is a good approximation of brightness
      if (thisBrightness > record) {                 // if our pixel is better than the record
        record = thisBrightness;
        recordHolderX= width-x;                           // and the new record holder
        recordHolderY= y;
      }
        PxPGetPixel(x, y, myMap.pixels, width);
        float distance = dist(x,y,recordHolderX, recordHolderY);
        float adjustBrightness = map(distance,0,100,1,0);
   
        R *= adjustBrightness;
        G *= adjustBrightness;
        B *= adjustBrightness;
        
        R = constrain(R,0,255);
        G = constrain(G,0,255);
        B = constrain(B,0,255);

        PxPSetPixel(x, y, R, G, B, A, pixels, width);
    }
  }
}

void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with the colors into the pixels[]
}
