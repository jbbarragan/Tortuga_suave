#include <Arduino.h>
// Arduino-ESP32 3.x. Seis PWM LEDC independientes a 50 Hz.
// Orden: T1,P1,D1,T2,P2,D2. GPIO, no numeros fisicos de cabecera.
const uint8_t SERVO[6]={1,2,4,5,6,7};
const uint8_t IN1=8, IN2=9, VENT=10, STOP=11, START=12;
// Escape 2/2 normalmente abierto: HIGH energiza bobina y CIERRA escape.
// GPIO VENT acciona MOSFET con diodo; nunca conectar bobina al GPIO.
const uint16_t pulse[6][3]={
 {1000,1250,1500},{1000,1250,1500},{1000,1250,1500},
 {1000,1250,1500},{1000,1250,1500},{1000,1250,1500}};
// Valores provisionales para servo 180 grados, 1000..2000 us.
// Calibrar por separado las posiciones fisicas 0/45/90 de cada valvula.
// Para servos invertidos, invertir/calibrar cada fila, no intercambiar canales.
struct Step { const char* name; uint8_t pos[3]; bool pump; uint32_t ms; };
const Step seq[]={
 {"Inflar T",     {1,0,0},true,2000},
 {"Desinflar T",  {2,0,0},false,1000},
 {"Inflar D+P",   {0,1,1},true,2000},
 {"Desinflar P",  {0,2,0},false,1000},
 {"Desinflar D",  {0,0,2},false,1000}
};
const uint32_t SETTLE_MS=250; // aumentar si el servo cargado tarda mas
// Dos barreras por estado: cerrar todos, posicionar seleccionados, actuar.
enum Phase { IDLE, ISOLATE, POSITION, ACTIVE, FAULT };
Phase phase=IDLE;
uint8_t stepIndex=0;
uint32_t since=0, startSince=0;
bool startWasHigh=true, startArmed=true, pwmOK=false;
bool valve(uint8_t i,uint8_t p){
 return ledcWrite(SERVO[i],(uint32_t(pulse[i][p])*16383UL+10000UL)/20000UL);
}
void pumpOff(){ digitalWrite(IN1,LOW); digitalWrite(IN2,LOW); }
bool all(uint8_t p){ bool ok=true; for(uint8_t i=0;i<6;i++) ok=valve(i,p)&&ok; return ok; }
void halt(bool fault=false){
 pumpOff(); digitalWrite(VENT,LOW); // escape abierto
 bool ok=all(2); // liberar todas las vias, salvo fallo mecanico/electrico
 phase=(fault||!ok||phase==FAULT)?FAULT:IDLE;
 Serial.println(phase==FAULT?"FALLO PWM: bomba inhibida; revisar":"PARO: bomba OFF, escape abierto, seis vias abiertas");
}
void enter(uint8_t s){
 pumpOff();
 // Mantener estado previo del escape mientras se cierran las seis vias.
 // Evita descargar D durante su retencion al cambiar de etapa.
 stepIndex=s; since=millis(); phase=ISOLATE;
 if(!all(0)) halt(true);
}
void beginCycle(){if(phase==IDLE&&pwmOK&&digitalRead(STOP)==LOW) enter(0);}
void setup(){
 pinMode(IN1,OUTPUT); pinMode(IN2,OUTPUT); pumpOff();
 pinMode(VENT,OUTPUT); digitalWrite(VENT,LOW);
 // STOP: contacto NC a GND. Pulsado o cable roto => HIGH => paro.
 pinMode(STOP,INPUT_PULLUP); pinMode(START,INPUT_PULLUP);
 Serial.begin(115200);
 pwmOK=true;
 for(uint8_t i=0;i<6;i++) pwmOK=ledcAttachChannel(SERVO[i],50,14,i)&&pwmOK;
 halt(!pwmOK);
 Serial.println("s = iniciar; x = parar. No arranca automaticamente.");
}
void loop(){
 uint32_t now=millis();
 if(digitalRead(STOP)==HIGH){
   if(phase!=IDLE&&phase!=FAULT) halt();
   startArmed=false;
 }
 bool high=digitalRead(START)==HIGH;
 if(high){startArmed=true; startSince=now;}
 if(!high&&startWasHigh) startSince=now;
 if(!high&&startArmed&&uint32_t(now-startSince)>=30){startArmed=false;beginCycle();}
 startWasHigh=high;
 // Paro domina incluso cuando hay varios comandos pendientes.
 bool requestStart=false,requestStop=false;
 while(Serial.available()){char c=Serial.read();requestStart|=(c=='s');requestStop|=(c=='x');}
 if(requestStop) halt(); else if(requestStart) beginCycle();
 if(phase==ISOLATE&&uint32_t(now-since)>=SETTLE_MS){
   digitalWrite(VENT,seq[stepIndex].pump?HIGH:LOW);
   bool ok=true;
   for(uint8_t i=0;i<6;i++) ok=valve(i,seq[stepIndex].pos[i%3])&&ok;
   if(!ok){halt(true);return;}
   phase=POSITION; since=now;
 }else if(phase==POSITION&&uint32_t(now-since)>=SETTLE_MS){
   digitalWrite(IN2,LOW); digitalWrite(IN1,seq[stepIndex].pump?HIGH:LOW);
   phase=ACTIVE; since=now; Serial.println(seq[stepIndex].name);
 }else if(phase==ACTIVE&&uint32_t(now-since)>=seq[stepIndex].ms){
   enter((stepIndex+1)%5);
 }
}
