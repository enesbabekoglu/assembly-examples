ORG 100h

JMP START

;DATA
primes      DB 17, 5, 13, 2, 11 ;Asal sayilar

;CODE
START:
    MOV CX, 5 ;Eleman sayisi
    DEC CX ;Dis dongu (N-1)

OUTER_LOOP:
    PUSH CX ;Sayaci sakla
    LEA SI, primes ;Dizi baslangici

INNER_LOOP:
    MOV AL, [SI] ;Mevcut sayi
    MOV BL, [SI+1] ;Sonraki sayi
    
    CMP AL, BL ;Karsilastir
    JBE SKIP_SWAP ;Siraliysa atla

    MOV [SI], BL ;Yer degistir (swap)
    MOV [SI+1], AL ;Yer degistir (swap)

SKIP_SWAP:
    INC SI ;Sonraki adres
    LOOP INNER_LOOP ;Ic dongu tekrar

    POP CX ;Sayaci yukle
    LOOP OUTER_LOOP ;Dis dongu tekrar

    RET