/*
 * A simple sketch that uses WiServer to serve a web page
 */


#include <WiServer.h>
#include <Servo.h> 
 // create servo object to control a servo 
 // a maximum of eight servo objects can be created 
Servo servo_head_lr; // left and right, 0 to 180, 0 is right, 180 is left, 90 is forward
//Servo servo_head_ud; // up and down, 0 is top, 58 is horizon, can be 0 to 60
Servo servo_head_ud; // up and down, 0 to 180, 100 is vertical, 180 is horizon
Servo servo_wheel_left;
Servo servo_wheel_right;
Servo servo_arm_left;
Servo servo_arm_right;

#define SERVO_HEAD_LR_PIN 5  // control head turn left and right
#define SERVO_HEAD_UD_PIN 6  // control head tu``2rn up and down
#define SERVO_WHEEL_LEFT_PIN 8  // control wheel left
#define SERVO_WHEEL_RIGHT_PIN 9 // control wheel right
#define SERVO_ARM_LEFT_PIN 4 // control left arm (120`0) NOTICE: DONOT BEYOND THE VALUE RANGE !
#define SERVO_ARM_RIGHT_PIN 7 // control right arm (45~180) NOTICE: DONOT BEYOND THE VALUE RANGE

#define MOV_HEAD_LEFT 11
#define MOV-HEAD_RIGHT 12
#define MOV_HEAD_UP 13
#define MOV_HEAD_DOWN 14
//#define MOV_FORWARD 15
//#define MOV_BACKWARD 16
//#define MOV_TURN_LEFT 17
//#define MOV_TURN_RIGHT 18

int head_pos_lr = 30;
int head_pos_ud = 10;
#define HEAD_POS_LR_MAX  180
#define HEAD_POS_LR_MIN 0
#define HEAD_POS_UD_MAX 140
#define HEAD_POS_UD_MIN 0
#define HEAD_INIT_POS_LR 90
#define HEAD_INIT_POS_UD 150

 
#define WIRELESS_MODE_INFRA	1
#define WIRELESS_MODE_ADHOC	2

// Wireless configuration parameters ----------------------------------------
unsigned char local_ip[] = {169,254,203,23};	// IP address of WiShield
 unsigned char gateway_ip[] = {169,254,0,0};	// router or gateway IP address
 unsigned char subnet_mask[] = {255,255,0,0};	// subnet mask for the local network
const prog_char ssid[] PROGMEM = {"jjxx3"};		// max 32 bytes

unsigned char security_type = 0;	// 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2

// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {""};	// max 64 characters

// WEP 128-bit keys
// sample HEX keys
prog_uchar wep_keys[] PROGMEM = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,	// Key 0
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Key 1
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Key 2
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	// Key 3
				};

// setup the wireless mode
// infrastructure - connect to AP
// adhoc - connect to another WiFi device
unsigned char wireless_mode = WIRELESS_MODE_ADHOC;

unsigned char ssid_len;
unsigned char security_passphrase_len;
// End of wireless configuration parameters ----------------------------------------


// This is our page serving function that generates web pages
boolean sendMyPage(char* URL) {
     
  //  Serial.println(URL);

    // Check if the requested URL matches "/"
    if (strcmp(URL, "/") == 0) {
        // Use WiServer's print and println functions to write out the page content
        WiServer.print("<html>");
        WiServer.print("Hello World!");
        WiServer.print("</html>");
    
        // URL was recognized
        return true;
    }
    
    if (parseCmd(URL)){
      WiServer.print(head_pos_lr);
       WiServer.print(",");
        WiServer.print(head_pos_ud);
     
     return true; 
    }
     
    // URL not found
    return false;
}

void move_forward(){
  servo_wheel_left.write(180);
  servo_wheel_right.write(0);
}
void move_backward(){
  servo_wheel_left.write(0);
  servo_wheel_right.write(180);
}
void move_left(){
  servo_wheel_left.write(0);
  servo_wheel_right.write(0);
}
void move_right(){
  servo_wheel_left.write(180);
  servo_wheel_right.write(180);
}

