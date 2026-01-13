ORG 100H
JMP START

; --- VERI TANIMLAMA ---
MATRIX  DB 13H, 00H, 31H, 33H, 00H, 00H, 00H  ; 7 satir veri
        DB 00H                                 ; 8. satir: sutun parity

ROW_ERR DB 0FFH    ; Hatali satir (0FFH = hata yok)
COL_ERR DB 0FFH    ; Hatali sutun (0FFH = hata yok)

; --- PROGRAM BASLANGICI ---
START:
    MOV AX, CS
    MOV DS, AX

; --- ANA DONGU ---
MAIN_LOOP:
    IN AL, 110              ; Komut oku
    
    CMP AL, 1               ; Giris 1: parity uret
    JE GEN_PARITY
    CMP AL, '1'
    JE GEN_PARITY
    
    CMP AL, 2               ; Giris 2: hata bul
    JE FIND_ERROR
    CMP AL, '2'
    JE FIND_ERROR
    
    JMP MAIN_LOOP

; --- PARITY URETME ---
GEN_PARITY:
    ; Satir parity
    MOV BX, 0
GEN_ROW_LOOP:
    AND BYTE PTR [MATRIX + BX], 7FH   ; Eski parity bitini sil
    MOV AL, [MATRIX + BX]
    CALL COUNT_ONES                    ; 1'leri say
    TEST AL, 1                         ; Tek mi?
    JNZ SKIP_ROW_SET                   ; Tek ise atla
    OR BYTE PTR [MATRIX + BX], 80H     ; Cift ise parity=1
SKIP_ROW_SET:
    INC BX
    CMP BX, 7
    JB GEN_ROW_LOOP

    ; Sutun parity
    MOV BYTE PTR [MATRIX + 7], 0
    MOV SI, 0
    MOV DL, 1                          ; Bit maskesi
GEN_COL_LOOP:
    MOV BX, 0
    MOV CL, 0                          ; 1 sayaci
SUM_COL_GEN:
    MOV AL, [MATRIX + BX]
    TEST AL, DL                        ; Ilgili bit 1 mi?
    JZ BIT_ZERO_GEN
    INC CL
BIT_ZERO_GEN:
    INC BX
    CMP BX, 7                          ; Sadece veri satirlari
    JB SUM_COL_GEN
    
    TEST CL, 1                         ; Tek mi?
    JNZ SKIP_COL_SET
    OR BYTE PTR [MATRIX + 7], DL       ; Cift ise parity=1
SKIP_COL_SET:
    SHL DL, 1
    INC SI
    CMP SI, 7
    JB GEN_COL_LOOP

    MOV AL, 0
    OUT 110, AL
    JMP MAIN_LOOP

; --- HATA BULMA ---
FIND_ERROR:
    MOV ROW_ERR, 0FFH
    MOV COL_ERR, 0FFH

    ; Satir kontrolu
    MOV BX, 0
CHK_ROW_LOOP:
    MOV AL, [MATRIX + BX]
    CALL COUNT_ONES                    ; Parity dahil tum bitleri say
    TEST AL, 1                         ; Tek olmali
    JNZ ROW_IS_OK
    MOV ROW_ERR, BL                    ; Cift ise hata var
ROW_IS_OK:
    INC BX
    CMP BX, 7
    JB CHK_ROW_LOOP

    ; Sutun kontrolu
    MOV SI, 0
    MOV DL, 1
CHK_COL_LOOP:
    MOV BX, 0
    MOV CL, 0
SUM_CHK_BITS:
    MOV AL, [MATRIX + BX]
    TEST AL, DL
    JZ BIT_ZERO_CHK
    INC CL
BIT_ZERO_CHK:
    INC BX
    CMP BX, 8                          ; Parity dahil 8 satir
    JB SUM_CHK_BITS
    
    TEST CL, 1                         ; Tek olmali
    JNZ COL_IS_OK
    MOV AX, SI                         ; Cift ise hata var
    MOV COL_ERR, AL
COL_IS_OK:
    SHL DL, 1
    INC SI
    CMP SI, 7
    JB CHK_COL_LOOP

    ; Sonuc hesapla
    CMP ROW_ERR, 0FFH
    JE NO_ERROR
    CMP COL_ERR, 0FFH
    JE NO_ERROR

    MOV AL, ROW_ERR
    INC AL                             ; 1-7 arasi
    MOV BL, 10
    MUL BL                             ; Satir * 10
    MOV BL, COL_ERR
    INC BL                             ; 1-7 arasi
    ADD AL, BL                         ; Format: satir-sutun (ornek: 23)
    OUT 199, AL
    JMP DONE

NO_ERROR:
    MOV AL, 0
    OUT 199, AL

DONE:
    MOV AL, 0
    OUT 110, AL
    JMP MAIN_LOOP

; --- ALT PROGRAM: 1'LERI SAYMA ---
COUNT_ONES:
    PUSH CX
    PUSH DX
    MOV CX, 8
    MOV DH, 0
CNT_LOOP:
    SHL AL, 1                          ; Bit'i carry'ye kaydir
    JNC NO_INC
    INC DH                             ; 1 ise say
NO_INC:
    LOOP CNT_LOOP
    MOV AL, DH                         ; Sonucu AL'ye koy
    POP DX
    POP CX
    RET

END
