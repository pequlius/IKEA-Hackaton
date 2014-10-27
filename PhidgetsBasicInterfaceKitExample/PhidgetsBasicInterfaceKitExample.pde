import com.phidgets.*;
import com.phidgets.event.*;

InterfaceKitPhidget ik;

// swap these labels for the actual sensors you have
float mot;
float temp;
float hum;
float light;
int xPos;

void setup()
{
size(400,300);
setupIK();
smooth();
}

void draw()
{
// the main interfaces for data input / output
readIK();

// clear the previous frame, draw a new background of greyscale value 200
background(200);

// draw the sensor input data
mot = map (mot,0,1000,0,height);
fill(255,0,0);
noStroke();
ellipse(xPos,(height-mot),10,10);

// this controls the graph position onscreen, it animates the graph and refreshes to the 0 position when the graph goes offscreen
if (xPos >= width)
{
xPos = 0;
}
else {
xPos++;
}
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

// make sure your 'motion' sensor is located at sensor port 1 (number 0)
// and your 'light' sensor is at sensor port 2 (number 1)

mot = (float)ik.getSensorValue(0);
//    light = (float)ik.getSensorValue(1);
//    hum = (float)ik.getSensorValue(2);
//    temp = (float)ik.getSensorValue(3);
}
catch (Exception e)
{
println(e.toString());
}
}
