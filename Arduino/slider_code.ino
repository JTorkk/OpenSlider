#include <AccelStepper.h>
#include <MultiStepper.h>
#include <SoftwareSerial.h>

SoftwareSerial mySerial(2, 3);  // RX, TX

AccelStepper slide(1, 5, 4);  // (Type:driver, STEP, DIR)
AccelStepper turn(1, 6, 7);

MultiStepper steppers;  // Create instance of MultiStepper

#define focus 10
#define record 11

long positions1[2];
long positions2[2];
long positions3[2];
long positions4[2];

int slideSpeed = 450;

/*
int sPeed = 3;
int acceleration = 0;

int speed_Accelration1[2];
int speed_Accelration2[2];
int speed_Accelration3[2];
int speed_Accelration4[2];

*/

void setup() {
    mySerial.begin(9600);
    Serial.begin(9600);

    slide.setMaxSpeed(4000);
    slide.setSpeed(200);
    slide.setAcceleration(100);

    turn.setMaxSpeed(4000);
    turn.setSpeed(200);

    steppers.addStepper(slide);
    steppers.addStepper(turn);

    pinMode(focus, OUTPUT);
    pinMode(record, OUTPUT);

    if (false) {
        sendCommand("AT");
        sendCommand("AT+ROLE0");
        sendCommand("AT+UUID0xFFE0");
        sendCommand("AT+CHAR0xFFE1");
        sendCommand("AT+NAMEOpenSlider");
    }
}
//bluetooth configuration
void sendCommand(const char *command) {
    Serial.print("Command send :");
    Serial.println(command);
    mySerial.println(command);
    //wait some time
    delay(100);

    char reply[100];
    int i = 0;
    while (mySerial.available()) {
        reply[i] = mySerial.read();
        i += 1;
    }
    //end the string
    reply[i] = '\0';
    Serial.print(reply);
    Serial.println("Reply end");
}

//bluetooth read function
char readSerial() {
    char reply[50];
    int i = 0;
    while (mySerial.available()) {
        reply[i] = mySerial.read();
        i += 1;
    }
    //end the string
    reply[i] = '\0';
    if (strlen(reply) > 0) {
        Serial.print("--> Some data received: ");
        Serial.print(reply);
        Serial.println(" <--");
    }

    return (reply[0]);
}

void focuss() {
    digitalWrite(focus, HIGH);
    delay(500);
    digitalWrite(focus, LOW);
}
void recordd() {
    digitalWrite(record, HIGH);
    delay(500);
    digitalWrite(record, LOW);
}

