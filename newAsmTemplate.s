#include <xc.inc>

    ;Configuracion general
    CONFIG  FOSC   = INTOSCIO_EC
    CONFIG  WDT    = OFF
    CONFIG  LVP    = OFF
    CONFIG  PBADEN = OFF
    CONFIG  MCLRE  = ON
    CONFIG  XINST  = OFF
    
    ;Inicio
    MOVLW 01110010B ; Oscilador interno a 8 MHz
    MOVWF OSCCON, c
    
    ;Botones como entradas
    BSF TRISB, 0, c	;RB0 Alarma
    BSF TRISB, 1 ,c	;RB1 Ventilador
    BSF TRISB, 2, c	;RB2 Celsius a Farenheit
    
    ;Salidas de los botones
    BCF TRISC, 0, c	;Led alarma
    BCF TRISC, 1, c	;Ventilador 
    
    
    