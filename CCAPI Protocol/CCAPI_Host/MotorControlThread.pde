//Author: Daniel Mor
//Date Started: 12/02/2012
//Program Details: Runs a thread that sends motor control signals to the arduino microcontroller

public class MotorControlThread implements Runnable
{
    //Global variables
    private PS3Controller controller;
    private Motor motor1;
    private Motor motor2;
  
    //General constructor
    public MotorControlThread(PS3Controller controller, Motor motor1, Motor motor2) {
        //Store variables locally
        this.controller = controller;
        this.motor1 = motor1;
        this.motor2 = motor2;
    }
    
    //Threaded function
    public void run() {
        //Endlessly loop control thread  
        while(true) {
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
    }
}
