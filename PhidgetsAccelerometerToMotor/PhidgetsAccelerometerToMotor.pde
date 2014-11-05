import com.phidgets.*;
import com.phidgets.event.*;
import processing.serial.*;

// phidgets java API: http://www.phidgets.com/documentation/web/javadoc/


//Sevo controller:
AdvancedServoPhidget sp;

//Accelerometer controller
SpatialPhidget acc;

double pos;
boolean ENGAGED = false;

void setup() {
  //frameRate(20);
  size(400, 300);
  try {
    // Create & Assign the servophidget
//    sp = new AdvancedServoPhidget();
//    sp.open(302952);
    
    acc = new SpatialPhidget();
<<<<<<< HEAD
    acc.openAny();// if not working try open("serial number")
=======
    acc.openAny();
>>>>>>> origin/master
    
    println("Waiting for servo");
    // if you do not see this below in the console, your servo phidget is not connected 
    println("Servo ready to go");
    //sp.setEngaged(0, true);
    
    println("Waiting for Accelerometer");
    acc.waitForAttachment();
    // if you do not see this below in the console, your accelerometer phidget is not connected 
    println("Accelerometer ready to go");
    
  } 
  catch(Exception e) {
    println("ERROR - exception called");
    System.out.println(e);
  }
  
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
    try {
  // calculate tilt from accelerometer data
  double accel_X = acc.getAcceleration(0);
  double accel_Y = acc.getAcceleration(1);
  float tilt = 180/3.14 * (asin((float)accel_X) + asin((float)accel_Y));
  //remove erroneous values
  if(!Float.isNaN(tilt)){
  System.out.println(tilt);
  // translate the tilt value in degrees to range between the max and min values of the servo
  pos = map(tilt, -90, 90, (int)sp.getPositionMin(0), (int)sp.getPositionMax(0));

    //set the position of the servo
    sp.setPosition(0, pos);
  }
  } 
  catch(Exception e) {
    println("ERROR");
    System.out.println(e);
  }

}
//
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
