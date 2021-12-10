/**
Code to	generate pogo pin jigs,	for interfacing	with circuits and microcontrollers.

Run get_deps.sh to clone dependencies into a linked folder in your home directory.

There are a few examples below; the nRF52840 and the TinyFPGA Bx, specifically set up for programming them.

-0.16 horizontal expansion, 0.3mm nozzle
I did use a 1/16" drill bit by hand briefly to open up the print-bed-side pin holes.

PINS: list of coordinate pairs of pins, in mm.
FULLY_CONNECTED: every pin gets connected (by plastic) to every other pin.  Easier than setting up CON_STRINGS by hand.
CON_STRINGS: (if not FULLY_CONNECTED,) list of connection strings; each connection string is a list of indices of PINS, and all pins in a string get connected with plastic.
LOOP_STRINGS: connect the last and first pin of each connection string together (so they each form loops).
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 10 : 60;

PIN_D = 1;
PAD_D = 5;
FRAME_T = 2;
FRAME_SZ = 7.5;
//PINS_OX = 10;

/*
{ // nRF52840
    PINS = [[16.84,5],[16.84,-5.27],[-11.1,7.5],[-11.1,-7.75],[11.78,7.5],[11.78,-7.75],[9.23,-7.75],[9.23,7.5]];
    FULLY_CONNECTED = false;
    CON_STRINGS = [[1,0,4,7,2,3,6,5,1],[1,2],[3,0]];
    LOOP_STRINGS = false;
}
/**/


{ // TinyFPGA Bx
    // Warning!  Not symmetrical!  Pay attention to the direction you insert your pogo pins!
    IX = 33/13; // Hah.  I rounded to 2.5 and surprise surprise, was 0.5mm off.
    IY = -15;
    N = 14;
    A = -3.5;
    B = -5.5;
    C = -6;
    // 33
    PINS = [
        [0,0],[IX*(N-1),0],[0, IY],[IX*(N-1),IY], // Corners
        [IX*1,C],[IX*1,C+B],[IX*2,C],[IX*2,C+B] // SPI pads
    ];
    echo(PINS);
    FULLY_CONNECTED = false;
    CON_STRINGS = [[0,1,3,2,0], [0,6,7,2,5,4,0],[4,6],[5,7],[6,1],[7,3]];
    LOOP_STRINGS = false;
}
/**/


// Main program

linear_extrude(height=FRAME_SZ) {
    difference() {
        union() {
            for (i = [0:len(PINS)-1]) {
                translate(PINS[i]) circle(d=PAD_D);
            }
            if (FULLY_CONNECTED) {
                for (i = [0:len(PINS)-2]) {
                    for (j = [i+1 : len(PINS)-1]) {
                        channel(PINS[i],PINS[j],d=FRAME_T,cap="circle");
                    }
                }
            } else {
                for (n = [0:len(CON_STRINGS)-1]) {
                    CON_STRING = CON_STRINGS[n];
                    for (i = [0:len(CON_STRING)-2]) {
                        channel(PINS[CON_STRING[i]],PINS[CON_STRING[i+1]],d=FRAME_T,cap="circle");
                    }
                    if (LOOP_STRINGS) {
                        channel(PINS[CON_STRING[len(CON_STRING)-1]],PINS[CON_STRING[0]],d=FRAME_T,cap="circle");
                    }
                }
            }
        }
        for (i = [0:len(PINS)-1]) {
            translate(PINS[i]) circle(d=PIN_D);
        }
    }
}

//difference() {
//    cube([10+PINS_OX,5,5],center=true);
//    ctranslate([PINS_OX,0,0]) tx(-PINS_OX/2) cylinder(d=PIN_D,h=$FOREVER,center=true);
//}