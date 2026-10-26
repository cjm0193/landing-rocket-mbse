// Propulsive Landing Demonstrator - SysML v2 model
// Author: Charles Massey
// Purpose: Learning MBSE by modeling my TVC landing rocket project.

package LandingDemonstrator {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    // =====================================================
    // 1. DATA & SIGNALS (what flows between parts)
    // =====================================================
    attribute def AttitudeData;      // IMU orientation estimate
    attribute def GimbalCommand;     // pitch/yaw command to TVC

    item def LaunchCmd;
    item def BurnoutDetected;
    item def ApogeeDetected;
    item def LandingBurnTrigger;
    item def TouchdownDetected;

    // =====================================================
    // 2. INTERFACES (ports = connection points on parts)
    // =====================================================
    port def AttitudePort {
        out attribute attitude : AttitudeData;
    }

    port def GimbalCmdPort {
        out attribute cmd : GimbalCommand;
    }
    attribute def ElectricalPower;

    port def PowerPort {
        out attribute power : ElectricalPower;
    }

    port def DeployCmdPort {
        out attribute deploy : Boolean;
    }
    // =====================================================
    // 3. PARTS (what the system is made of)
    // =====================================================
    part def IMU {
        doc /* Inertial measurement unit providing attitude data. */
        port attitudeOut : AttitudePort;
    }

    part def FlightComputer {
        doc /* Custom flight computer running state estimation and TVC control. */
        port attitudeIn : ~AttitudePort;     // ~ means the receiving side
        port gimbalOut : GimbalCmdPort;
        port powerIn : ~PowerPort;
        port deployOut : DeployCmdPort;
        exhibit state modes : FlightModes;   // the flight computer runs the mode logic
    }

    part def TVCMount {
        doc /* Two-axis thrust vector control gimbal. */
        port gimbalIn : ~GimbalCmdPort;
        part pitchServo : Servo;
        part yawServo : Servo;
    }

    part def Engine;
    part def LandingLegs { doc /* Deployable landing legs. */ 
        attribute maxImpactVelocity : SpeedValue;
    }
    part def Airframe;
    
    part def Battery {
        doc/* LiPo battery powering the avionics and servos*/
        attribute voltage : Real;
        attribute capacity : Real;
        port powerOut : PowerPort;
    }
    
    part def Servo {
        doc/* Actuator that drives one axis of the TVC gimbal*/
        attribute maxTorque : Real;
        port powerIn : ~PowerPort;
    }
   
    part def Parachute{
        doc/* Parachute for backup recovery*/
        attribute mass : MassValue;
        attribute deployAltitude : LengthValue;
        port deployIn : ~DeployCmdPort;
    }
    
    part def AvionicsBay{
        doc/* Houses Flight Computer, IMU, and battery*/
        part flightComputer : FlightComputer;
        part imu : IMU;
        part battery : Battery;

        interface imuToFC connect imu.attitudeOut to flightComputer.attitudeIn;
        interface batteryToFC connect battery.powerOut to flightComputer.powerIn;
    }
    
    part def Rocket {
        attribute dryMass : MassValue;
        attribute landingVelocity : SpeedValue;
        part avionics : AvionicsBay;
        part tvc : TVCMount;
        part engine : Engine;
        part legs : LandingLegs;
        part parachute : Parachute;
        part airframe : Airframe;


        // Internal connections (this is what an IBD shows)
        interface fcToTVC connect avionics.flightComputer.gimbalOut to tvc.gimbalIn;
        interface fcToChute connect avionics.flightComputer.deployOut to parachute.deployIn;
        interface powerToPitch connect avionics.battery.powerOut to tvc.pitchServo.powerIn;
        interface powerToYaw connect avionics.battery.powerOut to tvc.yawServo.powerIn;
    }

    // =====================================================
    // 4. BEHAVIOR (flight mode state machine)
    // =====================================================
    state def FlightModes {
        entry; then OnPad;

        state OnPad;
        transition first OnPad accept LaunchCmd then Ascent;

        state Ascent;
        transition first Ascent accept BurnoutDetected then Coast;

        state Coast;
        transition first Coast accept ApogeeDetected then Descent;

        state Descent;
        transition first Descent accept LandingBurnTrigger then LandingBurn;

        state LandingBurn;
        transition first LandingBurn accept TouchdownDetected then Touchdown;

        state Touchdown;
    }

    // =====================================================
    // 5. REQUIREMENTS
    // =====================================================
    requirement def MaxDryMass {
        doc /* The rocket dry mass shall not exceed 2.0 kg. */
        subject vehicle : Rocket;
        require constraint { vehicle.dryMass <= 2.0 [kg] }
    }
    requirement def MinDeployAltitude {
        doc /* The parachute shall deploy at an altitude at or above 100 m. */
        subject vehicle : Rocket;
        require constraint { vehicle.parachute.deployAltitude >= 100 [m] }
    }
    requirement def ClosedLoopAttitudeControl {
        doc /* The flight computer shall command the TVC mount using IMU attitude data. */
        subject vehicle : Rocket;
    }
    requirement def MaxLandingVelocity { 
        doc /* The rocket shall land at a vertical velocity of less than 2 m/s. */
        subject vehicle : Rocket;
        require constraint { vehicle.landingVelocity < 2 [m/s] }
    }
        requirement def LegImpactTolerance {
        doc /* The landing legs shall withstand an impact velocity of at least 3 m/s 
               (1.5x margin over the 2 m/s landing velocity requirement). */
        subject vehicle : Rocket;
        require constraint { vehicle.legs.maxImpactVelocity >= 3 [m/s] }
    }
    

    // =====================================================
    // 6. THE ACTUAL VEHICLE + TRACEABILITY
    // =====================================================
    part landingRocket : Rocket {
        attribute :>> dryMass = 1.8 [kg];
        attribute :>> landingVelocity = 1.5 [m/s];
         part :>> parachute {
            attribute :>> deployAltitude = 150 [m];   // update later
         }
         part :>> legs {
            attribute :>> maxImpactVelocity = 5 [m/s];
         }
    }
    requirement massReq : MaxDryMass;
    requirement controlReq : ClosedLoopAttitudeControl;
    requirement deployReq : MinDeployAltitude;
    requirement landingReq : MaxLandingVelocity;
    requirement impactReq : LegImpactTolerance;


    satisfy massReq by landingRocket;
    satisfy controlReq by landingRocket;
    satisfy deployReq by landingRocket;
    satisfy landingReq by landingRocket;
    satisfy impactReq by landingRocket;
}
