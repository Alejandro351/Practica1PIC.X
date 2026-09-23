#include <xc.inc>

GLOBAL ADC_Init

PSECT adc_code, class=CODE, reloc=2
PSECT udata_acs

ADC_H: DS 1
ADC_L: DS 1

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


END