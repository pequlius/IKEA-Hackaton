import com.phidgets.*;
import com.phidgets.event.*;
import processing.serial.*;

// Declare Variables - a ServoPhidget object called 'sp',
// a Double called 'pos' and an integer called 'xPos'
AdvancedServoPhidget sp;
double pos;
int xPos;
boolean ENGAGED = false;

void setup() {
  //frameRate(20);
  size(400, 300);
  try {
    // Create & Assign the servophidget
    sp = new AdvancedServoPhidget();
    sp.openAny();
    println("Waiting for Phidget");
    sp.waitForAttachment();
    // if you do not see this below in the console, your phidget is not connected 
    println("OK ready to go");
    sp.setEngaged(0, true);
  } 
  catch(Exception e) {
    println("ERROR");
    System.out.println(e);
  }
}

void draw() {
  background(200);
  // map the mouse x coordinate to the
  // available range of the servophidget
  //Här läses positionen hos muspekaren så att den kan styra hastigheten på motorn 
  pos = map(mouseX, 0, width, 90, 150.0);
  // read the data from the phidget
  try {
    //det är det här värdet man ändrar för att ändra hastigheten. Det verkar vara ett ganska litet spann där det märks någon skillnad i hastighet,typ mellan 100 och 120...
    sp.setPosition(0, pos);
    // checking the max and min values for the servophidget
    double helloMax = sp.getPositionMax(0);
    double helloMin = sp.getPositionMin(0);
    // print a line to the console to display the data as it arrives
    println("min is: " + helloMin + ", max is: " + helloMax + ", current position is: " + pos);
  } 
  catch(Exception e) {
    println("ERROR");
    System.out.println(e);
  }

  float fPos = (float)pos;
  fPos = map(fPos, -22.9, 232.0, 0, height);
  stroke(0);
  //  line(xPos,0,xPos,height-fPos);
  // Un-comment out the line above to draw a vertical graph of the motor
  stroke(50);
  line(mouseX, 0, mouseX, height);
  // this controls the graph position onscreen,
  // it animates the graph and refreshes to the 0 position
  // when the graph goes offscreen
  if (xPos >= width) {
    xPos = 0;
  }
  else {
    xPos++;
  }
}

void stop() {
  try {
    // Create & Assign the servophidget
    sp.setEngaged(0, false);
  } 
  catch(Exception e) {
    println("ERROR on closing");
    System.out.println(e);
  }
} 

void keyPressed() {
  ENGAGED = !ENGAGED;
 try {
    // Create & Assign the servophidget
    sp.setEngaged(0, ENGAGED);
  } 
  catch(Exception e) {
    println("ERROR on closing");
    System.out.println(e);
  }
  delay(500);
}
