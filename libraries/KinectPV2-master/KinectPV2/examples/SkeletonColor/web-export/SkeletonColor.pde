

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.entity.StringEntity;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.impl.client.DefaultHttpClient;

import KinectPV2.KJoint;
import KinectPV2.*;
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;

KinectPV2 kinect;

Skeleton [] skeleton;
 KJoint[] joints;

PVector v1,v2,v3,v4,v5;

String colHue="colorloop";

int minBrightness = 0;
int maxBrightness = 255; 
String url;
int hueColour = 0;
int handS;
int pinLED[]={3,5,6,9,10,11};  

void setup() {
  
   
   size(1920, 1080,P3D);
   url = "http://192.168.0.2/api/webuser123/lights/1/state";
   //frameRate(50);
   hueColour=0;

  kinect = new KinectPV2(this);
  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  
  kinect.init();
  
   
  println(Arduino.list());
  
  arduino = new Arduino(this, "COM4", 57600);
  arduino.pinMode(9,Arduino.OUTPUT);
}



//use different color for each skeleton tracked
color getIndexColor(int index) {
  color col = color(255);
  if (index == 0)
    col = color(255, 0, 0);
  if (index == 1)
    col = color(0, 255, 0);
  if (index == 2)
    col = color(0, 0, 255);
  if (index == 3)
    col = color(255, 255, 0);
  if (index == 4)
    col = color(0, 255, 255);
  if (index == 5)
    col = color(255, 0, 255);

  return col;
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  
  
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  
  // Right Arm  
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
  


  
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint joint, int jointType) {
  noStroke();
  handState(joint.getState());
  if(jointType==KinectPV2.JointType_HandRight && joint.getState()==KinectPV2.HandState_Closed)
  {
    fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("Right Hand Closd", 100, 500); 
    fill(0, 102, 153);
   // changeLight(100, 50000,200);
    
     
  }
  else if(jointType==KinectPV2.JointType_HandLeft && joint.getState()==KinectPV2.HandState_Closed)
  {
     fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("Left Hand Closd", 100, 600); 
    fill(0, 102, 153);
   //changeLight(100, 50000,0);
    //changeLight(255, 25000);
  }
  else if(jointType==KinectPV2.JointType_HandRight && jointType==KinectPV2.JointType_HandLeft && joint.getState()==KinectPV2.HandState_Closed)
   {
     fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("Both Hands Closd", 100, 700); 
    fill(0, 102, 153);
    
  }
  else 
  {
    fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("Both Hands Open", 100, 800); 
    fill(0, 102, 153);
    
  }
  
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}



/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
 
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("OPEN", 100, 300); 
    fill(0, 102, 153);
    handS=1;
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    //println(handState);
    textSize(50);
    text("CLOSE", 100, 300); 
    fill(0, 102, 153);
    handS=2;
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    textSize(50);
    text("Lasso/Scissors", 100, 300); 
    fill(0, 102, 153);
    handS=4;
    handS=3;
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    textSize(50);
    text("Not Tracked", 100, 300); 
    fill(0, 102, 153);
    handS=4;
    break;
  }
 
  
}



