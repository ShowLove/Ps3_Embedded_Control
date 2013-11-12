//Author: Daniel Mor
//Date Started: 11/20/2012
//Date Completed: 
//Program Details: A class that controls a virtual PS3 controller using Procontroll and MotionInJoy


//////////////////////////////////////////
//IMPORT LIBRARIES
import procontroll.*; //Procontroll allows interfacing with game controllers


public class PS3Controller 
{   
    /////////////////////////////
    //PS3 CONTROLLER ID MAPPING
    
    //Button IDs
    final static int triangleButtonID = 0;
    final static int circleButtonID = 1;
    final static int xButtonID = 2;
    final static int squareButtonID = 3;
    
    final static int L1ButtonID = 4;
    final static int R1ButtonID = 5;
    final static int L2ButtonID = 6;
    final static int R2ButtonID = 7;
    
    final static int selectButtonID = 8;
    final static int startButtonID = 9;
    
    final static int leftStickButtonID = 10;
    final static int rightStickButtonID = 11;
    
    final static int PS3ButtonID = 12;
    
    final static int dPadUpID = 13;
    final static int dPadRightID = 14;
    final static int dPadDownID = 15;
    final static int dPadLeftID = 16;
    
    //Slider IDs
    private final static int wAxisSliderID = 2; //Right Stick up/down
    private final static int yTiltSliderID = 3; //Tilt left/right
    private final static int xTiltSliderID = 4; //Tilt away/toward body
    private final static int zAxisSliderID = 5; //Right stick left/right
    private final static int yAxisSliderID = 6; //Left Stick up/down
    private final static int xAxisSliderID = 7; //Left Stick left/right
  
    
    /////////////////////////////
    //General
    private Arduino arduino;
    private String deviceName; //The name of the device being interfaced    
    
    //Controller object
    private ControllDevice controller;
    
    //Stick Objects
    public ControllStick leftStick;
    public ControllStick rightStick;
    public ControllStick tiltStick;
    
    //Constructor
    public PS3Controller(PApplet instance, Arduino arduino, String deviceName) {
        this.arduino = arduino;
        this.deviceName = deviceName;
        
        //Initialize all Controller objects
        initController(instance);
}

