PSECT udata_acs

Digito:      DS 1
Valor:       DS 1
Unidades:    DS 1
SegDec:      DS 1
SegUni:      DS 1
Indice:      DS 1

ConfigurarDisplays:

    ; RA1 selecciona display de decenas
    BCF TRISA, 1, c

    ; RC2 selecciona display de unidades
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

Separar_Digitos:

    CLRF Decenas, c

    MOVF Valor, W, c
    MOVWF Unidades, c


BCD:
    
    MOVLM 10
    SUBWF Unidades, W,c
    
    BTFSS STATUS, 0, c
    GOTO Fin_BCD
    
    MOVWF Unidades, c
    INCF Decenas, F, c

    GOTO BCD

Fin_BCD:
    
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
    

    ; Ya se va a actualizar el display
    BCF Actualizar, c

    ; Revisar si se muestra celsius o fahrenheit
    BTFSC UnidadF, 0, c
    GOTO Mostrar_F

    ; Mostrar celsius
    MOVF TempC, W
    GOTO Guardar_Valor

Mostrar_F:

    ; Mostrar Fahrenheit
    MOVF TempF, c


Guardar_Valor:

    MOVWF Valor, c

    
  

