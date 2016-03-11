/**********************************************************************************************************
* Project: MatrixArrayVisualizer.pde
* By: Chris Wittmier @ Sensitronics LLC
* LastRev: 04/22/2014
* Description: Graphic visualizer for MatrixArray demo / tutorial. Draws a colored grid to show force
* reported by 16x10 ThruMode matrix array connected to Arduino and minimal circuitry
**********************************************************************************************************/ 
import processing.serial.*;
 
 
/**********************************************************************************************************
* CONSTANTS
**********************************************************************************************************/
int SCALE_READING = 2;
int min_force_thresh = 1;
int BAUD_RATE =  9600;


/**********************************************************************************************************
* GLOBALS
**********************************************************************************************************/
float[] values;
float[] valuesFiltrated;
int fifoLength = 0;
Serial sPort;

void fifoAdd(int value, float scale, float offset, int fifoLength)
{
  for(int i = 0; i < fifoLength-1; i++)
  {
    values[fifoLength-1 - i] = values[fifoLength-2 - i];
  }
  values[0] = scale*value+offset;
}


/**********************************************************************************************************
* setup()
**********************************************************************************************************/
void setup() 
{
  background(0, 0, 0);
  stroke(255);
  
  textSize(32);
  
  int port_count = Serial.list().length;
  sPort = new Serial(this, Serial.list()[port_count - 1], BAUD_RATE);  
  println(port_count);

  size(1024, 512);
  
  fifoLength = width;
  values = new float[fifoLength];
  valuesFiltrated = new float[fifoLength];
}


/**********************************************************************************************************
* draw()
**********************************************************************************************************/
void draw() 
{
  background(0);
  rxRefresh();
  String data = str(values[0]);
  text(data, 12, 60);
  int r = 12;
  for(int i = 0; i < fifoLength-r; i++)
  {
    int sum = 0;
    for(int j = 0; j < r; j++)
      sum += values[i+j];
    valuesFiltrated[i] = sum/r;
  }
  for(int i = 1; i < fifoLength; i++)
  {
    stroke(125, 0, 0);
    line(i, height - values[i], i-1, height - values[i-1]);
    stroke(255);
    line(i, height - valuesFiltrated[i], i-1, height - valuesFiltrated[i-1]);
  }
}



/**********************************************************************************************************
* rxRefresh()
**********************************************************************************************************/
void rxRefresh() 
{
  while(sPort.available() > 0)
  {
    int value = (int) sPort.read();
    print(value);
    println();
    fifoAdd(value, 1.0, 0.0, fifoLength);
  }
}