// Cambender a.a
import processing.video.*;
import gifAnimation.*;
PImage a;
PFont f;
GifMaker gifExport;
int gifStatus = 0;
Capture video;
int capCount = 0;
int lastCap = 0;
int passedTime = 0;

void setup() {
  f = createFont("Helvetica",24,true);
  colorMode(HSB, 255);
  size(640, 480);

  video = new Capture(this, 640, 480, 5);
  video.start();
}

// Fires every time we have a frame
void captureEvent(Capture video) {
  video.read();
}

void pixelateImage(int pxSize) {
 
  // use ratio of height/width...
  float ratio;
  if (width < height) {
    ratio = height/width;
  }
  else {
    ratio = width/height;
  }
  
  // ... to set pixel height
  int pxH = int(pxSize * ratio);
  
  noStroke();
  for (int x=0; x<width; x+=pxSize) {
    for (int y=0; y<height; y+=pxH) {
      fill(a.get(x, y));
      rect(x, y, pxSize, pxH);
    }
  }
}

void posterizeImage(int rangeSize) {
  
  // the built-in filter(POSTERIZE) works ok, but this is a bit more tweakable...  
  // iterate through the pixels one by one and posterize
  loadPixels();
  for (int i=0; i<pixels.length; i++) {

    // divide the brightness by the range size (gets 0-rangeSize), then
    // multiply by the rangeSize to step by that value; set the pixel!
    int bright = int(brightness(pixels[i])/rangeSize) * rangeSize;
    pixels[i] = color(bright);
  }
  updatePixels();
}


void draw() {
  
  textFont(f);
  fill(255,255,255);

  int passedTime = millis() - lastCap;
  
  // Update every 100ms at most.
  if(passedTime > 100)
  {
    image(video, 0, 0);
    saveFrame("cam.jpg");

    // Load the frame we saved as bytes
    byte[] bytes = loadBytes("cam.jpg");
    
    // Randomly replace a byte with a random byte to glitch it up
    int loc=(int)random(128,bytes.length); //guess at header being 128 bytes at most..
    bytes[loc]=(byte)random(255);
    
    // Save the glitched bytes
    saveBytes("cam.jpg",bytes);
    
    // Load the image so we can pixellate and posterize
    a = loadImage("cam.jpg");
    pixelateImage(6);
    filter(POSTERIZE, 12);
    passedTime = 0;
    lastCap = millis();
     
    // Cap the GIF frame rate at 5
    frameRate(5);
    
    if (gifStatus == 1)
    {
      // Only add a frame if we're in capture mode
      gifExport.addFrame();
    }
    // Kill garbage.
    System.gc();
  }
}

void keyPressed() {
  // Return/Enter saves a jpg.
  if (key == '\n' ) {
    saveFrame("cam-###.jpg");
    // TODO: Make this text persist or something? I don't know.
    text("Screenshot saved", 25, 40);
  }
  
  // Spacebar contextually starts / stops GIF-ing
  if (key == ' ' ) {
    if (gifStatus == 0)
    {
      gifStatus = 1;
      gifExport = new GifMaker(this, "cambender.gif");
      gifExport.setRepeat(0);             // make it an "endless" animation
      gifExport.setDelay(1);
    }
    else
    {
      gifExport.finish();
      // TODO: Make this text persist or something? I don't know.
      text("GIF saved", 25, 40);
      gifStatus = 0;
    }
    
  }
  
}

