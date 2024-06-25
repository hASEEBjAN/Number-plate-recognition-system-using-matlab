# Number Plate Recognition System Using MATLAB

This project is designed using MATLAB R2019A.

## Additional Requirements
- Arduino
- Webcam

## Hardware Requirements
- Webcam
- Arduino Uno
- Servomotor (any for barrier opening)
- LCD (16x2 for status display)

## Designing
Connect the Arduino and Webcam to a PC with MATLAB R2019A via USB ports. The LCD data pins, i.e., D4, D5, D6, and D7, are connected to the Arduino's pins D5, D4, D3, and D2 respectively. The enable pin is connected to D6, the Register Select pin to D7, and the contrast control to D11 (if you don't have an external Variac). Connect the servo motor to A0 of the Arduino.

## Deployment
Add the path of the project to MATLAB and run "number_plate_recognition_system.m". Click on the "Initialize" button and then the "Start" button.

