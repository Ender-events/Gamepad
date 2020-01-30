# Gamepad Project

## Project

The Gamepad project is a project made by a 4-people team. The goal was to create
a gamepad from a STM32-F4 board, to be able to play games through USB. However,
the project is still unfinished.
This project is divided in two parts. One is the gamepad in itself, and the
other is a USB stack to transmit informations. All code is written in ADA.

## How to build it

## Behaviour

The command are sent generated using the gyroscope of the card. On launch, the
user will see a target on the screen of the card. This target contains all the
information for the user to send datas to the computer. In fact, the cursor
is the orientation, and the colors are the command being sent.
When the sensor is tilted forward, The `Z` keycode is send, backward `S`
keycode, to the left with `Q` and to the right with `D`. We can mix two keycode
like `Z` and `Q` by going in diagonal.
Each color corresponds to a command and a modifier status key.
- White smoke: no movement, all keycode to `NONE`.
- Green: Orientation + Left Ctrl modifier status key.
- Yellow: Just the orientation
- Red: Orientation + Left Shift

The datas are then sent through USB, if USB is connected, or through UART.
The UART part is working fine, however, you may have trouble using the USB
stack as it is incomplete.

## Development informations

### Gamepad

The Gamepad uses a in-board L3GD20 gyroscope and the driver from ADA driver
library. To reduce the drift, at the beginning, the average of zero motion raw
data of the gyroscope is computed. For each raw data given, the average is
removed and data is filtered through a high-pass filter from W3C Working Group
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

## Contracts

In order to have good control over our code, we chose to write contracts
for our Gamepad functions. Those contracts can be found as Pre and Post
conditions, but also Pre'Class and Post'Class, Predicates and asserts. The
final effect of all that is that we can prove a good part of our code with
Spark.
About Spark, it is disabled on few functions that can't be proven.

## Authors

- Tom Decrette <tom.decrette@epita.fr>
- Benoit Gloria <benoit.gloria@epita.fr>
- Mathis Raguin <mathis.raguin@epita.fr>
- Ferdinand Lemaire <ferdinand.lemaire@epita.fr>