void loop() {
    //setEnd();
    char data = readSerial();

    bool movee = true;
    char tmp = ' ';

    if (data == 's') {
        Serial.println("- case: move left");

        slide.setSpeed(800);
        while (movee) {
            slide.runSpeed();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                Serial.println(slide.currentPosition());
                movee = false;
                tmp = ' ';
            }
        }
    } else if (data == 'S') {
        Serial.println("- case: move right");

        slide.setSpeed(-800);
        while (movee) {
            slide.runSpeed();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                Serial.println(slide.currentPosition());
                movee = false;
                tmp = ' ';
            }
        }
    } else if (data == 't') {
        Serial.println("- case: turn left");

        turn.setSpeed(200);
        while (movee) {
            turn.runSpeed();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                Serial.println(turn.currentPosition());
                movee = false;
                tmp = ' ';
            }
        }
    } else if (data == 'T') {
        Serial.println("- case: turn right");

        turn.setSpeed(-200);
        while (movee) {
            turn.runSpeed();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                Serial.println(turn.currentPosition());
                movee = false;
                tmp = ' ';
            }
        }

        //speed and acceleration not working yet on the mobile app
        /* }else if (data >=0 || data <=9){
       Serial.println("- case: speed received");
       sPeed = data - '0';

       //
    }else if (data >=5 || data <=4){
       Serial.println("- case: acceleration received");
       acceleration = data - '0';*/

        //set keyframme positions
    } else if (data == 'J') {
        Serial.println("- case: set position 1");

        positions1[0] = slide.currentPosition();
        positions1[1] = turn.currentPosition();

        //usethese for all when the mobile app is working
        //slide.setMaxSpeed(sPeed);
        //slide.setAcceleration(acceleration);

        Serial.print("position 1; slide:");
        Serial.print(positions1[0]);
        Serial.print(", turn: ");
        Serial.println(positions1[1]);

    } else if (data == 'K') {
        Serial.println("- case: set position 2");

        positions2[0] = slide.currentPosition();
        positions2[1] = turn.currentPosition();

        Serial.print("position 2; slide:");
        Serial.print(positions2[0]);
        Serial.print(", turn: ");
        Serial.println(positions2[1]);

    } else if (data == 'L') {
        Serial.println("- case: set position 3");
        positions3[0] = slide.currentPosition();
        positions3[1] = turn.currentPosition();

        Serial.print("position 3; slide:");
        Serial.print(positions3[0]);
        Serial.print(", turn: ");
        Serial.println(positions3[1]);

    } else if (data == 'M') {
        Serial.println("- case: set position 4");
        positions4[0] = slide.currentPosition();
        positions4[1] = turn.currentPosition();

        Serial.print("position 4; slide:");
        Serial.print(positions4[0]);
        Serial.print(", turn: ");
        Serial.println(positions4[1]);

        //Move to position functions
    } else if (data == 'j') {
    Position1:
        Serial.println("- case: move to position 1");

        slide.setMaxSpeed(slideSpeed);
        turn.setMaxSpeed(slideSpeed);

        steppers.moveTo(positions1);  // Calculates the required speed for all motors
        movee = true;
        while ((slide.currentPosition() != positions1[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;

            } else if (tmp == 'j') {
                goto Position1;

            } else if (tmp == 'k') {
                goto Position2;

            } else if (tmp == 'l') {
                goto Position3;

            } else if (tmp == 'm') {
                goto Position4;
            }
            tmp = ' ';
        }

    } else if (data == 'k') {
    Position2:
        Serial.println("- case: move to position 2");

        slide.setMaxSpeed(slideSpeed);
        turn.setMaxSpeed(slideSpeed);

        steppers.moveTo(positions2);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions2[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;

            } else if (tmp == 'j') {
                goto Position1;

            } else if (tmp == 'k') {
                goto Position2;

            } else if (tmp == 'l') {
                goto Position3;

            } else if (tmp == 'm') {
                goto Position4;
            }
            tmp = ' ';
        }

    } else if (data == 'l') {
    Position3:
        Serial.println("- case: move to position 3");

        slide.setMaxSpeed(slideSpeed);
        turn.setMaxSpeed(slideSpeed);

        steppers.moveTo(positions3);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions3[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;

            } else if (tmp == 'j') {
                goto Position1;

            } else if (tmp == 'k') {
                goto Position2;

            } else if (tmp == 'l') {
                goto Position3;

            } else if (tmp == 'm') {
                goto Position4;
            }
            tmp = ' ';
        }

    } else if (data == 'm') {
    Position4:
        Serial.println("- case: move to position 4");

        slide.setMaxSpeed(slideSpeed);
        turn.setMaxSpeed(slideSpeed);

        steppers.moveTo(positions4);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions4[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;

            } else if (tmp == 'j') {
                goto Position1;

            } else if (tmp == 'k') {
                goto Position2;

            } else if (tmp == 'l') {
                goto Position3;

            } else if (tmp == 'm') {
                goto Position4;
            }
            tmp = ' ';
        }

    } else if (data == 'p') {
        Serial.println("- case: got from 1 to 4");

        slide.setMaxSpeed(slideSpeed);
        turn.setMaxSpeed(slideSpeed);
        if(positions1[0] != 0 || positions1[1] != 0){
        steppers.moveTo(positions1);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions1[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;
                tmp = ' ';
            }
        }
        }
        if(positions2[0] != 0 || positions2[1] != 0){
        steppers.moveTo(positions2);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions2[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;
                tmp = ' ';
            }
        }
        }
        if(positions3[0] != 0 || positions3[1] != 0){
        steppers.moveTo(positions3);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions3[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;
                tmp = ' ';
            }
        }
        }
        if(positions4[0] != 0 || positions4[1] != 0){
        steppers.moveTo(positions4);  // Calculates the required speed for all motors

        while ((slide.currentPosition() != positions4[0]) && movee) {
            steppers.run();
            tmp = readSerial();
            if (tmp == 'P') {
                Serial.println("movee = false");
                movee = false;
                tmp = ' ';
            }
        }
        }
    } else if (data == 'f') {
        recordd();
    } else if (data == 'F') {
        focuss();
    }
}
