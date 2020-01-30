# Gamepad Project

## Project

The Gamepad project is a project made by a 4-people team. The goal was to create
a gamepad from a STM32-F4 board, to be able to play games through USB. However,
the project is still unfinished.
This project is divided in two parts. One is the gamepad in itself, and the
other is a USB stack to transmit informations. All code is written in ADA.

## How to build it

In order to build the project you just have to follow the two next steps, once
the card is plugged to your computer.

* `gprbuild --target=arm-eabi -d -P prj.gpr -XLCH=led =XRTS_Profile=ravenscar-sfp -XLOADER=ROM -XADL_BUILD_CHECKS=Enabled src/main/adb -largs -Wl,-Map=map.txt`
* `st-flash obj/main 0x80000` 

## Behaviour

The command are sent generated using the gyroscope of the card. On launch, the
user will see a target on the screen of the card. This target contains all the
information for the user to send data to the computer. In fact, the cursor
is the orientation, and the colors are the command being sent.
When the sensor is tilted forward, The `Z` keycode is send, backward `S`
keycode, to the left with `Q` and to the right with `D`. We can mix two keycode
like `Z` and `Q` by going in diagonal.
Each color corresponds to a command and a modifier status key.
- White smoke: no movement, all keycode to `NONE`.
- Green: Orientation + Left Ctrl modifier status key.
- Yellow: Just the orientation
- Red: Orientation + Left Shift

The data are then sent through USB, if USB is connected, or through UART.
The UART part is working fine, however, you may have trouble using the USB
stack as it is incomplete.

## Development informations

### Gamepad

The Gamepad uses an in-board L3GD20 gyroscope and the driver from ADA driver
library. To reduce the drift, at the beginning, the average of zero motion raw
data of the gyroscope is computed. For each raw data given, the average is
removed and data are filtered through a high-pass filter from W3C Working Group
Note for Motion Sensors.
With this fixed angular velocity, a discrete integration is done with initial
value to 0°.
From the tilt of the board, some keycode is added to a report as explained
above (In the "behaviour" part). The report format is the same as
[USB keyboard](https://wiki.osdev.org/USB_Human_Interface_Devices#USB_keyboard)
. An 8 length bytes message with the first byte being a bitfield of all modifier
status key (Left/right Ctrl, Shift, Alt, GUI), the next one is a reserved byte
and next 6 byte, an array of the key pressed.
When there is a change (a new key is pressed or a key is released) the report
is sent through UART with transmission pin at PA9 and reception pin at PA10.

### USB Stack

In order to use the gamepad with a computer, or any other device, it is necessary
use a USB Stack and register as an HID controller. Nevertheless, there is no such
stack in the Ada Driver Library. One of the aim of this project was to add this
stack. This work is compiling for now but does not do a thing. It is based on
Fabien Chouteau's prototype. We took what was present and added some part in our
implementation. We did not have much time left on debug. So we keep our
implementation with transmission via UART. Nevertheless, we think about seeing
afterwards to make this stack work and make it, if possible, integrated in
ADA Drivers Library, as it was really interesting for our group to work on
it.

## Contracts

In order to have good control over our code, we chose to write contracts
for our Gamepad functions. Those contracts can be found as Pre and Post
conditions, but also Predicates and asserts. This
is useful for us because it documents and tests our code at the same time.
Moreover

## Authors

- Tom Decrette <tom.decrette@epita.fr>
- Benoit Gloria <benoit.gloria@epita.fr>
- Mathis Raguin <mathis.raguin@epita.fr>
- Ferdinand Lemaire <ferdinand.lemaire@epita.fr>
