ORG 100h

JMP START

;DATA
numbers     DB 20, 36, 59, 85, 13 ;sayilar
min_value   DB ? ;Sonuc yeri

;CODE
START:
    LEA SI, numbers ;Dizinin baslangic adresini al
    MOV CX, 5 ;Dongu sayaci (5 eleman)
    
    MOV AL, [SI] ;Ilk elemani en kucuk kabul et
    
    INC SI ;Sonraki elemana gec
    DEC CX ;Sayaci azalt

COMPARE_LOOP:
    CMP CX, 0 ;Sayac bitti mi
    JZ FINISH ;Bittiyse cýk

    MOV BL, [SI] ;Siradaki sayiyi al
    CMP BL, AL ;Mevcut en kucukle karsilastir
    JAE NEXT ;Eger buyuk veya esitse atla

    MOV AL, BL ;Daha kucukse AL'yi guncelle

NEXT:
    INC SI ;Sonraki adrese gec
    DEC CX ;Sayaci azalt
    JMP COMPARE_LOOP

FINISH:
    MOV min_value, AL ;Sonucu bellege yaz
    RET