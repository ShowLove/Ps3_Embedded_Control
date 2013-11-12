//Author: Daniel Mor
//Date Started: 11/25/2012
//Date Completed: 
//Program Details: A library that uses the CCAPI Protocol to send commands over a serial connection to an arduino microcontroller

public class Arduino
{
    //General
    private Serial port;
    private char terminatingCharacter;
  
    //Commands
    public final static int PINMODE_COMMAND = 0;
    public final static int READ_COMMAND = 1;
    public final static int WRITE_COMMAND = 2;
    public final static int SENSOR_COMMAND = 3;
    public final static int SERVO_COMMAND = 4;
    
    //SENSOR SUBCOMMANDS
    public final static int PING_SUBCOMMAND = 0;
    
    //SERVO SUBCOMMANDS
    public final static int ATTACH_SERVO_COMMAND = 0;
    public final static int MOVE_SERVO_SUBCOMMAND = 1;
  
    //Type
    public final static int ANALOG_TYPE = 0;
    public final static int DIGITAL_TYPE = 1;
    
    //Mode
    public final static int INPUT = 0;
    public final static int OUTPUT = 1;
    
    //Power Level
    public final static int LOW = 0;
    public final static int HIGH = 1;
  
    //Sensor Type
    public final static int ULTRASONIC_SENSOR_TYPE = 0;
  
  
    //Class constructor
    public Arduino(Serial port, char terminatingCharacter) {
        this.port = port;
        this.terminatingCharacter = terminatingCharacter;
    }
    
    
    
    ////////////////////////////////////////////
    //MAIN ARDUINO INTERFACING FUNCTIONS
    ////////////////////////////////////////////
    
    
    public void pinMode(int pinNumber, int mode) {
        serialWrite(PINMODE_COMMAND); //command
        serialWrite(pinNumber); //pin #
        serialWrite(mode); //INPUT OR OUTPUT
        //sendTerminator();
        //println("PINMODE:\t" + PINMODE_COMMAND+"/"+pinNumber+"/"+mode+"/");
    }
    
    public int analogRead(int pinNumber) {
        serialWrite(READ_COMMAND);
        serialWrite(ANALOG_TYPE);
        serialWrite(pinNumber);
        sendTerminator();
        //println("ANALOG READ:\t" + READ_COMMAND+"/"+ANALOG_TYPE+"/"+pinNumber+"/");
        return getNextSerialToken();
    }
    
    public int digitalRead(int pinNumber) {
        serialWrite(READ_COMMAND);
        serialWrite(DIGITAL_TYPE);
        serialWrite(pinNumber);
        //sendTerminator();
        //println("Digital Read:\t" + READ_COMMAND+"/"+DIGITAL_TYPE+"/"+pinNumber+"/");
        return getNextSerialToken();
    }
    
    public void analogWrite(int pinNumber, int value) {
        serialWrite(WRITE_COMMAND);
        serialWrite(ANALOG_TYPE);
        serialWrite(pinNumber);
        serialWrite(value);
        //sendTerminator();
        //println("Analog Write:\t" + WRITE_COMMAND+"/"+ANALOG_TYPE+"/"+pinNumber+"/"+value+"/");
    }
    
    public void digitalWrite(int pinNumber, int value) {
        serialWrite(WRITE_COMMAND);
        serialWrite(DIGITAL_TYPE);
        serialWrite(pinNumber);
        serialWrite(value);
        //sendTerminator();
        //println("Digital Write:\t" + WRITE_COMMAND + "/"+DIGITAL_TYPE+"/"+pinNumber+"/"+value+"/");
    }
    
    
    //Request a Sensor ping, return time delay in microseconds and convert to appropriate unit of distance
    public long requestUltraSonicSensorPing(int echoPinNumber, int triggerPinNumber) {
        //Request ping from arduino
        serialWrite(SENSOR_COMMAND);
        serialWrite(PING_SUBCOMMAND);
        serialWrite(ULTRASONIC_SENSOR_TYPE);
        serialWrite(echoPinNumber);
        serialWrite(triggerPinNumber);
        //sendTerminator();
        
        //Return microseconds to calling function
        return getNextSerialToken();
    }
    
    //Move the servo
    public void moveServo(int pinNumber, int degree) {
        serialWrite(SERVO_COMMAND);
        serialWrite(MOVE_SERVO_SUBCOMMAND);
        serialWrite(pinNumber);
        serialWrite(degree);
        //sendTerminator();
    }
    
    
    ////////////////////////////////////////////
    //SERIAL FUNCTIONS
    ////////////////////////////////////////////
    
    //append the terminating character to the end of the value and then write it to the serial port
    private void serialWrite(int value) {
        String out = str(value) + terminatingCharacter;
        port.write(out);
    }
    
    //Send a single terminating character to the serial port
    private void sendTerminator() {
        port.write(str(terminatingCharacter));
    }
    
    //Retrieve next token from serial port (command that ends with terminating character), return -1 if no serial data is available
    public int getNextSerialToken() {   
        //Initialize token collection variables to 0
        int serialToken = 0;
        int incomingByte = 0; 
      
        //Collect serial data for this token until terminating character is reached        
        do {
            //Read the next byte of incoming serial data
            incomingByte = port.read();
            
            //If the incoming byte isn't a terminating character or 0, concatenate it to a new number
            if(incomingByte > 0 && incomingByte != terminatingCharacter) 
                serialToken = serialToken * 10 + incomingByte - '0';
        }
        while(incomingByte != terminatingCharacter);
    
        //Return the serial token
        return serialToken;
    }
}

