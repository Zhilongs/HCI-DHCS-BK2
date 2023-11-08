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

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

// mouse dragging variables
boolean dragging = false;
float prevMouseX, prevMouseY;


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
  border = inchToPix(1f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    
    d.z = inchToPix((float)random(1,12)/4.0f); //increasing size from .25" up to 3.0" 
    
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

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  // Draw Line Between Logo And Target Square
  Destination currentDest = destinations.get(trialIndex);
  // Calculate the distance between the logo and the target square center
  float distance = dist(logoX, logoY, currentDest.x, currentDest.y);
  // Set the line color based on the distance
  if (distance < inchToPix(0.05f)) { // Replace 0.05f with your "close enough" distance threshold
    stroke(0, 255, 0); // Green for close enough
  } else {
    stroke(255, 0, 0); // Grey otherwise
  }
  // Draw the line
  line(logoX, logoY, currentDest.x, currentDest.y);
  
  stroke(128); // Grey otherwise
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  // Check if we're dragging the "logo"
  if (dragging) {
    logoX += mouseX - prevMouseX;
    logoY += mouseY - prevMouseY;
    
    // Update previous mouse positions
    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
}

//
void scaffoldControlLogic()
{
  float controlAreaCenterX = width/2; // Center X for the controls area
  float controlAreaY = height - inchToPix(1f); // Y position for all controls, set to near the bottom of the screen
  float controlSpacing = inchToPix(1f); // Space between each control
  
  // Control positions
  float ccwX = controlAreaCenterX - controlSpacing * 2; // Counterclockwise button X position
  float cwX = controlAreaCenterX + controlSpacing * 2; // Clockwise button X position
  
  float minusX = controlAreaCenterX - controlSpacing; // Decrease Z button X position
  float plusX = controlAreaCenterX + controlSpacing; // Increase Z button X position
  
  float leftX = controlAreaCenterX - controlSpacing * 3; // Move left button X position
  float rightX = controlAreaCenterX + controlSpacing * 3; // Move right button X position
  
  float upY = controlAreaY - controlSpacing; // Move up button Y position
  float downY = controlAreaY + controlSpacing; // Move down button Y position

  float buttonWidth = inchToPix(0.8f);  //
  float buttonHeight = inchToPix(0.6f); //
  // Rotate counterclockwise button
  fill(128); 
  rect(ccwX , controlAreaY , buttonWidth, buttonHeight);
  fill(0); 
  text("CCW", ccwX, controlAreaY);
  if (mousePressed && dist(ccwX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoRotation--;

  // Rotate clockwise button
  fill(128); 
  rect(cwX , controlAreaY , buttonWidth, buttonHeight);
  fill(0); 
  text("CW", cwX, controlAreaY);
  if (mousePressed && dist(cwX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoRotation++;

  // Decrease Z button
  fill(128); 
  rect(minusX , controlAreaY , buttonWidth, buttonHeight);
  fill(0); 
  text("-", minusX, controlAreaY);
  if (mousePressed && dist(minusX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  // Increase Z button
  fill(128); 
  rect(plusX , controlAreaY , buttonWidth, buttonHeight);
  fill(0); 
  text("+", plusX, controlAreaY);
  if (mousePressed && dist(plusX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  // Move left button
  fill(128); 
  rect(leftX , controlAreaY , buttonWidth, buttonHeight);
  fill(0);
  text("left", leftX, controlAreaY);
  if (mousePressed && dist(leftX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoX-=inchToPix(.02f);

  // Move right button
  fill(128); 
  rect(rightX, controlAreaY , buttonWidth, buttonHeight);
  fill(0);
  text("right", rightX, controlAreaY);
  if (mousePressed && dist(rightX, controlAreaY, mouseX, mouseY)<inchToPix(.4f))
    logoX+=inchToPix(.02f);

  // Move up button, positioned above the CCW and "-" buttons
  fill(128); 
  rect(controlAreaCenterX, upY , buttonWidth, buttonHeight);
  fill(0);
  text("up", controlAreaCenterX, upY);
  if (mousePressed && dist(controlAreaCenterX, upY, mouseX, mouseY)<inchToPix(.4f))
    logoY-=inchToPix(.02f);

  // Move down button, positioned below the CW and "+" buttons
  fill(128); 
  rect(controlAreaCenterX, downY , buttonWidth, buttonHeight);
  fill(0);
  text("down", controlAreaCenterX, downY);
  if (mousePressed && dist(controlAreaCenterX, downY, mouseX, mouseY)<inchToPix(.4f))
    logoY+=inchToPix(.02f);
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  // Check if the mouse is inside the "logo" rectangle upon pressing
  if (dist(mouseX, mouseY, logoX, logoY) < logoZ / 2) {
    dragging = true;
    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
}

void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(0.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  dragging = false;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
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

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
