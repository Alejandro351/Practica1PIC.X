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

