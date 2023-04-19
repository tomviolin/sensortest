
import websockets.*;

import ketai.camera.*;
import ketai.cv.facedetector.*;
import ketai.data.*;
import ketai.net.*;
import ketai.net.bluetooth.*;
import ketai.net.nfc.*;
import ketai.net.nfc.record.*;
import ketai.net.wifidirect.*;
import ketai.sensors.*;
import ketai.ui.*;
import android.os.VibratorManager;
import android.os.Vibrator;
import android.os.VibrationEffect;
import android.app.Activity;
import android.content.Context;

import android.hardware.SensorManager;

WebsocketClient wsc;

KetaiSensor sensor;

int fr = 50;
int c=0;
int lastc = 0;
VibratorManager vibman;
Vibrator vib;
long[] timings; //= new long[64];// { 20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20};
int[] amplitudes; //= new int[64];// { 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0 };

void setup(){
  fullScreen(JAVA2D);

  frameRate(fr);
  background(0);
  stroke(255,255,255);
  //strokeWeight(5);
  sensor = new KetaiSensor(this);
  sensor.setSamplingRate(android.hardware.SensorManager.SENSOR_DELAY_FASTEST);
  sensor.start();
  VibrationEffect g;
  //int d=
  //long[] timings = new long[] { 50,50,50,50,50,50,50,50,50,50,50,50,50 };
  //int[] amplitudes = new int[] { 0,1,1,1,1,0,0,0,1,0,0,0,0 };
  //vib.vibrate(pattern,1);
  Activity activity = getActivity();
  Context context = getContext();
  VibratorManager vibman = (VibratorManager) context.getSystemService(context.VIBRATOR_MANAGER_SERVICE);
  vib=vibman.getDefaultVibrator();
  timings = new long[200];
  amplitudes = new int[200];
  for (int i = 0; i < 50; ++i) {
    timings[i]=20;
    amplitudes[i]=0;
  }
  for ( int i = 0; i < 50; i+=50 ) {
    for (int j = 0; j < 5; ++j){
      amplitudes[i+j]=1;
    }
    for (int j = 45; j < 50; ++j) {
      amplitudes[i+j] = 1;
    }
  }
  //  else
  //  vib.vibrate(500);
  try {
    wsc = new WebsocketClient(this, "ws://10.7.76.131:5000/");
  } catch(Exception e) {
    println("*** ERROR'"+e+"' CAUGHT!***");
    e.printStackTrace();
    println("after error.");
  }
}
boolean done=false;
long lastframemillis=0;


long nextvibmillis=-10000;
long lastvibmillis=-10000;

float sensorRecord[] = new float[50];
float sensorMin[] = new float[50];
float sensorMax[] = new float[50];
float sensorDetail[] = new float[500];
int detailCount = 0;

void draw(){
  long thisframemillis=millis();
  System.out.print(thisframemillis-lastframemillis);
  System.out.print(" ");
  lastframemillis=thisframemillis;
  //line(0,c,width-1,c);
  if (lastc > 0) {
    print(c-lastc);
  }
  lastc = c;
  
  long thisvibmillis = millis();
  if (nextvibmillis < -9999) {
    nextvibmillis = thisvibmillis;
  }
  if (true || thisvibmillis >= nextvibmillis) {
    // transmit sensor data
    String json = "{\"data\":[";
    for (int i = 0; i < 50; ++i) {
      if (i > 0) json += ",";
      json += "[" + sensorRecord[i] + "," + sensorMin[i]+","+sensorMax[i]+"]";
    }
    json += "],\"timestamp\":"+thisvibmillis+"}";
    if (wsc != null)
      wsc.sendMessage(json);
      
    // new vib restart
    stroke(255,255,0,160);
    line(0,c,width-1,c);
    for ( int i = 0; i < 50; ++i) {
      amplitudes[i] = 0;
    }
    for ( int k = 0; k < 50; ++k ){
      amplitudes[int(random(50))]=1;
    }
    vib.vibrate(VibrationEffect.createWaveform(timings,amplitudes,0));
    nextvibmillis += 20;
    lastvibmillis = thisvibmillis;
  }
  long millisintovib = thisvibmillis-lastvibmillis;
  point(millisintovib,c);
  if (amplitudes[int(millisintovib/20)]>0){
    stroke(0,255,0);
    strokeWeight(10);
    point(width/2,c);
    stroke(255);
    strokeWeight(1);
  }
  sensorRecord[int(millisintovib/20)] = mean(sensorDetail, detailCount);
  sensorMin[int(millisintovib/20)] = min(sensorDetail, detailCount);
  sensorMax[int(millisintovib/20)] = max(sensorDetail, detailCount);
  detailCount = 0;
  stroke(255,128,0);
  strokeWeight(4);
  point(width/2 + sensorRecord[int(millisintovib/20)]*500,c);
  stroke(255);
  strokeWeight(1);
  System.out.println("");
}
int lastmillis=millis();
float kr = 1; // kalman ratio
float kv=-10000.0;

void onGyroscopeEvent(float gyro_x, float gyro_y, float gyro_z) {
  if (kr < 20) kr += 0.2;
  if (c==0) {
    background(0);
    clear();
    background(0);
  }
  float krr = 1.0/kr;
  if (kv < -9999.0) kv=gyro_z-10.;
  kv = kv * (1.0-krr) + (gyro_z) * krr;
  int center_x = int(width / 2);
  //int center_y = int(height / 2);
  //int sqsize = min(width,height);
  
  int xcx = int(width/2+(gyro_z-kv) * 500); //int(gyro_x*1000);
  //int xcy = center_x+int(gyro_y*5000);
  //int xcz = int(sqrt(abs(gyro_z))*500);
 
  int thismillis = millis();
  //int xm = millis()-lastmillis;
  lastmillis = thismillis;
  stroke(255,255,255);
  point(xcx,c);
  sensorDetail[detailCount++] = gyro_z-kv;
  /*
  stroke(0,255,0);
  point(xcy%width,c%height);

  stroke(0,128,255);
  point(xcz%width,c%height);

  stroke(255,255,255);
  point(xm,c%height);

  //stroke(255,128,0);
  //point(xckx%width,c%height);
  
  //stroke(0,255,0);
  //point(xcky%width,c%height);
  
  //stroke(0,128,255);
  //point(xckz%width,c%height);
    
  text(xm,center_x,center_y);
  */
  c++;
  c=c%height;
}

float mean(float[] x, int n) {
  float total=0;
  for (int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total / float(n);
}

float min(float[] x, int n) {
  float minv=1e9;
  for (int i = 0; i < n; ++i) {
    minv = min(minv,x[i]);
  }
  return minv;
}
float max(float[] x, int n) {
  float maxv=-1e9;
  for (int i = 0; i < n; ++i) {
    maxv = max(maxv,x[i]);
  }
  return maxv;
}