void move_stop(){
   servo_wheel_left.write(90);
  servo_wheel_right.write(90);
}
// process str to get a word before '?' or '/', by set it to 0
// e.g Input=>"mh-1/mh-2/mh-3" 
//     str=>"mh-1", return "mh-2/mh-3"
char* getWord(char* str){
    
    char* p = str;
    char* pp=p;
    
    
    while (*pp != '/' && *pp!='?' && *pp != 0)
    {
      pp = pp+1;
    }
    
    *pp = 0;
        //Serial.println("getWord:");
         //Serial.println(str);
    return pp+1;
}


// parse command and parameter from a word
// e.g. "mh-1"
//  g_cmd=>mh, g_param=>"-1", return "1"
char g_cmd[10];
char g_param[20];
char g_sign;
char g_unit;
char* getCmd(char* str){
    char* p = str;
    char* pp=p;
    int i = 0;
    memset(g_cmd, 0, 10);
    memset(g_param, 0, 10);
    while (*pp != '-' && *pp != '+' && *pp != '=' && *pp != 0)
    {
      g_cmd[i] = *pp;
      pp = pp+1;
      i=i+1;
    }
    g_cmd[i] = 0;
    strcpy(g_param, pp);
     
    *pp = 0;
        //Serial.println("getWord:");
         //Serial.println(str);
    Serial.println(g_cmd);
    Serial.println(g_param);
    return pp+1;
}
// get meaning of parameter
// e.g. "1c+2s" or "1" or "+1" mean 1 degree or HIGH
//      "1s" means one step of unit
//      "-1" meams minus 1 degree 
// return the number, p=>+2s, g_sign => sign
int parseCmdParam(char* p){
  char *_p = p;
  // sign
  if (*p != '+' && *p != '-' && *p != '=')
    g_sign='=';
   else{
    g_sign = *p;
    p++;
   }
    
   // digit code
   int i = 0;
  for ( i = 0; i< strlen(p); i++){
    if (!(p[i] > 47 && p[i] < 58) )
      break;
  }
  
  g_unit = *p;
  
  char b[20] = "";
  strcpy(b,p);
  b[i] = 0;
  int r = atoi(b);
 
  strcpy(_p, b+i+1);
  
  Serial.println("--cmd--");
  Serial.println(g_cmd);
  Serial.println(g_param);
  Serial.println(g_sign);
  Serial.println(g_unit);
  return r;
}

