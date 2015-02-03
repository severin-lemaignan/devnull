import processing.video.*;

PImage image;
Capture cam;

Scrollbar hueMinBar;
Scrollbar hueMaxBar;

void setup() {
  size(800, 600);
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[12]);
    cam.start();
   }
   
   
   hueMinBar= new Scrollbar(160, 205, 320, 20, 1, 255);
   hueMaxBar= new Scrollbar(160, 230, 320, 20, 1, 255);

}

  public PImage hueThreshold(PImage img,  float min_hue, float max_hue, float min_brightness, float max_brightness,float min_saturation, float max_saturation) {
    PImage hueImg = createImage(img.width, img.height, ALPHA);
    for (int i = 0; i < img.width * img.height; i++) {
      float br = brightness(img.pixels[i]);
      if (br > max_brightness || br < min_brightness) {
        hueImg.pixels[i] = color(0);
        continue;
      }
      float sat=saturation(img.pixels[i]);
      if (sat > max_saturation || sat < min_saturation) {
        hueImg.pixels[i] = color(0);
        continue;
      }
      float hue = hue(img.pixels[i]);
      if (hue > max_hue || hue < min_hue)
        hueImg.pixels[i] = color(0);
      else
        hueImg.pixels[i] = color(255);
    }

    return hueImg;
  }
public PImage sobel(PImage img,float[] gtheta) {

    // Scharr kernel
    float[][] kernel_h = { {  3,  0,  -3  }, 
                 { 10,  0, -10 }, 
                 {  3,  0,  -3  } };
    
    float[][] kernel_v = { {  3,  10,  3 }, 
                   {  0,   0,  0 }, 
                   { -3, -10, -3 } };

    /*
     * float[][] kernel_h = {{ 0, 0, 0}, { 1, 0,-1}, { 0, 0, 0}}; float[][]
     * kernel_v = {{ 0, 1, 0}, { 0, 0,0}, { 0, -1, 0}};
     */
    PImage edgeImg = createImage(img.width, img.height, ALPHA);
    // Clear the image (ie, white background) why not black :) ?
    for (int i = 0; i < img.width * img.height; i++) {
      edgeImg.pixels[i] = color(0);
    }
    float max=0;
    float[] gvalue=new float[img.width*img.height];
    // Loop through every pixel in the image.
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
                            // edges
        float sum = 0;
        float sum_h = 0; // Kernel sum for this pixel
        float sum_v = 0; // Kernel sum for this pixel

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            // Calculate the adjacent pixel for this kernel point
            int pos = (y + ky) * img.width + (x + kx);
            // Image is grayscale, red/green/blue are identical
            float val = red(img.pixels[pos]);
            // Multiply adjacent pixels based on the kernel values
            sum_h += kernel_h[ky + 1][kx + 1] * val;
            sum_v += kernel_v[ky + 1][kx + 1] * val;
          }
        }
        sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        
        if(sum>max)
          max=sum;
        
        gvalue[y * img.width + x]=sum;
        gtheta[y * img.width + x]=atan2(sum_v, sum_h);
        /*
        // For this pixel in the new image, set the gray value
        // based on the sum from the kernel
        if (sum < pow(450, 2)) {
          // if (sum < pow(30,2)) {
          edgeImg.pixels[y * img.width + x] = color(255);
        } else {
          edgeImg.pixels[y * img.width + x] = color(0);
        }
        */
      }
    }
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        int val=(int) ((gvalue[y * img.width + x] / max)*255);
        edgeImg.pixels[y * img.width + x]=color(val);
      }
    }
    return edgeImg;
  }
public PImage gaussianBlur(PImage img) {
    
//    float[][] kernel = { { 9,  12, 9 }, 
//               { 12, 15, 12 }, 
//               { 9,  12, 9 } };
    float[][] kernel = { { 0,  0, 0 }, 
               { 1, 0, 0 }, 
               { 0,  0, 0 } };
    
//    float weight = 1.f / 99;
  float weight = 1.f;

    PImage blurredImg = createImage(img.width, img.height, RGB);

    // Loop through every pixel in the image.
    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
                            // edges
        float sum = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            // Calculate the adjacent pixel for this kernel point
            int pos = (y + ky) * img.width + (x + kx);
            // Turn image to grayscale
            float val = brightness(img.pixels[pos]);
            // Multiply adjacent pixels based on the kernel values
            sum += kernel[ky + 1][kx + 1] * val;

          }
        }
        blurredImg.pixels[y * img.width + x] = color((int) (sum * weight));
      }
    }
    return blurredImg;
  }
  
void draw() {


  
  float hueMin = hueMinBar.getPos();
  float hueMax = hueMaxBar.getPos();
  hueMinBar.update();
  hueMaxBar.update();

  
  
  if (cam.available() == true) {
    cam.read();
    image = cam.get();
    background(color(0,0,0));
  PImage thresholded = createImage(image.width, image.height, RGB);
  PImage thresholdedColor = createImage(image.width, image.height, RGB);
  
  PImage kernel = gaussianBlur( image ); //<>//
  
  image(image, 0, 0);


  for(int i=0; i < image.width * image.height; i++){
      float hue = hue(image.pixels[i]);
      //if (hueMin > hue && hue > hueMax) {
        thresholded.pixels[i] = color(hue);
      //  thresholdedColor.pixels[i] = image.pixels[i];
      //}
      //else {
      //  thresholded.pixels[i] = color(0);
      //  thresholdedColor.pixels[i] = color(0);

      //}

  }
  //image(thresholded, image.width, 0);

  image(kernel, image.width, 0);
  //image(thresholdedColor, image.width, image.height);
  //hueMinBar.display();
  //hueMaxBar.display();
  
  }
  
}
