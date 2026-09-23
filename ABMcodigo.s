#include <xc.inc>

GLOBAL ADC_Init

PSECT adc_code, class=CODE, reloc=2
PSECT udata_acs

ADC_H: DS 1
ADC_L: DS 1 
TempC: DS 1
TempF: DS 1
Temp4: DS 1
Resto: DS 1
Cociente: DS 1
ContMuestra: DS 1
PedirADC: DS 1
ContMuestra: DS 1
PedirADC: DS 1

ADC_Init:

    ; RA0/AN0 como entrada
    BSF TRISA, 0, c

    ; Referencias:
    ; VREF+ = VDD
    ; VREF- = VSS
    ; AN0 analogico y los demas digitales
    MOVLW 00001110B
    MOVWF ADCON1, c

    ; Resultado justificado a la izquierda
    ; Tiempo de adquisicion = 4 TAD
    ; Reloj ADC = Fosc/32
    MOVLW 00010010B
    MOVWF ADCON2, c

   ; Seleccionar AN0
    ; GO/DONE inicialmente en 0
    ; Encender ADC
    MOVLW 00000001B
    MOVWF ADCON0, c

    RETURN



   Leer_ADC:

    ; Iniciar conversion
    BSF ADCON0, 1, c


Esperar_ADC:

    ; Esperar mientras la conversion esta activa
    BTFSC ADCON0, 1, c
    GOTO Esperar_ADC


    ; Guardar parte alta del resultado
    MOVF ADRESH, W, c
    MOVWF ADC_H, c

    ; Guardar parte baja del resultado
    MOVF ADRESL, W, c
    MOVWF ADC_L, c

    RETURN

    Calcular_Celsius:

    ; Parte alta del ADC por 2
    MOVF ADC_H, W, c
    ADDWF ADC_H, W, c
    MOVWF TempC, c

    ; Tener en cuenta el siguiente bit del ADC
    BTFSC ADC_L, 7, c
    INCF TempC, F, c

    ; Limitar la temperatura a 99
    MOVLW 100
    SUBWF TempC, W, c
    ; Si es menor de 100, dejar el valor
    BTFSS STATUS, 0, c
    GOTO Fin_Celsius
    ; Si es 100 o mayor, dejarlo en 99
    MOVLW 99
    MOVWF TempC, c

Fin_Celsius:
    RETURN
    
    Calcular_Fahrenheit:

    ; Si Celsius es 38 o mayor, Fahrenheit supera 99
    MOVLW 38
    SUBWF TempC, W, c
    BTFSS STATUS, 0, c
    GOTO Hacer_Fahrenheit

    ; Limitar Fahrenheit a 99
    MOVLW 99
    MOVWF TempF, c
    RETURN
    
    
Hacer_Fahrenheit:

    ; Temp4 = TempC por 2
    MOVF TempC, W, c
    ADDWF TempC, W, c
    MOVWF Temp4, c

    ; Temp4 = TempC por 4
    MOVF Temp4, W, c
    ADDWF Temp4, W, c
    MOVWF Resto, c

    ; Cociente empieza en cero
    CLRF Cociente, c
    
Dividir_5:

    ; Intentar restar 5
    MOVLW 5
    SUBWF Resto, W, c

    ; Si el resultado seria negativo termina
    BTFSS STATUS, 0, c
    GOTO Fin_Division

    ; Guardar la resta
    MOVWF Resto, c

    ; Aumentar cociente
    INCF Cociente, F, c

    GOTO Dividir_5
Fin_Division:
    
    ; TempF = TempC + Cociente
    MOVF TempC, W, c
    ADDWF Cociente, W, c
    MOVWF TempF, c

    ; Sumar 32
    MOVLW 32
    ADDWF TempF, F, c

    RETURN
    
    ;Configuracion del Timer
; Configurar Timer0
MOVLW 00000011B
MOVWF T0CON, c

; Cargar valor inicial
MOVLW 0xFF
MOVWF TMR0H, c

MOVLW 0x06
MOVWF TMR0L, c
    
; Contador para nueva lectura
MOVLW 250
MOVWF ContMuestra, c

; Limpiar solicitud ADC
BCF PedirADC, 0, c
    
    
; Limpiar bandera Timer0
BCF INTCON, 2, c

; Habilitar interrupcion Timer0
BSF INTCON, 5, c

; Encender Timer0
BSF T0CON, 7, c
    
Revisar_Timer0:

    ; Revisar bandera de Timer0
    BTFSS INTCON, 2, c
    GOTO Fin_ISR

    ; Recargar Timer0
    MOVLW 0xFF
    MOVWF TMR0H, c

    MOVLW 0x06
    MOVWF TMR0L, c   

END