#include <RxSoftwareSerial.h>

// cURL -X PUT -d '{"on":false}' http://(your hub's address)/api/(your hash)/lights/(light number)
// url = "http://193.10.67.238/api/webuser123/lights/2/state";
// curl -X PUT -d '{"on":true, "hue":0, "bri":255, "transitiontime":10}' http://193.10.67.238/api/webuser123/lights/2/state


/*
  Maxbotix simple test

  Instructions:
  - At least one of: (comment the appropriate code below)
    * PW is digital pin 8
    * TX is digital pin 6
    * AN is analog pin A0
  - Change code below according to your model (LV, XL and
  HRLV supported)

  Note:
  For convenience, the getRange method will always return centimeters.
  You can use convert fuctions to convert to another unit (toInches and
  toCentimeters are available)

*/
#include "Maxbotix.h"
#include "RunningMedian.h"
//#include <Process.h>

int pin[]={9,10,11};
const int hue = 0; //65535;
const int minBrightness = 0;
const int maxBrightness = 80; //100;
const int transitiontime = 15; //15;
//command string to send the http request to the hue bridge
const String curlcommand_1 = "curl -X PUT -d '{\"on\":true, \"hue\":";
const String curlcommand_2 = ", \"bri\":";
const String curlcommand_3 = ", \"transitiontime\":";
const String curlcommand_4 = "}' http://192.168.0.2/api/webuser123/lights/2/state";
const String lightOnCommand = curlcommand_1 + hue + curlcommand_2 + maxBrightness + curlcommand_3 + transitiontime + curlcommand_4;
const String lightOffCommand = curlcommand_1 + hue + curlcommand_2 + minBrightness + curlcommand_3 + transitiontime + curlcommand_4;

//array length for running mean calculation
//const int numReadings = 20;
const int BREATHING_IN = 0;
const int BREATHING_OUT =1;
const int NO_BREATHING = 2;
int breathingStatus = NO_BREATHING;

//Length of array for calculating curve slope
const int slopeArray = 8;
//Array for calculating mean value 
RunningMedian slope = RunningMedian(slopeArray);
//Threshold for curve slope
const float slopeThresh = 0.04;
//minimum time between inhale and exhale to avoid noise
unsigned long minBreathingRate = 800;
unsigned long breathingTimestamp = 0;
//Length of array for estimating min and max estimated at approximately 6 sec
const int maxminArrayLenth = 60;
//how many cycles inbetween calculation of man and min
const int maxminCalcRate = 30;
//Array for estimating max and min values
RunningMedian maxminArray = RunningMedian(maxminArrayLenth);
int maxminIndex = 0;
float maxVal = 0;
float minVal = 0;

float oldVal=0;
Maxbotix rangeSensorTX(8, Maxbotix::TX, Maxbotix::HRLV);

void setup()
{
  //Bridge.begin();
  Serial.begin(9600);
  breathingTimestamp = millis();
  Serial.println("started");
}

void loop()
{
  //Process p;
  unsigned long start;
 
  start = millis();
  float currentVal = rangeSensorTX.getRange();//*25.4;
  //Serial.println(currentVal);
  maxminArray.add(currentVal);
  
  //Add the difference between old and new reading. If breathing in the new reading should be smaller than the old, thus negative reading
  slope.add(currentVal-oldVal);
  //if(currentVal > oldVal) {slope.add(1)} 
  //  else if (currentVal == oldVal) {slope.add(0)} 
  //  else if (currentVal < oldVal) {slope.add(-1)}
  float s = slope.getAverage();
  unsigned long dt = millis()-breathingTimestamp;
  if (s > slopeThresh && (dt > minBreathingRate) && (breathingStatus != BREATHING_OUT)) {
    breathingStatus = BREATHING_OUT;
    Serial.println("out");   
    analogWrite(9,100);
    //p.runShellCommandAsynchronously(lightOffCommand);
//    Serial.println("breathing out, breathing time: ");
//    Serial.println(dt);
    breathingTimestamp=millis();
//    digitalWrite(11,LOW);
//    delay(100);
//    analogWrite(10,255);
  } else if (s < -slopeThresh && (dt > minBreathingRate) && (breathingStatus != BREATHING_IN)) {
    breathingStatus = BREATHING_IN; 
    Serial.println("in");
    analogWrite(9,255);
    //p.runShellCommandAsynchronously(lightOnCommand); 
//    Serial.print("breathing in, breathing time: ");
//    Serial.println(dt);
    breathingTimestamp=millis();
//    analogWrite(11,255);
//    delay(100);
//    digitalWrite(10,LOW);
    } //else if ((s <= slopeThresh) && (s >= -slopeThresh)) {breathingStatus = NO_BREATHING;}  
  
  //check for max and min values
  if (maxminIndex == maxminCalcRate) {
    minVal=maxminArray.getLowest();
    maxVal=maxminArray.getHighest();
    maxminIndex=0;
    Serial.print("Min: ");
    Serial.print(minVal);
    Serial.print("Max: ");
    Serial.println(maxVal);       
  }
  maxminIndex++;
  
//  if()
  
  //Serial.print(currentVal);
  //Serial.print(" slope coeff: ");
  //Serial.print(s);
  //Serial.print(" breathing status: " + breathingStatus);
  //float m = samples.getMedian();
  //Serial.print(" median: ");
  //Serial.print(m);
  
  //Serial.print(" readtime: ");
  //Serial.print(millis() - start);
  //Serial.println("ms"); 
  oldVal = currentVal;
  delay(1);
}
