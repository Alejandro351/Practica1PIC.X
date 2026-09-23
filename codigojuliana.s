PSECT udata_acs

Digito:      DS 1
Valor:       DS 1
Unidades:    DS 1
SegDec:      DS 1
SegUni:      DS 1
Indice:      DS 1


ConfigurarDisplays:

    ; RC2 selecciona display de unidades
    BCF TRISC, 2, c

    ; RD0-RD6 controlan segmentos a-g
    MOVLW 10000000B
    MOVWF TRISD, c

    ; Apagar displays inicialmente
    BCF TRISC, 1, c
    BCF LATC, 2, c

    CLRF Digito, c
    CLRF Decenas, c

    RETURN


