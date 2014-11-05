//rgb led connected to arduino and sensor connected to interface kit 8/8/8
//load  standard firmata in arduino to start with
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
phidgetIK ik;
PFont myFont;

int pin[]={9,10,11};//pins connected arduino
int sensorVal;

void setup()
{
  // set screen size
  size( 180, 240 );
  
  // get phidget IK started and wait up to 1s for attach
  ik = new phidgetIK();
  ik.waitForAttachment();
  ik.setRatiometric( true );
  
  // set up font
  myFont = createFont("arial", 10);
  textFont(myFont);
  
  println(arduino.list());
  arduino = new Arduino(this, arduino.list()[5], 57600);// arduino connected port
  for(int i=0;i<3;i++){ arduino.pinMode(pin[i],Arduino.OUTPUT);} //RGB strip connected to arduino
  
colorMode(RGB, 255);
}

void draw()
{
  //background( 200 );
  
  // show attach status
  if ( ik.isAttached() ) fill( 0, 255, 0 );
  else fill( 255, 0, 0 );
  noStroke();
  ellipse( 20, 20, 10, 10 );

  // show serial number and version
  
  text( ik.serial(), 40, 25 );
  text( ik.version(), 40, 35 );
  
  // display analog inputs

    sensorVal=ik.getSensorValue(0);// 0,1,2 corresponds to the analog input of the phidget to which sensor is connected
    int sensorVal1=(int)map(sensorVal,120,500,0,255);
    println(sensorVal1);
    arduino.analogWrite(9,sensorVal1);
    arduino.analogWrite(10,0);
    arduino.analogWrite(11,0);  
    
    
}
