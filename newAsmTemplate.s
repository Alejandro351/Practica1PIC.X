#include <xc.inc>

; CONFIGURACION GENERAL
CONFIG FOSC   = INTOSCIO_EC
CONFIG WDT    = OFF
CONFIG LVP    = OFF
CONFIG PBADEN = OFF
CONFIG MCLRE  = ON
CONFIG XINST  = OFF

; Variables 
UnidadF:       DS 1	
PSECT udata_acs		
Digito:      DS 1
Valor:       DS 1
Unidades:    DS 1
SegDec:      DS 1
SegUni:      DS 1
Indice:      DS 1

; Vector Reset
PSECT resetVec, class=CODE, reloc=2
ORG 0x0000
GOTO Inicio

; Vector interrupcion
PSECT intVec, class=CODE, reloc=2

ORG 0x0008
GOTO ISR



; Codigo Principal
PSECT main_code, class=CODE, reloc=2



; Interrupciones externas

ISR:
    ; Revisar INT0
    BTFSS INTCON, 1, c
    GOTO Revisar_INT1
    
    ; Cambiar estado del LED
    BTG LATC, 0, c
    
    ; Limpiar bandera
    BCF INTCON, 1, c

Revisar_INT1:
    ; Revisar INT1
    BTFSS INTCON3, 0, c
    GOTO Revisar_INT2
    
    ; Cambiar estado del ventilador
    BTG LATC, 1, c
    
    ; Limpiar bandera
    BCF INTCON3, 0, c

Revisar_INT2:
    ; Revisar INT2
    BTFSS INTCON3, 1, c
    GOTO Fin_ISR

    ; Cambiar entre Celsius y Fahrenheit
    BTG UnidadF, 0, c

    ; Limpiar bandera
    BCF INTCON3, 1, c

Fin_ISR:
    RETFIE 1
    
; Config Inicial

Inicio:
    ; Trabajar sin prioridades
    BCF RCON, 7, c

    ; Oscilador interno a 8 MHz
    MOVLW 01110010B
    MOVWF OSCCON, c

    ; LED y ventilador apagados
    CLRF LATC, c

    ; Iniciar en Celsius
    CLRF UnidadF, c

    ; Botones como entradas
    BSF TRISB, 0, c
    BSF TRISB, 1, c
    BSF TRISB, 2, c

    ; LED y ventilador como salidas
    BCF TRISC, 0, c
    BCF TRISC, 1, c

    ; Limpiar banderas y permisos
    CLRF INTCON, c
    CLRF INTCON3, c

    ; Interrupciones por flanco de bajada
    MOVLW 10000000B
    MOVWF INTCON2, c

    ; Habilitar INT0
    BSF INTCON, 4, c

    ; Habilitar INT1
    BSF INTCON3, 3, c

    ; Habilitar INT2
    BSF INTCON3, 4, c

    ; Habilitar interrupciones globales
    BSF INTCON, 7, c

; --- BUCLE PRINCIPAL
Principal:
    GOTO Principal
    
; --- ADC
GLOBAL ADC_Init
PSECT adc_code, class=CODE, reloc=2

ADC_Init:
    ; RA0/AN0 como entrada
    BSF TRISA, 0, c

    ; AN0 analogico
    MOVLW 00001110B
    MOVWF ADCON1, c

    ; Reloj ADC 
    MOVLW 00010010B
    MOVWF ADCON2, c

    ; Encender ADC
    MOVLW 00000001B
    MOVWF ADCON0, c

    RETURN

; --- Visualizacion

ConfigurarDisplays:
    ; RA1 display de decenas
    BCF TRISA, 1, c

    ; RC2 display de unidades
    BCF TRISC, 2, c

    ; RD0-RD6 controlan segmentos a-g
    MOVLW 10000000B
    MOVWF TRISD, c

    ; Apagar displays inicialmente
    BCF LATA, 1, c
    BCF LATC, 2, c

    CLRF Digito, c
    CLRF Decenas, c
    CLRF Unidades, c

    RETURN

; --- Separar unidades y decenas

Separar_Digitos:
    CLRF Decenas, c
    MOVF Valor, W, c
    MOVWF Unidades, c
    
BCD:
