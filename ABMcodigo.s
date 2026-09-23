#include <xc.inc>

GLOBAL ADC_Init

PSECT adc_code, class=CODE, reloc=2


ADC_Init:

    ; RA0/AN0 como entrada para el LM35
    BSF TRISA, 0, c

    ; Pendiente:
    ; configurar ADCON1
    ; configurar ADCON2
    ; configurar ADCON0

    RETURN


END