    //////////////////////////////////////////
    //INITIALIZE CONTROLLER OBJECTS
    //////////////////////////////////////////
    void initController(PApplet instance) {
        //Retrieve the ControllIO instance
        ControllIO io = ControllIO.getInstance(instance);
          
        //Store the controller's instance into a variable
        controller = io.getDevice(deviceName);
            
        //Create Plug Event Listeners for Controller Buttons
        //Each Button specifies to trigger: ON_PRESS, ON_RELEASE or WHILE_PRESS with specified functions
        controller.plug(this, "triangleButtonPressed", ControllIO.ON_PRESS, triangleButtonID); 
        controller.plug(this, "triangleButtonReleased", ControllIO.ON_RELEASE, triangleButtonID);
        controller.plug(this, "triangleButtonHeld", ControllIO.WHILE_PRESS, triangleButtonID);
        
        controller.plug(this, "circleButtonPressed", ControllIO.ON_PRESS, circleButtonID);
        controller.plug(this, "circleButtonReleased", ControllIO.ON_RELEASE, circleButtonID);
        controller.plug(this, "circleButtonHeld", ControllIO.WHILE_PRESS, circleButtonID);
        
        controller.plug(this, "xButtonPressed", ControllIO.ON_PRESS, xButtonID);
        controller.plug(this, "xButtonReleased", ControllIO.ON_RELEASE, xButtonID);
        controller.plug(this, "xButtonHeld", ControllIO.WHILE_PRESS, xButtonID);
        
        controller.plug(this, "squareButtonPressed", ControllIO.ON_PRESS, squareButtonID);
        controller.plug(this, "squareButtonReleased", ControllIO.ON_RELEASE, squareButtonID);
        controller.plug(this, "squareButtonHeld", ControllIO.WHILE_PRESS, squareButtonID);
        
        controller.plug(this, "L1ButtonPressed", ControllIO.ON_PRESS, L1ButtonID);
        controller.plug(this, "L1ButtonReleased", ControllIO.ON_RELEASE, L1ButtonID);
        controller.plug(this, "L1ButtonHeld", ControllIO.WHILE_PRESS, L1ButtonID);
        
        controller.plug(this, "R1ButtonPressed", ControllIO.ON_PRESS, R1ButtonID);
        controller.plug(this, "R1ButtonReleased", ControllIO.ON_RELEASE, R1ButtonID);
        controller.plug(this, "R1ButtonHeld", ControllIO.WHILE_PRESS, R1ButtonID);
        
        controller.plug(this, "L2ButtonPressed", ControllIO.ON_PRESS, L2ButtonID);
        controller.plug(this, "L2ButtonReleased", ControllIO.ON_RELEASE, L2ButtonID);
        controller.plug(this, "L2ButtonHeld", ControllIO.WHILE_PRESS, L2ButtonID);
        
        controller.plug(this, "R2ButtonPressed", ControllIO.ON_PRESS, R2ButtonID);
        controller.plug(this, "R2ButtonReleased", ControllIO.ON_RELEASE, R2ButtonID);
        controller.plug(this, "R2ButtonHeld", ControllIO.WHILE_PRESS, R2ButtonID);
        
        controller.plug(this, "selectButtonPressed", ControllIO.ON_PRESS, selectButtonID);
        controller.plug(this, "selectButtonReleased", ControllIO.ON_RELEASE, selectButtonID);
        controller.plug(this, "selectButtonHeld", ControllIO.WHILE_PRESS, selectButtonID);
        
        controller.plug(this, "startButtonPressed", ControllIO.ON_PRESS, startButtonID);
        controller.plug(this, "startButtonReleased", ControllIO.ON_RELEASE, startButtonID);
        controller.plug(this, "startButtonHeld", ControllIO.WHILE_PRESS, startButtonID);
        
        controller.plug(this, "leftStickButtonPressed", ControllIO.ON_PRESS, leftStickButtonID);
        controller.plug(this, "leftStickButtonReleased", ControllIO.ON_RELEASE, leftStickButtonID);
        controller.plug(this, "leftStickButtonHeld", ControllIO.WHILE_PRESS, leftStickButtonID);
        
        controller.plug(this, "rightStickButtonPressed", ControllIO.ON_PRESS, rightStickButtonID);
        controller.plug(this, "rightStickButtonReleased", ControllIO.ON_RELEASE, rightStickButtonID);
        controller.plug(this, "rightStickButtonHeld", ControllIO.WHILE_PRESS, rightStickButtonID);
        
        controller.plug(this, "PS3ButtonPressed", ControllIO.ON_PRESS, PS3ButtonID);
        controller.plug(this, "PS3ButtonReleased", ControllIO.ON_RELEASE, PS3ButtonID);
        controller.plug(this, "PS3ButtonHeld", ControllIO.WHILE_PRESS, PS3ButtonID);
        
        controller.plug(this, "dPadUpButtonPressed", ControllIO.ON_PRESS, dPadUpID);
        controller.plug(this, "dPadUpButtonReleased", ControllIO.ON_RELEASE, dPadUpID);
        controller.plug(this, "dPadUpButtonHeld", ControllIO.WHILE_PRESS, dPadUpID);
        
        controller.plug(this, "dPadRightButtonPressed", ControllIO.ON_PRESS, dPadRightID);
        controller.plug(this, "dPadRightButtonReleased", ControllIO.ON_RELEASE, dPadRightID);
        controller.plug(this, "dPadRightButtonHeld", ControllIO.WHILE_PRESS, dPadRightID);
        
        controller.plug(this, "dPadDownButtonPressed", ControllIO.ON_PRESS, dPadDownID);
        controller.plug(this, "dPadDownButtonReleased", ControllIO.ON_RELEASE, dPadDownID);
        controller.plug(this, "dPadDownButtonHeld", ControllIO.WHILE_PRESS, dPadDownID);
        
        controller.plug(this, "dPadLeftButtonPressed", ControllIO.ON_PRESS, dPadLeftID);
        controller.plug(this, "dPadLeftButtonReleased", ControllIO.ON_RELEASE, dPadLeftID);
        controller.plug(this, "dPadLeftButtonHeld", ControllIO.WHILE_PRESS, dPadLeftID);
            
        //Retrieve Controller's 6 Sliders
        ControllSlider wAxisSlider = controller.getSlider(wAxisSliderID);  //Right Stick up/down
        ControllSlider yTiltSlider = controller.getSlider(yTiltSliderID);  //Tilt left/right
        ControllSlider xTiltSlider = controller.getSlider(xTiltSliderID);  //Tilt away/toward body
        ControllSlider zAxisSlider = controller.getSlider(zAxisSliderID); //Right stick left/right
        ControllSlider yAxisSlider = controller.getSlider(yAxisSliderID);  //Left Stick up/down
        ControllSlider xAxisSlider = controller.getSlider(xAxisSliderID);  //Left Stick left/right
          
        //Create custom stick objects using individual sliders & set tolerances
        leftStick = new ControllStick(xAxisSlider, yAxisSlider);
        leftStick.setTolerance(.05f);
        
        rightStick = new ControllStick(zAxisSlider, wAxisSlider);
        rightStick.setTolerance(.05f);
        
        tiltStick = new ControllStick(xTiltSlider, yTiltSlider);
        tiltStick.setTolerance(.2f);
    }
    
    
    
