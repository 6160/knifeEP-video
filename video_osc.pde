import com.hamoid.*;

// 6160
// http://sixonesixo.com
// crappy source code for the video "Manico"
// thanks to Daniel Shiffman (http://codingrainbow.com) for teaching me this 

import peasy.*;
import oscP5.*;

PeasyCam cam;
VideoExport videoExport;
OscP5 oscP5;

PVector[][] globe;
int total = 20;

float m = 0;
float mchange = 0;
float n1change = 0;
float n2change = 0;
float n3change = 0;
float n1 = 0;
float n2 = 0;
float n3 = 0;

void setup() {
  size(1280,720, P3D);
 // uncomment this and use PeasyCam if you want
 // cam = new PeasyCam(this, 500);
  colorMode(HSB);
  globe = new PVector[total+1][total+1];
  oscP5 = new OscP5(this, 2346 );
  frameRate(25);
 //exporting video
 //videoExport = new VideoExport(this, "manico.mp4");
}

float a = 1;
float b = 1;
boolean flag_end = false;
float increment = 0.085;


float supershape(float theta, float m, float n1, float n2, float n3) {

  float t1 = abs((1/a) * cos(m*theta/4));
  t1 = pow(t1, n2);

  float t2 = abs((1/b)*sin(m * theta/4));
  t2 = pow(t2, n3);

  float t3 = t1 + t2;
  float r = pow(t3, -1/n1);
  return r;
}


void oscEvent(OscMessage theOscMessage) {
  //checking the OSC messages
  //incrementing the values
  
  if (theOscMessage.checkAddrPattern("/Note1")==true) {
    n3change += increment;
    n2change += increment;
    n1change += increment;     
    int nota = theOscMessage.get(0).intValue();
    if (nota == 0) {
      flag_end = true;
    }
  } 
  
  if (theOscMessage.checkAddrPattern("/Note2")==true) {
    n3change += increment;
    n2change += increment;
    n1change += increment;
  }

  if (theOscMessage.checkAddrPattern("/Note3")==true) {
    n3change += increment;
    n2change += increment;
    n1change += increment;
  }

}

//calculate m parameter for the supershape
void calculate_m(){
  m = map(sin(mchange), -1, 1, 0, 10);
  mchange += 0.0085;
}

//calculate the n parameters (n1,n2,n3) for the supershape
void calculate_n(){
  //change behaviour at the end of song
  if (flag_end) {
    if (n1change < 10) {
      n1change += 0.085;
    }
    if (n2change < 10) {
      n2change += 0.085;
    }
    if (n2change < 10) {
      n2change += 0.085;
    }    
    
  }
  else {
    n1 = map(cos(n1change), -1, 1, -10, 10 );
    //n1change += 0.0085;
  
    n2 = map(cos(n2change), -1, 1, -1, 8 );
    //n2change += 0.0085;
  
    n3 = map(sin(n3change), -1, 1, -0.1, 0.1 );
    //n3change += 0.0085;
  }

}


void draw() {
  //init
  background(0);
  noStroke();
  lights();
  translate(width/2, height/2, -300);
  rotateX((HALF_PI/5)*4);
  
  // it ends the video render
  if (mchange > 10 || flag_end) {
   //  videoExport.dispose();
  }

  //calculate supershape parameters
  calculate_m();
  calculate_n();

  //for logging purpose only
  //println("m = "+m+" / n1 = " + n1 + " / n2 = " + n2 + " / n3 = " + n3); 


  //calculate points on globe
  float r = 200;
  for (int i = 0; i < total+1; i++) {
    float lat = map(i, 0, total, -HALF_PI, HALF_PI);
    float r2 = supershape(lat, m, n1, n2, n3);

    for (int j = 0; j < total+1; j++) {
      float lon = map(j, 0, total, -PI, PI);
      float r1 = supershape(lon, m, n1*cos(n2), n2*n2*sin(n1), n3);

      float x = r * r1 * cos(lon) * r2 * cos(lat);
      float y = r * r1 * sin(lon) * r2 * cos(lat);
      float z = r * r2 * sin(lat);
      
      //draw point
      ///TODO: COLOR CHANGE SU ASSE Z
      float stroke_value = map(y,-200,200,60,255);
      
      stroke(stroke_value);
      strokeWeight(2);
      point(x, y, z);
      
      //create vector matrix
      globe[i][j] = new PVector(x, y, z);
    }
  }

//apply fill with this
 //stroke(255);
/*
   for (int i = 0; i < total; i++) {
     float hu = map(i, 0, total, 0, 255*6);
     //fill(hu  % 255, 255, 255);
     noFill();
     beginShape(TRIANGLE_STRIP);
     for (int j = 0; j < total+1; j++) {
       PVector v1 = globe[i][j];
       vertex(v1.x, v1.y, v1.z);
       PVector v2 = globe[i+1][j];
       vertex(v2.x, v2.y, v2.z);
     }
     endShape();
   }
*/ 

  //saveFrame("frames/####.png");
  //video export save frame
  // videoExport.saveFrame();
}