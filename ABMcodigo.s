#include <xc.inc>

GLOBAL ADC_Init

PSECT adc_code, class=CODE, reloc=2


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


END


