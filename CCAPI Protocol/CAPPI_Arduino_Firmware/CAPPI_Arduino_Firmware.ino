////////////////////////////////
//Author: Daniel Mor
//Date: 11/24/2012
//Title: CCAPI: Custom Communication Arduino-PC Interfacing Protocol
//Subject: Waits for commands using the CCAPI Protocol to execute commands and send back data


////////////////////////////////
//INCLUDE HEADER FILES
#include <Servo.h>


////////////////////////////////
//PROTOCOL CONSTANTS

//General
#define TERMINATING_CHARACTER '/' //Defines where the end of a command or message is
#define BAUD_RATE 9600 //The speed of the serial communication

//Commands
#define PINMODE_COMMAND 0 //Configure the behavior of a pin [COMMAND -> PIN -> MODE]
#define READ_COMMAND 1 //Read a digital or analog pin [COMMAND -> TYPE -> PIN]
#define WRITE_COMMAND 2 //Writes to a digital or analog pin a value [COMMAND -> TYPE -> PIN -> VALUE]
#define SENSOR_COMMAND 3 //This command sends,receives sensor data among other commands [COMMAND -> SUBCOMMAND -> SENSORTYPE -> ###PINS###]
#define SERVO_COMMAND 4 //Controll and attach a command [COMMAND -> SUBCOMMAND -> PIN NUMBER]

//Sensor SubCommands
#define PING_SUBCOMMAND 0 

//Servo Subcommands
#define ATTACH_SERVO_SUBCOMMAND 0
#define MOVE_SERVO_SUBCOMMAND 1 //[ -> DEGREE]

//Type
#define ANALOG_TYPE 0
#define DIGITAL_TYPE 1

//Mode
#define INPUT_MODE 0
#define OUTPUT_MODE 1

//Power Level
#define LOW_POWER 0
#define HIGH_POWER 1

//Sensor Type
#define ULTRASONIC_SENSOR_TYPE 0 //[ -> ECHO PIN# -> TRIGGER PIN#]


////////////////////////////////
//GLOBAL VARIABLES
Servo servo; 

////////////////////////////////
//INITIALIZE VARIABLES AND OBJECTS
void setup() 
{
    //Initialize the serial connection at the specified baud rate speed
    Serial.begin(BAUD_RATE);
    
    //Initialize by emptying the serial buffer
    clearSerialBuffer();
}

////////////////////////////////
//MAIN PROGRAM LOOP - WAIT FOR INSTRUCTIONS
void loop() 
{         
    //while(Serial.available()) {  
        //Verify that there is incoming serial data
        if(Serial.available()) {  
            //Retrieve command as a serial token
            int command = getNextSerialToken();
            
            //Send the command to be processed
            processCommand(command);
        }  
    //}
}


////////////////////////////////
//FUNCTIONS

//Retrieve next token from serial port (command that ends with terminating character), return -1 if no serial data is available
int getNextSerialToken() {   
    //Initialize token collection variables to 0
    int serialToken = 0;
    int incomingByte = 0; 
  
    //Collect serial data for this token until terminating character is reached        
    do {
        //Read the next byte of incoming serial data
        incomingByte = Serial.read();
        
        //If the incoming byte isn't a terminating character or 0, concatenate it to a new number
        if(incomingByte > 0 && incomingByte != TERMINATING_CHARACTER) 
            serialToken = serialToken * 10 + incomingByte - '0';
    }
    while(incomingByte != TERMINATING_CHARACTER);

    //Return the serial token
    return serialToken;
}

