
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
  for (int i = 0; i < 200; ++i) {
    timings[i]=5;
    amplitudes[i]=0;
  }
  for ( int i = 50; i < 200; i+=200 ) {
    for (int j = 0; j < 30; ++j){
      amplitudes[i+j]=1;
    }
  }
  //  else
  //  vib.vibrate(500);
}
boolean done=false;
long lastframemillis=0;


long nextvibmillis=-10000;
long lastvibmillis=-10000;
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
  if (thisvibmillis >= nextvibmillis) {
    // new vib restart
    line(0,c,width-1,c);
    vib.vibrate(VibrationEffect.createWaveform(timings,amplitudes,0));
    nextvibmillis += 1000;
    lastvibmillis = thisvibmillis;
  }
  long millisintovib = thisvibmillis-lastvibmillis;
  point(millisintovib,c);
  if (amplitudes[int(millisintovib/5)]>0){
    point(width/3,c);
  }
  System.out.println("");
}
int lastmillis=millis();
float kr = 1; // kalman ratio
float kv=-10000.0;

void onGyroscopeEvent(float gyro_x, float gyro_y, float gyro_z) {
  if (kr < 200) kr += 0.2;
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
