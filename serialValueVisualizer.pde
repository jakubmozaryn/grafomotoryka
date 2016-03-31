
import processing.serial.*;


Serial myPort;        // The serial port
//global variables
int xPos=1; 
int xPos_1=1;
float yPos=1;
float yPos_1=1;
float[] values;
float[] valuesFiltrated;
int fifoLength = 0;
//---
int d = day();    // Values from 1 - 31
int mon = month();  // Values from 1 - 12
int y = year();   // 2003, 2004, 2005, etc.
//---
int s = second();  // Values from 0 - 59
int min = minute();  // Values from 0 - 59
int h = hour();    // Values from 0 - 23
//---
int mil=0;
//--- 
String saveDate="0";
String saveTime="0";

// horizontal position of the graph
float inByte = 0;

//start saving data
boolean startSave = false;
//stop saving data
boolean stopSave = false;
//set file name
boolean setFileName=false;

//file to save data
PrintWriter output;

void fifoAdd(float value, float scale, float offset, int fifoLength)
{
  for(int i = 0; i < fifoLength-1; i++)
  {
    values[fifoLength-1 - i] = values[fifoLength-2 - i];
  }
  values[0] = scale*value+offset;
};


void setup () {
  // set the window size:
  size(500, 300);
  textSize(32);

  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 9600);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // set inital background:
  background(0);
  
  //set fifo
  fifoLength = width;
  values = new float[fifoLength];
  valuesFiltrated = new float[fifoLength];
  
  // Create a new file in the sketch directory
  //saveDate=str(d)+"."+str(d)+"."+str(mon);
  //saveTime=str(h)+"."+str(min)+"."+String.valueOf(s);
  //output = createWriter(saveDate+"_"+saveTime+"_"+"force.txt"); 
}

void draw () {
  background(0);
  stroke(127, 34, 255);
  textSize(14);
  String data = str(stopSave);
  //Write the force value on the screen
  if (startSave==true){
      if(setFileName==true){
      // Create a new file in the sketch directory
      d = day();    // Values from 1 - 31
      mon = month();  // Values from 1 - 12
      y = year();   // 2003, 2004, 2005, etc.
//---
      s = second();  // Values from 0 - 59
      min = minute();  // Values from 0 - 59
      h = hour();    // Values from 0 - 23
       // Create a new file in the sketch directory
      saveDate=str(d)+"."+str(d)+"."+str(mon);
      saveTime=str(h)+"."+str(min)+"."+String.valueOf(s);
      output = createWriter(saveDate+"_"+saveTime+"_"+"force.txt");
      };
      text("dane sa zapisywane (nacisnij 'q' aby zakonczyc zapisywanie)", 12, 40);
      text("nazwa pliku:"+saveDate+"_"+saveTime+"_"+"force.txt", 12, 65);
      setFileName=false;
  };
  
  if(startSave==false){
  text("dane nie są zapisywane (nacisnij 's' aby rozpoczac zapisywanie)", 12, 40);
  };
  
  // Write the force value to the file

   int r = 8;
  for(int i = 0; i < fifoLength-r; i++)
  {
    int sum = 0;
    for(int j = 0; j < r; j++)
      sum += values[i+j];
    valuesFiltrated[i] = sum/r;
  };
  for(int i = 1; i < fifoLength; i++)
  {
    stroke(125, 0, 0);
    line(i, height - values[i], i-1, height - values[i-1]);
    stroke(255);
    line(i, height - valuesFiltrated[i], i-1, height - valuesFiltrated[i-1]);
  };
}


void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // convert to an int and map to the screen height:
    inByte = float(inString);
    println(inByte);
    inByte = map(inByte, 0, 1023, 0, height);
    fifoAdd(inByte, 1.0, 0.0, fifoLength);
    
    //save raw data into file
    if (startSave!=false){ 
     String millisVal=str(millis());
     output.println(millisVal+";"+inByte);
    };
  }
}


/**********************************************************************************************************
* rxRefresh()
**********************************************************************************************************/
void rxRefresh() 
{
  while(myPort.available() > 0)
  {
    int value = (int) myPort.read();
    print(value);
    println();
    fifoAdd(value, 1.0, 0.0, fifoLength);
  }
}


/**********************************************************************************************************
* keyPressed() - exit application after pressing the key
**********************************************************************************************************/
void keyPressed() {
  // Writes the remaining data to the file
  if (key == 's' || key == 'S'){
  startSave=true;
  stopSave=false;
  setFileName=true;
  };
  if (key == 'q' || key == 'Q'){
  startSave=false;
  stopSave=true;
  setFileName=false;
  }
  if (stopSave==true){
    output.flush();  
    // Finishes the file 
    output.close();
    //exit();
  };
}