    /////////////////////////////////////////////////////////////
    //BUTTON-PLUG METHODS
    /////////////////////////////////////////////////////////////
    
    //Group of methods called when the Triangle button is pressed, released or held
    void triangleButtonPressed() {println("Triangle Pressed");}
    void triangleButtonReleased() {println("Triangle Released");}
    void triangleButtonHeld() {println("Triangle Held");}
    
    //Group of methods called when the circle button is pressed, released or held
    void circleButtonPressed() {}
    void circleButtonReleased() {}
    void circleButtonHeld() {println("Circle Held");}
    
    //Group of methods called when the x button is pressed, released or held
    void xButtonPressed() {println("X Pressed");}
    void xButtonReleased() {println("X Released");}
    void xButtonHeld() {println("X Held");}
    
    //Group of methods called when the square button is pressed, released or held
    void squareButtonPressed() {println("Square Pressed");}
    void squareButtonReleased() {println("Square Released");}
    void squareButtonHeld() {println("Square Held");}
    
    //Group of methods called when the L1 button is pressed, released or held
    void L1ButtonPressed() {println("L1 Pressed");}
    void L1ButtonReleased() {println("L1 Released");}
    void L1ButtonHeld() {println("L1 Held");}
    
    //Group of methods called when the R1 button is pressed, released or held
    void R1ButtonPressed() {println("R1 Pressed");}
    void R1ButtonReleased() {println("R1 Released");}
    void R1ButtonHeld() {println("R1 Held");}
    
    //Group of methods called when the L2 button is pressed, released or held
    void L2ButtonPressed() {println("L2 Pressed");}
    void L2ButtonReleased() {println("L2 Released");}
    void L2ButtonHeld() {println("L2 Held");}
    
    //Group of methods called when the R2 button is pressed, released or held
    void R2ButtonPressed() {println("R2 Pressed");}
    void R2ButtonReleased() {println("R2 Released");}
    void R2ButtonHeld() {println("R2 Held");}
    
    //Group of methods called when the select button is pressed, released or held
    void selectButtonPressed() {println("Select Pressed");}
    void selectButtonReleased() {println("Select Released");}
    void selectButtonHeld() {println("Select Held");}
    
    //Group of methods called when the start button is pressed, released or held
    void startButtonPressed() {println("Start Pressed");}
    void startButtonReleased() {println("Start Released");}
    void startButtonHeld() {println("Start Held");}
    
    //Group of methods called when the left stick's button is pressed, released or held
    void leftStickButtonPressed() {println("Left Stick Pressed");}
    void leftStickButtonReleased() {println("Left Stick Released");}
    void leftStickButtonHeld() {println("Left Stick Held");}
    
    //Group of methods called when the right stick's button is pressed, released or held
    void rightStickButtonPressed() {println("Right Stick Pressed");}
    void rightStickButtonReleased() {println("Right Stick Released");}
    void rightStickButtonHeld() {println("Right Stick Held");}
    
    //Group of methods called when the PS3 button is pressed, released or held
    void PS3ButtonPressed() {println("PS3 Pressed");}
    void PS3ButtonReleased() {println("PS3 Released");}
    void PS3ButtonHeld() {println("PS3 Held");}
    
    //Group of methods called when the D-Pad's Up button is pressed, released or held
    void dPadUpButtonPressed() {println("D-pad Up Pressed");}
    void dPadUpButtonReleased() {println("D-pad Up Released");}
    void dPadUpButtonHeld() {println("D-pad Up Held");}
    
    //Group of methods called when the D-Pad's Right button is pressed, released or held
    void dPadRightButtonPressed() {println("D-Pad Right Pressed"); }
    void dPadRightButtonReleased() {println("D-Pad Right Released");}
    void dPadRightButtonHeld() {println("D-Pad Right Held");}
    
    //Group of methods called when the D-Pad's down button is pressed, released or held
    void dPadDownButtonPressed() {println("D-Pad Down Pressed");}
    void dPadDownButtonReleased() {println("D-Pad Down Released");}
    void dPadDownButtonHeld() {println("D-Pad Down Held");}
    
    //Group of methods called when the D-Pad's Left button is pressed, released or held
    void dPadLeftButtonPressed() {println("D-Pad Left Pressed"); }
    void dPadLeftButtonReleased() {println("D-Pad Left Released");}  
    void dPadLeftButtonHeld() {println("D-Pad Left Held");}  
}
