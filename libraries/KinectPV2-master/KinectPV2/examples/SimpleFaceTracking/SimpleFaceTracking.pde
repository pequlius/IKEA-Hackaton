/*
Copyright (C) 2014  Thomas Sanchez Lengeling.
 KinectPV2, Kinect for Windows v2 library for processing
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.entity.StringEntity;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.impl.client.DefaultHttpClient;
import processing.serial.*;
import KinectPV2.*;
import cc.arduino.*;

Arduino arduino;
FaceData [] faceData;
Skeleton [] skeleton;
KinectPV2 kinect;

int minBrightness = 0;
int maxBrightness=100;
int hueColour=50000;
String url;


void setup() {
  size(1920, 1080, P2D);
  url = "http://192.168.0.2/api/webuser123/lights/1/state";
  hueColour=0;
  kinect = new KinectPV2(this);
  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.enableFaceDetection(true);

  kinect.init();
  
  arduino = new Arduino(this, "COM4", 57600);
  arduino.pinMode(2,Arduino.OUTPUT);
   arduino.pinMode(3,Arduino.OUTPUT);
    arduino.pinMode(4,Arduino.OUTPUT);
    arduino.pinMode(9,Arduino.OUTPUT);
}

void draw() {
  background(0);

 image(kinect.getColorImage(), 0, 0, width, height);
 // image(kinect.getColorImage(), 0, 0);

  faceData =  kinect.getFaceData();
  
  
  skeleton =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      
      KJoint[] joints = skeleton[i].getJoints();

      color col  = getIndexColor(i);
     
      fill(col);
      stroke(col);
     drawBody(joints);
     posHead(joints);
      
      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight],KinectPV2.JointType_HandRight);
      drawHandState(joints[KinectPV2.JointType_HandLeft],KinectPV2.JointType_HandLeft);
      }
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);

  for (int i = 0; i < faceData.length; i++) {
    if (faceData[i].isFaceTracked()) {
         
      PVector [] facePointsColor = faceData[i].getFacePointsColorMap();

      Rectangle rectFace = faceData[i].getBoundingRect();

      FaceFeatures [] faceFeatures = faceData[i].getFaceFeatures();

      PVector nosePos = new PVector();
      noStroke();

      color col = getIndexColor(i);

      fill(col);   
      for (int j = 0; j < facePointsColor.length; j++) {
        if (j == KinectPV2.Face_Nose)
          nosePos.set(facePointsColor[j].x, facePointsColor[j].y);

        ellipse(facePointsColor[j].x, facePointsColor[j].y, 15, 15);
      }

      if (nosePos.x != 0 && nosePos.y != 0)
        for (int j = 0; j < 8; j++) {
          int st   = faceFeatures[j].getState();
          int type = faceFeatures[j].getFeatureType();
          String str2="WearingGlasses: Yes";
          String str = getStateTypeAsString(st, type);
          if(str.equals(str2)==true)
          {
            println(st);
            println(str2);
            arduino.analogWrite(2,150);
            arduino.analogWrite(3,50);
            arduino.analogWrite(4,20);
          }
          else
          {
             arduino.analogWrite(2,0);
            arduino.analogWrite(3,0);
            arduino.analogWrite(4,255); 
          }
          

          fill(255);
          text(str, nosePos.x + 150, nosePos.y - 70 + j*25);
        }
      stroke(255, 0, 0);
      noFill();
      rect(rectFace.getX(), rectFace.getY(), rectFace.getWidth(), rectFace.getHeight());
    }
    
  }
}


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


String getStateTypeAsString(int state, int type) {
  String  str ="";
  switch(type) {
  case KinectPV2.FaceProperty_Happy:
    str = "Happy";
   // changeLight(maxBrightness,50000);
    break;

  case KinectPV2.FaceProperty_Engaged:
    str = "Engaged";
    break;

  case KinectPV2.FaceProperty_LeftEyeClosed:
    str = "LeftEyeClosed";
   
    break;

  case KinectPV2.FaceProperty_RightEyeClosed:
    str = "RightEyeClosed";
    
    break;

  case KinectPV2.FaceProperty_LookingAway:
    str = "LookingAway";
    
    break;

  case KinectPV2.FaceProperty_MouthMoved:
    str = "MouthMoved";
    break;

  case KinectPV2.FaceProperty_MouthOpen:
    str = "MouthOpen";
    break;

  case KinectPV2.FaceProperty_WearingGlasses:
    str = "WearingGlasses";
    
    break;
  }

  switch(state) {
  case KinectPV2.DetectionResult_Unknown:
    str += ": Unknown";
    break;
  case KinectPV2.DetectionResult_Yes:
    str += ": Yes";
    break;  
  case KinectPV2.DetectionResult_No:
    str += ": No";
    break;
  }

  return str;
}




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
    changeLight(100, 50000,200);
    
     
  }
  else if(jointType==KinectPV2.JointType_HandLeft && joint.getState()==KinectPV2.HandState_Closed)
  {
     fill(0, 255, 0);
    //println(handState);
    textSize(50);
    text("Left Hand Closd", 100, 600); 
    fill(0, 102, 153);
   changeLight(100, 50000,0);
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
   // handS=1;
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    //println(handState);
    textSize(50);
    text("CLOSE", 100, 300); 
    fill(0, 102, 153);
   // handS=2;
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    textSize(50);
    text("Lasso/Scissors", 100, 300); 
    fill(0, 102, 153);
    //handS=4;
    //handS=3;
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    textSize(50);
    text("Not Tracked", 100, 300); 
    fill(0, 102, 153);
    //handS=4;
    break;
  }
 
  
}


void posHead(KJoint[] joints)
{
   if( joints[KinectPV2.JointType_WristRight].getY()< joints[KinectPV2.JointType_SpineShoulder].getY())
  {
    textSize(50);
    text(" Right Hand Above Head", 400, 300); 
    fill(0, 100, 100);
    changeLight(100, 50000,255);
    int newPos = constrain(int(joints[KinectPV2.JointType_WristRight].getY())/2,0,180);
     arduino.servoWrite(9,newPos);
//         arduino.analogWrite(pinLED[0],150);//Green
//        arduino.analogWrite(pinLED[1],100);//RED
//         arduino.analogWrite(pinLED[2],150);//BLUE
//         arduino.analogWrite(pinLED[0],150);//Green
//        arduino.analogWrite(pinLED[1],100);//RED
//         arduino.analogWrite(pinLED[2],150);//BLUE
   
  }
  
  else if( joints[KinectPV2.JointType_WristLeft].getY()< joints[KinectPV2.JointType_SpineShoulder].getY())
  {
    textSize(50);
    text(" Left Hand Above Head", 400, 100); 
    fill(0, 0, 0);
     
//    arduino.analogWrite(pinLED[0],200);
//      arduino.analogWrite(pinLED[1],200);
//       arduino.analogWrite(pinLED[2],50);
//       arduino.analogWrite(pinLED[3],200);
//      arduino.analogWrite(pinLED[4],200);
//       arduino.analogWrite(pinLED[5],50);
    
  }
  else if( joints[KinectPV2.JointType_WristLeft].getY() > joints[KinectPV2.JointType_ShoulderLeft].getY())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 400); 
    fill(0, 0, 0);
     changeLight(0, 50000,255);
     arduino.servoWrite(9,0);
//    arduino.analogWrite(pinLED[0],0);
//      arduino.analogWrite(pinLED[1],255);
//       arduino.analogWrite(pinLED[2],0);
//        arduino.analogWrite(pinLED[3],0);
//      arduino.analogWrite(pinLED[4],255);
//       arduino.analogWrite(pinLED[5],0);
  }
   else if( joints[KinectPV2.JointType_WristRight].getY() > joints[KinectPV2.JointType_ShoulderRight].getY())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 500); 
    fill(0, 0, 0);
   
//    arduino.analogWrite(pinLED[0],0);
//      arduino.analogWrite(pinLED[1],0);
//       arduino.analogWrite(pinLED[2],255);
//        arduino.analogWrite(pinLED[3],0);
//      arduino.analogWrite(pinLED[4],0);
//       arduino.analogWrite(pinLED[5],255);
  }
 else if( joints[KinectPV2.JointType_WristLeft].getZ() == joints[KinectPV2.JointType_ShoulderLeft].getZ())
  {
    textSize(50);
    text(" wrist below shoulder", 400, 600); 
    fill(0, 0, 0);
//    arduino.analogWrite(pinLED[0],255);
//      arduino.analogWrite(pinLED[1],0);
//       arduino.analogWrite(pinLED[2],0);
  }
   else if( joints[KinectPV2.JointType_WristRight].getZ() == joints[KinectPV2.JointType_ShoulderRight].getZ())
  {
    textSize(50);
    text(" wrist equal shoulder", 400, 700); 
    fill(0, 0, 0);
//    arduino.analogWrite(pinLED[0],255);
//      arduino.analogWrite(pinLED[1],0);
//       arduino.analogWrite(pinLED[2],0);
//        arduino.analogWrite(pinLED[5],0);
//      arduino.analogWrite(pinLED[4],0);
//       arduino.analogWrite(pinLED[3],255);
  }   
}



public void changeLight(int brightness, int hColour,int saturation) {
  
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
    data += "\"sat\" :";
    data += saturation;
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
