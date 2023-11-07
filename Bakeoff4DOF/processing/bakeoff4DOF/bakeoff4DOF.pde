import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
int numClicks = 0;
float x1 = 0;
float x2 = 0;
float y1 = 0;
float y2 = 0;
float dx = 0;
float dy = 0;
boolean isSubmitButtonPressed = false;
float submitButtonX = width * 0.95;
float submitButtonY = height * 0.9;
float submitButtonWidth = inchToPix(1.0f);
float submitButtonHeight = inchToPix(0.5f);

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }
  
  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
  if (checkForSuccess()) {
    background(0, 70, 0);
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(logoRotation); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  drawSubmitButton();
}

void drawSubmitButton() {
 
  float submitButtonX = width * 0.95; 
  float submitButtonY = height * 0.9;
  float submitButtonWidth = inchToPix(1.0f); 
  float submitButtonHeight = inchToPix(0.5f);
  fill(128);
  rect(submitButtonX-submitButtonWidth/2 , submitButtonY-submitButtonHeight/2 , submitButtonWidth, submitButtonHeight);
  
  fill(0);
  textAlign(CENTER, CENTER);
  text("Submit", submitButtonX-submitButtonWidth/2, submitButtonY-submitButtonHeight/2);
}

//my example design for control, which is terrible


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if (numClicks % 2 == 0 && !inSubmit()) {
      x1 = mouseX;
      y1 = mouseY;
      numClicks++;
  }
  else if (numClicks % 2 == 1 && !inSubmit()){
      x2 = mouseX;
      y2 = mouseY;
      numClicks++;
      logoX = ((x2-x1)/2) + x1;
      logoY = ((y2-y1)/2) + y1;
      logoZ = sqrt(sq(y2-y1) + sq(x2-x1))/sqrt(2);
      dx = abs(x2 - x1);
      dy = abs(y2 - y1);
      logoRotation = atan2(dy, dx)-QUARTER_PI;
      println(atan(abs((y2-y1)/(x2-x1))));
  }
  if (inSubmit()) {
      submit();
  }
}

Boolean inSubmit() 
{
  if (mouseX > submitButtonX-submitButtonWidth/2 - 10  && mouseX < submitButtonX + submitButtonWidth/2 &&
      mouseY > submitButtonY-submitButtonHeight/2 - 10  && mouseY < submitButtonY + submitButtonHeight/2 + 10) {
      return true;
  }
  return false;
}

void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  //if (dist(width, height, mouseX, mouseY)<inchToPix(1f))
  //{
  //  if (userDone==false && !checkForSuccess())
  //    errorCount++;
  submitButtonX = width * 0.95;
  submitButtonY = height * 0.9;
  submitButtonWidth = inchToPix(1.0f);
  submitButtonHeight = inchToPix(0.5f);
  //if (inSubmit()) {
  //    submit();
  //}
}
void submit() {
  if (userDone == false && !checkForSuccess())
    errorCount++;
    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation*180/PI)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation*180/PI)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));


  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//double calculateDifferenceBetweenAngles(float a1, float a2)
//{
//  double diff=abs(a1%360-a2%360);
//  return diff;
//}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
