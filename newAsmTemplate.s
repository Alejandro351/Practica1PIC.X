#include <xc.inc>

; CONFIGURACION GENERAL
CONFIG FOSC   = INTOSCIO_EC
CONFIG WDT    = OFF
CONFIG LVP    = OFF
CONFIG PBADEN = OFF
CONFIG MCLRE  = ON
CONFIG XINST  = OFF

; Variables
PSECT udata_acs

UnidadF:        DS 1
Actualizar:     DS 1
Digito:         DS 1
Valor:          DS 1
Decenas:        DS 1
Unidades:       DS 1
SegDec:         DS 1
SegUni:         DS 1
Indice:         DS 1

ADC_H:          DS 1
ADC_L:          DS 1
TempC:          DS 1
TempF:          DS 1
Temp4:          DS 1
Resto:          DS 1
Cociente:       DS 1
ContMuestra:    DS 1
PedirADC:       DS 1

VentAuto:       DS 1
AlarmaManual:   DS 1


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

    ; Cambiar estado de alarma manual
    BTG AlarmaManual, 0, c

    ; Actualizar LED
    CALL Actualizar_LED

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
    GOTO Revisar_Timer0

    ; Cambiar entre Celsius y Fahrenheit
    BTG UnidadF, 0, c

    ; Actualizar lo que se muestra
    BSF Actualizar, 0, c

    ; Limpiar bandera
    BCF INTCON3, 1, c


Revisar_Timer0:

    ; Revisar bandera de Timer0
    BTFSS INTCON, 2, c
    GOTO Fin_ISR

    ; Recargar Timer0
    MOVLW 0xFF
    MOVWF TMR0H, c

    MOVLW 0x06
    MOVWF TMR0L, c

    ; Limpiar bandera
    BCF INTCON, 2, c

    ; Llamado de multiplexacion
    CALL Multiplexar

    ; Tiempo para nueva muestra
    DECFSZ ContMuestra, F, c
    GOTO Fin_ISR

    ; Reiniciar contador
    MOVLW 250
    MOVWF ContMuestra, c

    ; Pedir una nueva lectura
    BSF PedirADC, 0, c


Fin_ISR:

    RETFIE 1


; Config Inicial

Inicio:

    ; Trabajar sin prioridades
    BCF RCON, 7, c

    ; Oscilador interno a 8 MHz
    MOVLW 01110010B
    MOVWF OSCCON, c

    ; Limpiar salidas
    CLRF LATA, c
    CLRF LATC, c
    CLRF LATD, c

    ; Iniciar en Celsius
    CLRF UnidadF, c
    CLRF Actualizar, c

    ; Estados iniciales
    CLRF VentAuto, c
    CLRF AlarmaManual, c
    CLRF PedirADC, c
    CLRF Digito, c
    CLRF Decenas, c
    CLRF Unidades, c

    ; RA0/AN0 como entrada
    BSF TRISA, 0, c

    ; RA1 display de decenas
    BCF TRISA, 1, c

    ; Botones como entradas
    BSF TRISB, 0, c
    BSF TRISB, 1, c
    BSF TRISB, 2, c

    ; LED y ventilador como salidas
    BCF TRISC, 0, c
    BCF TRISC, 1, c

    ; RC2 display de unidades
    BCF TRISC, 2, c

    ; RD0-RD6 segmentos a-g
    MOVLW 10000000B
    MOVWF TRISD, c

    ; Comparadores apagados
    MOVLW 00000111B
    MOVWF CMCON, c


    ; Config ADC

    ; AN0 analogico y los demas digitales
    MOVLW 00001110B
    MOVWF ADCON1, c

    ; Resultado justificado a la izquierda
    ; Tiempo de adquisicion 4 TAD
    ; Reloj ADC Fosc/32
    MOVLW 00010010B
    MOVWF ADCON2, c

    ; Seleccionar AN0 y encender ADC
    MOVLW 00000001B
    MOVWF ADCON0, c


    ; Valores iniciales de los displays
    MOVLW 0x3F
    MOVWF SegDec, c
    MOVWF SegUni, c


    ; Config Timer0

    MOVLW 00000011B
    MOVWF T0CON, c

    ; Valor inicial Timer0
    MOVLW 0xFF
    MOVWF TMR0H, c

    MOVLW 0x06
    MOVWF TMR0L, c

    ; Contador para nueva lectura
    MOVLW 250
    MOVWF ContMuestra, c


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

    ; Habilitar interrupcion Timer0
    BSF INTCON, 5, c

    ; Encender Timer0
    BSF T0CON, 7, c

    ; Pedir primera lectura
    BSF PedirADC, 0, c

    ; Habilitar interrupciones globales
    BSF INTCON, 7, c


; --- BUCLE PRINCIPAL

Principal:

    ; Revisar si se necesita una nueva lectura
    BTFSC PedirADC, 0, c
    CALL Leer_ADC

    ; Revisar si se debe actualizar el display
    BTFSC Actualizar, 0, c
    CALL Preparar_Display

    GOTO Principal


