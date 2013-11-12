//Author: Daniel Mor
//Date Started: 11/15/2012
//Date Completed: 
//Program Details: A program to directly interface with a PS3 Controller and send commands to an Arduino microcontroller via Serial Connection



//////////////////////////////////////////
//IMPORT LIBRARIES
import processing.serial.*; //Enable serial communication
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;



//////////////////////////////////////////
//GLOBAL VARIABLES

//General
String deviceName = "MotioninJoy Virtual Game Controller";
color bgColor = color(0, 0, 0);
char terminatingCharacter = '/';
int baudRate = 9600;

//Serial com-port object
Serial port;

//Arduino-Microcontroller object
Arduino arduino;

//Motor objects
Motor motor1;
Motor motor2;

//Servo objects
Servo servo1;

//Sensors
UltraSonicSensor sensor1;

//Playstation controller object
PS3Controller controller;

//Audio Objects
Minim minim;
AudioSample beep;
Timer beepTimer;
boolean triggered;

//////////////////////////////////////////
//DEFAULT SETUP METHOD - EXECUTES ONCE
//////////////////////////////////////////
void setup() {    
    //Initialize the window and general application settings
    initWindow();

    //Open a Serial connection and clear the serial buffer
    port = new Serial(this, Serial.list()[0], baudRate); 
    port.clear();
    
    //Register Microcontroller
    arduino = new Arduino(port, terminatingCharacter);
    
    //Create motor objects - passing in appropriate physical pin numbers and control method
    motor1 = new Motor(arduino, 12, 9, 3, true);    
    motor2 = new Motor(arduino, 13, 8, 11, true);
    
    //Create and initialize servo objects
    servo1 = new Servo(arduino, 10, 0, 180);
  
    //Create and initialize sensor objects
    sensor1 = new UltraSonicSensor(arduino, 7, 4);  
    
    //Create and init the PS3Controller
    controller = new PS3Controller(this, arduino, deviceName);    
    
    //Initialize audio objects
    minim = new Minim(this);
    beep = minim.loadSample("Audio/Beep.wav");
    beepTimer = new Timer();
    triggered = false;
    
    //Create and initialize the motor controller thread
    //MotorControlThread motorControl = new MotorControlThread(controller, motor1, motor2);
    //Thread motorThread = new Thread(motorControl);
    //motorThread.start();
}



//////////////////////////////////////////
//UPDATE DATA METHOD - ENDLESS LOOP
//////////////////////////////////////////
void update() { 
    //Retrieve analog stick Y axis values for both sticks
    float leftValue = controller.leftStick.getY();
    float rightValue = controller.rightStick.getY();
             
    //Move motor1 according to the left stick's position
    if(leftValue == 0) 
        motor1.applyBreaks();
    else if(leftValue > 0)
        motor1.moveForward(leftValue);
    else if(leftValue < 0)
        motor1.moveBackward(leftValue);
           
    //Move motor2 according to the right stick's position
    if(rightValue == 0) 
        motor2.applyBreaks();
    else if(rightValue > 0)
        motor2.moveForward(rightValue);
    else if(rightValue < 0)
        motor2.moveBackward(rightValue);
}


//////////////////////////////////////////
//DRAW - ENDLESS LOOP
//////////////////////////////////////////
void draw() {
    //Update data before drawing
    update();
    
    //Ping the sensor and draw data
    sensorPing();    

    //Draw Left Stick
    //fill(255,0,0);
    //rect(width/2 + controller.leftStick.getX()*width/2, height/2 + controller.leftStick.getY()*height/2, circleSize, circleSize, 12, 12);
    
    //Draw right stick
    //fill(0,255,0);
    //rect(width/2 + controller.rightStick.getX()*width/2, height/2 + controller.rightStick.getY()*height/2, circleSize, circleSize, 12, 12);
}

//CALLED ON EXIT
void stop() {
    //print to console that program has exited
    println("EXITTED...");
    
    //Close audio thread
    beep.close();
    minim.stop();
    
    //Stop motors
    motor1.applyBreaks();
    motor2.applyBreaks();
    
    //call stuper class
    super.stop();
}

//////////////////////////////////////////
//INITIALIZE WINDOW AND PROGRAM SETTINGS
//////////////////////////////////////////
void initWindow() {
    //Set a default size
    size(500, 500);
  
    //Allow the window to be resized and/or maximized
    frame.setResizable(true);
    
    //set the background color of the screen
    background(bgColor);
    
    //Set that rectangles and ellipses are drawn from a centerpoint
    rectMode(CENTER); 
    ellipseMode(RADIUS);

    //Set the size of the text used in the program
    textSize(18);
}


void sensorPing() {
    //Pan the servo
    servo1.pan(1);
  
    //Clear the background if the servo reached its bounds
    if(servo1.atBound()) {
        background(bgColor);
    }
    
    //Ping the ultrasonic sensor and retrieve a distance in the specified unit
    float distance = sensor1.requestDistance(Unit.IN);
    float multiplier = 25; 
    
    //print to console
    println(distance);

    //Beep if within proximity
    float proximity = 5;
    int pause = 1000;
                
    //Test if object within proximity
    if(distance > 0 && distance <= proximity) {
        if(triggered == false) {
            beep.trigger();
            beepTimer.reset();
            triggered = true;
        }
        else {
            if(beepTimer.ellapsedMillis() > pause) {
                beep.trigger();
                beepTimer.reset();
            }    
        }
    }
    else {
        if(beepTimer.ellapsedMillis() > pause)
            triggered = false;
    }
    
    //Calculate the x and y values using the direction the servo is pointing to draw in the appropriate location
    float angle = servo1.getPosition() * PI / 180;
    float offSet = 90 * PI / 180;
    float x = width/2 + distance * sin(angle + offSet) * multiplier;
    float y = height/2 + distance * cos(angle + offSet) * multiplier;
    
    //Change the color and draw the dots
    fill(245,185,0);
    stroke(0,0,0);
    ellipse(x, y, 8, 8); //small circles   
   
    
    stroke(0, 255, 0);
    line(width/2, height/2, x, y); //Line
    
    stroke(0, 50, 0);   
    
    //Draw distance rings
    noFill();
    int amount = 30;
    for(int i = 0; i < amount; i++) {
        ellipse(width/2, height/2, i*multiplier, i*multiplier);
    }
    
    stroke(0, 100,0);
    //Draw vertical and horizontal crosshairs
    line(0, height/2, width, height/2); //horizontal
    line(width/2, 0, width/2, height);

    fill(200, 0, 0);
    stroke(0,0,0);
    ellipse(width/2, height/2, multiplier, multiplier); //center 
}