void draw() {
  background(0);

  image(kinect.getColorImage(), 0, 0, width, height);

  skeleton =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      KJoint[] joints = skeleton[i].getJoints();
      KJoint[] joint1=skeleton[0].getJoints();
      
      //color col=getIndexColor(0);
      color col  = getIndexColor(0);
     
      fill(col);
      stroke(col);
     drawBody(joint1);
     posHead(joint1);
      
      //draw different color for each hand state
      drawHandState(joint1[KinectPV2.JointType_HandRight],KinectPV2.JointType_HandRight);
      drawHandState(joints[KinectPV2.JointType_HandLeft],KinectPV2.JointType_HandLeft);
      
      float x1=joint1[KinectPV2.JointType_ShoulderRight].getX();
      float x2=joint1[KinectPV2.JointType_ShoulderRight].getY();
      float x3=joint1[KinectPV2.JointType_ShoulderRight].getZ();
      float x4=joint1[KinectPV2.JointType_SpineMid].getX();
      float x5=joint1[KinectPV2.JointType_SpineMid].getY();
      float x6=joint1[KinectPV2.JointType_SpineMid].getX();
      float x7=joint1[KinectPV2.JointType_ElbowRight].getX();
      float x8=joint1[KinectPV2.JointType_ElbowRight].getY();
      float x9=joint1[KinectPV2.JointType_ElbowRight].getZ();
      v1=new PVector(x1,x2);
      v2=new PVector(x4,x5);
      v3=new PVector(x7,x8);
      PVector v4 = PVector.sub(v2, v1);
      PVector v5 = PVector.sub(v3, v1);
       float angle = PVector.angleBetween(v5, v4);
      println(round(degrees(angle)));
      fill(255, 0, 0);
      text(round(degrees(angle)), 50, 100);
      
      
      // newPos=round(degrees(angle)));
      //println(newPos);
      
      //int newPos = constrain(int(joints[KinectPV2.JointType_WristRight].getY())/2,0,170);
      arduino.servoWrite(9,(180-round(degrees(angle))));
      
      
//      println("Right:");
//      println(joints[KinectPV2.JointType_WristRight].getY());
//      println("LEFT:");
//      println(joints[KinectPV2.JointType_ShoulderRight].getY());
      
      }
  }
 

  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

void posHead(KJoint[] joints)
{
   if( joints[KinectPV2.JointType_WristRight].getY()< joints[KinectPV2.JointType_SpineShoulder].getY())
  {
    textSize(50);
    text(" Right Hand Above Head", 400, 300); 
    fill(0, 100, 100);
    changeLight(100, 50000 );   
  }
  
  else if( joints[KinectPV2.JointType_WristLeft].getY()< joints[KinectPV2.JointType_SpineShoulder].getY())
  {
    textSize(50);
    text(" Left Hand Above Head", 400, 100); 
    fill(0, 0, 0);
    
  }
  else if( joints[KinectPV2.JointType_WristLeft].getY() > joints[KinectPV2.JointType_ShoulderLeft].getY())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 400); 
    fill(0, 0, 0);
    
      
  }
   else if( joints[KinectPV2.JointType_WristRight].getY() > joints[KinectPV2.JointType_ShoulderRight].getY())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 500); 
    fill(0, 0, 0);
    changeLight(0, 50000);   

  }
 else if( joints[KinectPV2.JointType_WristLeft].getZ() == joints[KinectPV2.JointType_ShoulderLeft].getZ())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 600); 
    fill(0, 0, 0);

  }
   else if( joints[KinectPV2.JointType_WristRight].getZ() == joints[KinectPV2.JointType_ShoulderRight].getZ())
  {
    textSize(50);
    text(" wrist equal shoulder", 400, 700); 
    fill(0, 0, 0);

  }   
}

public void changeLight(int brightness, int hColour) {
  
  hueColour = hColour;

  try
  {
    DefaultHttpClient httpClient = new DefaultHttpClient();
    HttpPut httpPut = new HttpPut(url);

   String data = "{";
    data += "\"on\": true";
    data += ",";
    data += "\"hue\" :";
    data += hueColour;
    data += ",";
    data += "\"bri\" :";
    data += brightness;
    data += ",";
    data += "\"transitiontime\" : 15";
    data += "}";

   

    //with post requests you can use setParameters, however this is
    //the only way the put request works with the JSON parameters

    StringEntity se = new StringEntity(data);
    httpPut.setEntity(se);
    println( "executing request: " + httpPut.getRequestLine() );
    HttpResponse response = httpClient.execute(httpPut);
    HttpEntity entity = response.getEntity();
    println("————————————————————");
    println( response.getStatusLine() );
    println("————————————————————");
    if (entity != null) entity.writeTo( System.out );
    if (entity != null) entity.consumeContent();
    // when HttpClient instance is no longer needed, 
    // shut down the connection manager to ensure
    // immediate deallocation of all system resources
    httpClient.getConnectionManager().shutdown();
  } 
  catch( Exception e ) { 
    e.printStackTrace();
  }
}