; --- ADC

Leer_ADC:

    ; Limpiar solicitud ADC
    BCF PedirADC, 0, c

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

    ; Calcular Celsius
    CALL Calcular_Celsius

    ; Revisar umbral de temperatura
    CALL Control_Temperatura

    ; Calcular Fahrenheit
    CALL Calcular_Fahrenheit

    ; Actualizar display
    BSF Actualizar, 0, c

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

    BTFSS STATUS, 0, c
    GOTO Fin_Celsius

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

    ; Resto = TempC por 4
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


; --- Control automatico

Control_Temperatura:

    ; Revisar si TempC es 25 o mayor
    MOVLW 25
    SUBWF TempC, W, c

    BTFSS STATUS, 0, c
    GOTO Temperatura_Baja


    ; Activacion automatica
    BSF VentAuto, 0, c

    ; Encender ventilador
    BSF LATC, 1, c

    ; Actualizar LED
    CALL Actualizar_LED

    RETURN


Temperatura_Baja:

    ; Revisar si el ventilador estaba en automatico
    BTFSS VentAuto, 0, c
    GOTO Revisar_LED

    ; Apagar ventilador automatico
    BCF LATC, 1, c

    ; Quitar estado automatico
    BCF VentAuto, 0, c


Revisar_LED:

    CALL Actualizar_LED

    RETURN


Actualizar_LED:

    ; Si hay alarma por temperatura mantener LED encendido
    BTFSC VentAuto, 0, c
    GOTO Encender_LED

    ; Revisar alarma manual
    BTFSC AlarmaManual, 0, c
    GOTO Encender_LED

    ; Si no hay ninguna alarma apagar LED
    BCF LATC, 0, c
    RETURN


Encender_LED:

    BSF LATC, 0, c

    RETURN


; --- Separar unidades y decenas

Separar_Digitos:

    CLRF Decenas, c

    MOVF Valor, W, c
    MOVWF Unidades, c


BCD:

    MOVLW 10
    SUBWF Unidades, W, c

    BTFSS STATUS, 0, c
    GOTO Fin_BCD

    MOVWF Unidades, c
    INCF Decenas, F, c

    GOTO BCD


Fin_BCD:

    RETURN


Tabla_7Seg:

    MOVWF Indice, c

    MOVF Indice, W, c
    XORLW 0
    BTFSC STATUS, 2, c
    RETLW 0x3F

    MOVF Indice, W, c
    XORLW 1
    BTFSC STATUS, 2, c
    RETLW 0x06

    MOVF Indice, W, c
    XORLW 2
    BTFSC STATUS, 2, c
    RETLW 0x5B

    MOVF Indice, W, c
    XORLW 3
    BTFSC STATUS, 2, c
    RETLW 0x4F

    MOVF Indice, W, c
    XORLW 4
    BTFSC STATUS, 2, c
    RETLW 0x66

    MOVF Indice, W, c
    XORLW 5
    BTFSC STATUS, 2, c
    RETLW 0x6D

    MOVF Indice, W, c
    XORLW 6
    BTFSC STATUS, 2, c
    RETLW 0x7D

    MOVF Indice, W, c
    XORLW 7
    BTFSC STATUS, 2, c
    RETLW 0x07

    MOVF Indice, W, c
    XORLW 8
    BTFSC STATUS, 2, c
    RETLW 0x7F

    MOVF Indice, W, c
    XORLW 9
    BTFSC STATUS, 2, c
    RETLW 0x6F

    RETLW 0x00


Preparar_Display:

    ; Actualizar el display
    BCF Actualizar, 0, c

    ; Revisar si esta en Celsius o Fahrenheit
    BTFSC UnidadF, 0, c
    GOTO Mostrar_F

    ; Mostrar Celsius
    MOVF TempC, W, c
    GOTO Guardar_Valor


Mostrar_F:

    ; Mostrar Fahrenheit
    MOVF TempF, W, c


Guardar_Valor:

    MOVWF Valor, c

    ; Separar decenas y unidades
    CALL Separar_Digitos

    ; Obtener segmentos para decenas
    MOVF Decenas, W, c
    CALL Tabla_7Seg
    MOVWF SegDec, c

    ; Obtener segmentos para unidades
    MOVF Unidades, W, c
    CALL Tabla_7Seg
    MOVWF SegUni, c

    RETURN


Multiplexar:

    ; Apagar ambos displays
    BCF LATA, 1, c
    BCF LATC, 2, c

    ; Cambiar de display
    BTG Digito, 0, c

    BTFSC Digito, 0, c
    GOTO Mostrar_Unidades


Mostrar_Decenas:

    ; Cargar segmentos de decenas
    MOVF SegDec, W, c
    MOVWF LATD, c

    ; Encender display de decenas
    BSF LATA, 1, c

    RETURN


Mostrar_Unidades:

    ; Cargar segmentos de unidades
    MOVF SegUni, W, c
    MOVWF LATD, c

    ; Encender display de unidades
    BSF LATC, 2, c

    RETURN


END