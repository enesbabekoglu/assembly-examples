ORG 100h

JMP START

;DATA
number      DB 13 ;Kontrol edilecek sayi
result      DB ? ;1: Asal, 0: Degil

;CODE
START:
    MOV AL, number ;Sayiyi al
    CALL CHECK_PRIME ;Alt programi cagir
    MOV result, DL ;Sonucu kaydet
    RET ;Cikis

CHECK_PRIME:
    CMP AL, 2 ;2'den kucuk mu
    JB NOT_PRIME ;Degilse atla

    MOV CL, AL ;Sayiyi sakla
    MOV BL, 2 ;Bolen 2'den baslar

CHECK_LOOP:
    CMP BL, CL ;Bolen sayiya ulasti mi
    JAE IS_PRIME ;Ulastiysa asaldir

    MOV AH, 0 ;Kalan temizle
    MOV AL, CL ;Bolunen geri yukle
    DIV BL ;Bolme yap
    
    CMP AH, 0 ;Kalan 0 mi
    JZ NOT_PRIME ;Tam bolundu asal degil

    INC BL ;Sonraki bolen
    JMP CHECK_LOOP ;Donguya don

IS_PRIME:
    MOV DL, 1 ;Sonuc 1 (Asal)
    RET

NOT_PRIME:
    MOV DL, 0 ;Sonuc 0 (Degil)
    RET