//Route each command to appropriate functions
void processCommand(int command) {
    //Test command against existing cases
    switch(command) 
    {
        //Execute pinMode(pin, mode) command
        case PINMODE_COMMAND: 
        {
            //Retrieve pinMode parameters from incoming serial commands
            int pinNumber = getNextSerialToken();
            int mode = getNextSerialToken();
                                    
            //Execute command
            pinMode(pinNumber, mode);
            
            //Verify that the end of the command sentence was found
            //verifyCommandTerminator();
              
            //Break out of switch statement
            break;
        }
        
        //Execute read command digital or analog   
        case READ_COMMAND: 
        {
            //Retrieve read command type and parameters from incoming serial commands
            int readType = getNextSerialToken();
            int pinNumber = getNextSerialToken();
            
            //Test whether the incoming serial command specifies a digital or analog read
            //Then execute the read function and send the data over the serial port
            if(readType == ANALOG_TYPE) 
                serialWrite(analogRead(pinNumber));
            else if(readType == DIGITAL_TYPE)
                serialWrite(digitalRead(pinNumber));
            
            //Verify that the end of the command sentence was found
            //verifyCommandTerminator();
            
            //Break out of switch statement
            break;
        }
        
        //Execute a write command digital or analog
        case WRITE_COMMAND:
        {
            //Retrieve write command type and parameters from incoming serial commands
            int writeType = getNextSerialToken();
            int pinNumber = getNextSerialToken();
            int value = getNextSerialToken();
            
            //Test whether the incoming serial command specifies a digital or analog read
            if(writeType == ANALOG_TYPE) 
                analogWrite(pinNumber, value);
            else if(writeType == DIGITAL_TYPE) 
                digitalWrite(pinNumber, value);
              
            //Verify that the end of the command sentence was found
            //verifyCommandTerminator();  
                        
            //Break out of switch statement
            break;
        }
        
        //This command sends or receives sensor data
        case SENSOR_COMMAND: 
        {
            //Retrieve subcommand and sensor type
            int subCommand = getNextSerialToken();
            int sensorType = getNextSerialToken();
            
            //Pull pin numbers based on sensor type
            if(sensorType == ULTRASONIC_SENSOR_TYPE) {
                //Store pin numbers
                int echoPinNumber = getNextSerialToken();
                int triggerPinNumber = getNextSerialToken();
                
                //Execute sensor command and send data over serial port
                //Ping the sensor for distance time
                if(subCommand == PING_SUBCOMMAND) {
                    serialWrite(pingUltraSonicSensor(echoPinNumber, triggerPinNumber));
                    
                    //Verify that the end of the command sentence was found
                    //verifyCommandTerminator();  
                }
            }
            
            //break out of the switch statement
            break;
        }
        
        //Control a servo
        case SERVO_COMMAND:
        {
            //store other commands
            int subCommand = getNextSerialToken();
            int pinNumber = getNextSerialToken();
            
            //Process subcommands
            if(subCommand == MOVE_SERVO_SUBCOMMAND) {
                //Get the position the servo should move to
                int degree = getNextSerialToken();
                
                //attach the servo to the pin
                servo.attach(pinNumber);
                
                //Move the servo
                servo.write(degree); 
 
                //Verify that the end of the command sentence was found
                //verifyCommandTerminator();               
            }
          
            //break out of the switch statement
            break;
        }
        
        //Catch any unknown commands
        default:
            //UNKNOWN COMMAND - DO NOTHING
            break;
    }
}

/////////////////////////////////
//SERIAL FUNCTIONS
/////////////////////////////////

//Empty the serial buffer by dumping all read values in the pipe
void clearSerialBuffer() {   
    while(Serial.available() > 0) 
        Serial.read();
}

//Write to the serial port a command value (an int) and concatenate the terminating character to the end
void serialWrite(int value) {
    String out = String(value) + String(TERMINATING_CHARACTER);
    Serial.print(out);
}

//check if the next incoming byte from the serial port is a terminating character
//If it isn't, then clear the serial buffer
boolean verifyCommandTerminator() {
    //Verify that the end of the command sentence was found
    int terminator = Serial.read();
    
    //If something went wrong and the terminator wasn't found, clear the serial buffer
    if(terminator != TERMINATING_CHARACTER) {
        clearSerialBuffer();
        return false;   
    }
    else
        return true;
}


/////////////////////////////////
//SENSOR FUNCTIONS
/////////////////////////////////

//Returns the ping delay in microseconds (time for echo to travel to object and back)
long pingUltraSonicSensor(int echoPinNumber, int triggerPinNumber) {
    //Turn trigger pin off and delay
    digitalWrite(triggerPinNumber, LOW);
    delayMicroseconds(2);
    
    //Turn trigger pin on and delay
    digitalWrite(triggerPinNumber, HIGH);
    delayMicroseconds(10);
    
    //Turn trigger pin back off 
    digitalWrite(triggerPinNumber, LOW);
    
    //Measures how long it takes for the echo to return (MAX 3M = 8823.54 uS)
    return pulseIn(echoPinNumber, HIGH, 8823); //Waits for the pin to go high and times how long till it becomes low in microseconds
    //return pulseIn(echoPin, HIGH);

}
