# Propulsive Landing Demonstrator – SysML v2 Model

A SysML v2 model of my TVC Rocket, built to learn model-based systems engineering (MBSE).

## The Vehicle
A SpaceX-style Thrust vector controlled landing rocket featuring thrust vector control (TVC), deployable landing legs, a custom flight computer, and a backup recovery parachute. Inspired by BPS Space.

## Why I Built This
I built this model to learn MBSE and SysML v2 by modeling my upcoming TVC rocket project.

## What's in the Model
- **Part hierarchy:** Rocket → Avionics Bay → Flight Computer, IMU, Battery
- **Interfaces and ports:** attitude data, gimbal commands, power distribution, parachute deploy command
- **Flight-mode state machine:** Pad → Ascent → Coast → Descent → Landing Burn → Touchdown
- **Requirements with traceability:** each requirement is linked to the vehicle using `satisfy` relationships

## Requirement Flowdown
The vehicle-level requirement (land at under 2 m/s) flows down to a requirement for the landing legs (withstand impacts of at least 3 m/s, a 1.5× structural margin). Both are traced in the model, so a change in landing performance shows exactly which component requirements are affected.

## Tools
- SysML v2 textual notation
- Syside Editor (VS Code)
- Git / GitHub

## Future Plans
- Add a barometer and an abort flight mode
- Visualize the model in SysON
- Link a Python Monte Carlo landing-dispersion simulation to the model's requirements