boolean strStarWith(char* s, char* p){
  int ls = strlen(s);
  int lp = strlen(p);
  if (s < p)
    return false;
  if (s == p)
    return strcmp(s,p) == 0;
    int i = 0;
    int j = 0;
  for ( i = 0,  j = 0; i< strlen(s) && j < strlen(p); i++, j++){
    if (s[i] != p[j])
      return false;
  }
  return true;
  
}
boolean parseCmd(char* url)
{
Serial.println(url);
  if (url[0] != '/')
    return false;
    
   int len = strlen(url);
   if (len <= 1)
     return false;
     
     char* str = url+1;
   char* p = getWord(url+1);
   
    if (strcmp(url+1, "mh")==0){
      char *pp = getWord(p);
      int code = atoi(p);
      doMoveHead(code);
      return true;
    }else if (strcmp(url+1, "g") ==0){
      move_forward();
    }
    else if (strcmp(url+1, "b") ==0){
      move_backward();
    }
        else if (strcmp(url+1, "l") ==0){
      move_left();
    }
     else if (strcmp(url+1, "r") ==0){
      move_right();
    }
     else if (strcmp(url+1, "stop") ==0){
      move_stop();
    }
      else if (strcmp(url+1, "dance") ==0){
     dance();
    }
    else if (strcmp(url+1, "reset") == 0){
      reset();
    }
    else if (strStarWith(url+1, "mhud") ){ // move head up and down
      getCmd(str); 
      int code = parseCmdParam(g_param);
      doMoveHeadUpDown(code, g_unit, g_sign);
    }

  return false;
}
#define HD_UD_STEP 2
void doMoveHeadUpDown(int code, char u, char s){
  Serial.println("-->code");
  Serial.println(code);
  if (u ==0 || u=='c'){ // degree
    // calculate actual degree
    if (s == '+' )
      code = head_pos_ud + code;
    else if (s == '-')
     code = head_pos_ud -code;
    else if (s != '=')
      return;
       Serial.println(code);
    // validate
    if (code > HEAD_POS_UD_MAX || code < HEAD_POS_UD_MIN)
      return;
     // write
     servo_head_ud.write(code);
     head_pos_ud = code;
     return;
  }else if(u == 's' ){ // step
   if (s == '+' || s==0)
      code = head_pos_ud + code* HD_UD_STEP;
    else if (s == '-')
     code = head_pos_ud -code* HD_UD_STEP;
    else 
      return;
     if (code > HEAD_POS_UD_MAX || code < HEAD_POS_UD_MIN)
      return;
     servo_head_ud.write(code);
     head_pos_ud = code;
     return;
  }
   return;
}
void reset(){
  move_stop();
    servo_head_lr.write(HEAD_INIT_POS_LR);
  servo_head_ud.write(HEAD_INIT_POS_UD);
   head_pos_ud = HEAD_INIT_POS_UD;
   head_pos_lr = HEAD_INIT_POS_LR;
   
   servo_arm_left.write(0);
   servo_arm_right.write(0);
}
#define HD_STEP 5
void head_up(int n, int d, int s){
   // up
   int i;
    if (head_pos_ud > HEAD_POS_UD_MAX- s || head_pos_ud < HEAD_POS_UD_MIN + s)
            return;
      
       for ( i = head_pos_ud-s; i>=head_pos_ud- n; i=i-s){
        servo_head_ud.write(i);
        if (i > HEAD_POS_UD_MAX- s || i < HEAD_POS_UD_MIN + s)
            break;
        delay(d);
      }
      head_pos_ud = i;
}
void head_down(int n, int d, int s){
   // down
   int i;
         if (head_pos_ud > HEAD_POS_UD_MAX- s || head_pos_ud < HEAD_POS_UD_MIN + s)
            return;
       for ( i = head_pos_ud+s; i<=head_pos_ud+n; i=i+s){
        servo_head_ud.write(i);
        if (i > HEAD_POS_UD_MAX- s || i < HEAD_POS_UD_MIN + s)
            break;
        delay(d);
      }
      head_pos_ud = i;
}
void doMoveHead(int c){

  int i=0;
  //Serial.println("doMoveHead");
  Serial.println(c);
  Serial.println(head_pos_lr);
    if (c == 12){
      // turn right
     // if (head_pos_lr > HEAD_POS_LR_MAX- HD_STEP || head_pos_lr < HEAD_POS_LR_MIN + HD_STEP)
       // return;
      for ( i = head_pos_lr; i>head_pos_lr- HD_STEP; i--){
        servo_head_lr.write(i);
      }
      head_pos_lr = i;
      //Serial.println(head_pos_lr);
    }else if (c == 11){
            // turn left
       //        if (head_pos_lr > HEAD_POS_LR_MAX- HD_STEP || head_pos_lr < HEAD_POS_LR_MIN + HD_STEP)
        //return;
        for ( i = head_pos_lr; i<head_pos_lr+ HD_STEP; i++){
        servo_head_lr.write(i);
      }
      head_pos_lr = i;
 //Serial.println(head_pos_lr);
    }else if (c == 13){
      // up
      //   if (head_pos_ud > HEAD_POS_UD_MAX- HD_STEP || head_pos_ud < HEAD_POS_UD_MIN + HD_STEP)
        //return;
       for ( i = head_pos_ud; i>head_pos_ud- HD_STEP; i--){
        servo_head_ud.write(i);
      }
      head_pos_ud = i;
    //  Serial.println(head_pos_ud);
    }else if (c == 14){
      // down
   //   if (head_pos_ud > HEAD_POS_UD_MAX- HD_STEP || head_pos_ud < HEAD_POS_UD_MIN + HD_STEP)
     //   return;
      for ( i = head_pos_ud; i<head_pos_ud+ HD_STEP; i++){
        servo_head_ud.write(i);
      }
      head_pos_ud = i;
    //  Serial.println(head_pos_ud;
    }
     else if (c == 15){
      // shake
  // int org = head_pos_lr;
     for ( i = head_pos_lr; i<HEAD_POS_LR_MAX; i++){
        servo_head_lr.write(i);
           delay(20);
      }
      delay(50);
      for ( ;i>HEAD_POS_LR_MIN; i--){
        servo_head_lr.write(i);
           delay(20);
      }
        delay(50);
          for ( ;i<head_pos_lr; i++){
        servo_head_lr.write(i);
           delay(20);
      }
      
    }
 
}

