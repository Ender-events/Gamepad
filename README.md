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
is the orientation, and the colors are the command being sent. Each color
corresponds to a command. //BENOIT JE VEUX BIEN QUE TU ME FASSES LES CORRES

The datas are then sent through USB, if USB is connected, or through UART.
The UART part is working fine, however, you may have trouble using the USB
stack as it is incomplete.

## Development informations

### Gamepad

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
