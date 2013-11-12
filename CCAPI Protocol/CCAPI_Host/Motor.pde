//Author: Daniel Mor
//Date Started: 11/10/2012
//Date Completed: 
//Program Details: Class that stores a motors information as well as controlling and actuating it (forward, backward, break)

class Motor
{
    //The arduino object that holds the motor
    private Arduino arduino;
    
    //The pin numbers that the motor is connected to
    private int pinNumber;
    private int breakPinNumber;
    private int pwmPinNumber;
    
    //control variables for the motor
    private boolean analogControlled; //if analog controlled, convert [-1,1] range to [0,255], if not, then expects [0,255] power
    private boolean breaksEngaged;
  
  
    //Constructor to initialize values and register pins with arduino
    public Motor(Arduino arduino, int pinNumber, int breakPinNumber, int pwmPinNumber, boolean analogControlled) {
        //Locally store variables
        this.arduino = arduino;
        this.pinNumber = pinNumber;
        this.breakPinNumber = breakPinNumber;
        this.pwmPinNumber = pwmPinNumber;
        this.analogControlled = analogControlled;
        breaksEngaged = false; //By default set the breaks to not be engaged
        
        //Register motor with arduino
        arduino.pinMode(pinNumber, Arduino.OUTPUT);
        arduino.pinMode(breakPinNumber, Arduino.OUTPUT);
        
        //Apply the breaks to the motor
        applyBreaks();        
    }
    
    //Apply the breaks to a motor if they aren't already engaged - this stops the motor
    public void applyBreaks() {
        if(breaksEngaged == false) {
            arduino.digitalWrite(breakPinNumber, Arduino.HIGH);
            breaksEngaged = true;
        }
    }
    
    //Move the motor in the forwards direction the specific amount of power passed in
    //If the motor is controlled by analog, pass in a value [-1, 1], or else a value [0, 255]
    public void moveForward(float power) {
        arduino.digitalWrite(pinNumber, Arduino.HIGH); //Direction
        arduino.digitalWrite(breakPinNumber, Arduino.LOW); //Disengage Break
                
        if(analogControlled == true) 
            arduino.analogWrite(pwmPinNumber, int(map(abs(power), 0, 1, 0, 255))); //Move motor
        else 
            arduino.analogWrite(pwmPinNumber, int(constrain(abs(power), 0, 255))); //Move motor
          
        //Reset breaks boolean  
        breaksEngaged = false;
    }
    
    //Move the motor in the backwards direction the specific amount of power passed in
    //If the motor is controlled by analog, pass in a value [-1, 1], or else a value [0, 255]
    public void moveBackward(float power) {
        arduino.digitalWrite(pinNumber, Arduino.LOW); //Direction
        arduino.digitalWrite(breakPinNumber, Arduino.LOW); //Disengage Break
                
        if(analogControlled == true) 
            arduino.analogWrite(pwmPinNumber, int(map(abs(power), 0, 1, 0, 255))); //Move motor
        else 
            arduino.analogWrite(pwmPinNumber, int(abs(power))); //Move motor
            
        //Reset breaks boolean
        breaksEngaged = false;
    }
}