void dance(){
 /* 
    servo_head_ud.write(50);
    head_pos_ud =50;
    */
    reset();
    int pos = head_pos_ud;
  for (int i = 0; i< 3; i++){
   move_left();
  // delay(50);
   
  servo_arm_left.write(120); // left low
  servo_arm_right.write(180); // right high
 
  servo_head_ud.write(100);
/*  if (head_pos_ud -30 > 0){
   servo_head_ud.write(head_pos_ud -30);
   head_pos_ud -=30;
  }*/
   
  delay(1000);
  
   move_right();
  //  delay(50);
  servo_arm_left.write(0);  // left high
  servo_arm_right.write(45); // right low
  servo_head_ud.write(130);
  /* if (head_pos_ud +30 < 60){
   servo_head_ud.write(head_pos_ud +30);
   head_pos_ud +=30;
  }
   */

  delay(1000);
  
  }
  move_stop();
//  delay(5000);
  
   servo_head_ud.write(pos);
    head_pos_ud =pos;
}


void setup() {
 
  servo_head_lr.attach(SERVO_HEAD_LR_PIN);  // attaches the servo on pin 9 to the servo object 
  servo_head_ud.attach(SERVO_HEAD_UD_PIN); 
  servo_wheel_left.attach(SERVO_WHEEL_LEFT_PIN);
  servo_wheel_right.attach(SERVO_WHEEL_RIGHT_PIN);
  servo_arm_left.attach(SERVO_ARM_LEFT_PIN);
  servo_arm_right.attach(SERVO_ARM_RIGHT_PIN);


  servo_head_lr.write(HEAD_INIT_POS_LR);
  servo_head_ud.write(HEAD_INIT_POS_UD);
   head_pos_ud = HEAD_INIT_POS_UD;
   head_pos_lr = HEAD_INIT_POS_LR;
   
   servo_arm_left.write(0);
   servo_arm_right.write(0);
 //  delay(1000);
 //  servo_head_lr.write(180);
 //  servo_head_ud.write(100);
  //  servo_head_lr.write(90);
 //      delay(1000);
        //    servo_head_ud.write(90);
   // servo_head_lr.write(120);
//servo_arm_left.write(0);delay(1000);
//servo_arm_left.write(120);delay(1000);servo_arm_left.write(0);
/*for (int i =0; i <=120; i++){
  servo_arm_left.write(i);
  delay(50);
}
for (int i =120; i >=0; i--){
    servo_arm_left.write(i);
  delay(50);
}*/
 // servo_arm_right.write(45);
 // delay(1000);
 // servo_arm_right.write(180);
  /*
for (int i =0; i <=90; i++){
  servo_arm_right.write(i);
  delay(50);//delay(1000);servo_arm_right.write(90);
}
for (int i =90; i >=0; i--){
  servo_arm_right.write(i);
  delay(50);//delay(1000);servo_arm_right.write(90);
}*/
//dance();

  /*for (int i = 1; i< 20; i++){
  servo_head_ud.write(i);
  delay(100);
  }*/
 
  // Initialize WiServer and have it use the sendMyPage function to serve pages
  WiServer.init(sendMyPage);
  
  // Enable Serial output and ask WiServer to generate log messages (optional)
  Serial.begin(9600);
  //WiServer.enableVerboseMode(true);
 //  Serial.println("---h---");
}
int count = 0;
void loop(){

  if (count == 1000)
   {
     count=0;
     //Serial.print("#");
   }
  else
  count++;
 
  // Run WiServer
  WiServer.server_task();

  delay(10);
}

