import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import com.phidgets.*;
import com.phidgets.event.*;


InterfaceKitPhidget ik;
Minim minim;
AudioSample heartbeat1, heartbeat2, heartbeat3, inhale, exhale;

// swap these labels for the actual sensors you have
float heartBeatSensor;
float heartBeatSensor2;
float heartBeatSensor3;
float breathingInSensor;
float breathingOutSensor;
float pulseSensor;


void setup()
{
size(400,300);
setupIK();
minim = new Minim(this);

// load sounds from the data folder
heartbeat1 = minim.loadSample("heartbeat1.wav");
heartbeat2 = minim.loadSample("heartbeat2.wav");
heartbeat3 = minim.loadSample("heartbeat3.wav");
inhale = minim.loadSample("inhale.wav");
exhale = minim.loadSample("exhale.wav");

smooth();
}

void draw()
{
// the main interfaces for data input / output
readIK();
System.out.println(heartBeatSensor + " " + pulseSensor);
if (heartBeatSensor < 500.0) {
  heartbeat2.trigger();
  }
  
 float bpm = map (pulseSensor,0,1000,50,110);
 float dt = 60000/bpm;
 delay((int)dt);

}

void setupIK()
{
try
{
ik = new InterfaceKitPhidget();
ik.openAny();
println("Waiting for Phidget");
ik.waitForAttachment();
println("OK ready to go");
}
catch(Exception e)
{
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

heartBeatSensor = (float)ik.getSensorValue(0);
heartBeatSensor2 = (float)ik.getSensorValue(1);
heartBeatSensor3 = (float)ik.getSensorValue(2);
breathingInSensor = (float)ik.getSensorValue(3);
breathingOutSensor = (float)ik.getSensorValue(4);
pulseSensor = (float)ik.getSensorValue(7);
//    light = (float)ik.getSensorValue(1);
//    hum = (float)ik.getSensorValue(2);
//    temp = (float)ik.getSensorValue(3);
}
catch (Exception e)
{
println(e.toString());
}
}
