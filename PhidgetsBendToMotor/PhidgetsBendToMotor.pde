import com.phidgets.*;
import com.phidgets.event.*;
import processing.serial.*;

// phidgets java API: http://www.phidgets.com/documentation/web/javadoc/


//Sevo controller:
AdvancedServoPhidget sp;

//Phidgets Interface Kit
InterfaceKitPhidget ik;

double pos;
int bendSensor;
static final int bendMax = 470;
static final int bendMin = 120;
boolean ENGAGED = false;

void setup() {
  //frameRate(20);
  size(400, 300);
  try {
    // Create & Assign the Interface Kit phidget
    ik = new InterfaceKitPhidget();
    ik.openAny();    
    println("Waiting for Interface Kit");
    ik.waitForAttachment();
    // if you do not see this below in the console, your phidget interface board is not connected 
    println("Interface kit with bend sensor ready to go");
    // Create & Assign the servophidget
    sp = new AdvancedServoPhidget();
    sp.openAny();
    println("Waiting for servo phidget");
    sp.waitForAttachment();
    // if you do not see this below in the console, your phidget is not connected 
    println("servo ready to go");
    sp.setEngaged(0, true);    
  } 
  catch(Exception e) {
    println("ERROR - exception called");
    System.out.println(e);
  }
  
}

void draw() {
  background(200);
    try {
   readIK();
  // calculate tilt from accelerometer data

  // translate the bend value to range between the max and min values of the servo
  pos = map(bendSensor, bendMin, bendMax, (int)sp.getPositionMin(0), (int)sp.getPositionMax(0));

    //set the position of the servo
    sp.setPosition(0, pos);
  
  } 
  catch(Exception e) {
    println("ERROR");
    System.out.println(e);
  }

}
void readIK()
{
try
{
// the ports are considered an array, with 8 ports in total
// the first port is array number 1, but it is addressed as port 0
// since it is 0 elements away from the start of the array.

bendSensor = ik.getSensorValue(0);

}
catch (Exception e)
{
println(e.toString());
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
