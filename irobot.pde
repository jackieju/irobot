/*
 * A simple sketch that uses WiServer to serve a web page
 */


#include <WiServer.h>
#include <Servo.h> 
 // create servo object to control a servo 
 // a maximum of eight servo objects can be created 
Servo servo_head_lr;   // left and right 30 is center, can be 0 to 60
Servo servo_head_ud; // up and down 0 is top, 58 is horizon, can be 0 to 60
#define MOV_HEAD_LEFT 11
#define MOV-HEAD_RIGHT 12
#define MOV_HEAD_UP 13
#define MOV_HEAD_DOWN 14
int head_pos_lr = 30;
int head_pos_ud = 10;
#define HEAD_POS_LR_MAX  60
#define HEAD_POS_LR_MIN 0
#define HEAD_POS_UD_MAX 73
#define HEAD_POS_UD_MIN 0

 
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
     
    Serial.println(URL);

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

// process str to get a word before '?' or '/', by set it to 0
char* getWord(char* str){
    
    char* p = str;
    char* pp=p;
    
    
    while (*pp != '/' && *pp!='?' && *pp != 0)
    {
      pp = pp+1;
    }
    
    *pp = 0;
        Serial.println("getWord:");
         Serial.println(str);
    return pp+1;
}
boolean parseCmd(char* url)
{

  if (url[0] != '/')
    return false;
    
   int len = strlen(url);
   if (len <= 1)
     return false;
     
   char* p = getWord(url+1);
   
    if (strcmp(url+1, "mh")==0){
      char *pp = getWord(p);
      int code = atoi(p);
      doMoveHead(code);
      return true;
    }
  return false;
}

void doMoveHead(int c){
  int i=0;
  Serial.println("doMoveHead");
  Serial.println(c);
    if (c == 12){
      // turn left
      if (head_pos_lr > HEAD_POS_LR_MAX-3 || head_pos_lr < HEAD_POS_LR_MIN +3)
        return;
      for ( i = head_pos_lr; i>head_pos_lr-3; i--){
        servo_head_lr.write(i);
      }
      head_pos_lr = i;
      Serial.println(head_pos_lr);
    }else if (c == 11){
            // turn right
               if (head_pos_lr > HEAD_POS_LR_MAX-3 || head_pos_lr < HEAD_POS_LR_MIN +3)
        return;
        for ( i = head_pos_lr; i<head_pos_lr+3; i++){
        servo_head_lr.write(i);
      }
      head_pos_lr = i;
 Serial.println(head_pos_lr);
    }else if (c == 13){
      // up
         if (head_pos_ud > HEAD_POS_UD_MAX-3 || head_pos_ud < HEAD_POS_UD_MIN +3)
        return;
       for ( i = head_pos_ud; i>head_pos_ud-3; i--){
        servo_head_ud.write(i);
      }
      head_pos_ud = i;
    }else if (c == 14){
      // down
      if (head_pos_ud > HEAD_POS_UD_MAX-3 || head_pos_ud < HEAD_POS_UD_MIN +3)
        return;
      for ( i = head_pos_ud; i<head_pos_ud+3; i++){
        servo_head_ud.write(i);
      }
      head_pos_ud = i;
    }
    
 
}
void setup() {
 
  servo_head_lr.attach(9);  // attaches the servo on pin 9 to the servo object 
  servo_head_ud.attach(6);  
  servo_head_lr.write(30);
  servo_head_ud.write(10);
  
  // Initialize WiServer and have it use the sendMyPage function to serve pages
  WiServer.init(sendMyPage);
  
  // Enable Serial output and ask WiServer to generate log messages (optional)
  Serial.begin(9600);
  //WiServer.enableVerboseMode(true);
   Serial.println("---h---");
}
int count = 0;
void loop(){
  if (count == 1000)
   {
     count=0;
     Serial.print("#");
   }
  else
  count++;
 
  // Run WiServer
  WiServer.server_task();

  delay(10);
}

