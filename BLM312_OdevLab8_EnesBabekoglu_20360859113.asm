; =================================================================
; EMU8086 OZEL AYARLARI (Otomatik Pencere Acma)
; =================================================================
#start=simple.exe#
#start=led_display.exe#

; =================================================================
; Ogrenci No  : 20360859113
; Ad Soyad    : Enes Babekoğlu
; Ders        : BLM312 - Mikroislemciler (Odev 5)
; Konu        : Parity (Eslik) Kontrolu ve Port I/O
; =================================================================

DATA SEGMENT
    ; 10 Adet 32-bit (DoubleWord) rastgele sayi tanimlamasi.
    ; Ilk sayi odevde verilen ornek: 33310013H
    SAYILAR DD 33310013h, 12345678h, 0ABCDEF0h, 0FFFFFFFFh, 00000001h
            DD 10101010h, 88888888h, 77777777h, 55555555h, 11111111h
DATA ENDS

STACK SEGMENT
    DW 128 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

START:
    ; --- SEGMENT AYARLARI ---
    MOV AX, DATA
    MOV DS, AX          ; DS Data Segmenti gosteriyor

    MOV AX, 0700h       ; Hedef Segment (Odevde istenen)
    MOV ES, AX          ; ES = 0700h
    
    ; --- DONGU HAZIRLIK ---
    LEA SI, SAYILAR     ; Kaynak verilerin baslangici (DS:SI)
    MOV DI, 0300h       ; Hedef offset (ES:DI -> 0700:0300)
    MOV CX, 10          ; 10 adet sayi islenecek

HESAPLA_DONGU:
    ; 32-bit sayinin Parity (Eslik) kontrolu
    ; x86 Parity Flag (PF) sadece son islemdeki alt 8 bite bakar.
    ; Bu yuzden 32 biti sikistirarak (XOR yaparak) tek bir byte'a indirgemeliyiz.
    
    MOV AX, [SI]        ; Sayinin alt 16 biti (Low Word)
    MOV BX, [SI+2]      ; Sayinin ust 16 biti (High Word)
    
    XOR AX, BX          ; High ve Low word'u XOR'la (Bitleri ust uste bindir)
    XOR AL, AH          ; AH ve AL'yi XOR'la (Sonucu AL'de topla)
    
    ; PF (Parity Flag) Kontrolu:
    ; Eger sonuc CIFT sayida 1 iceriyorsa PF=1 (JPE - Jump Parity Even)
    ; Eger sonuc TEK  sayida 1 iceriyorsa PF=0 (JPO - Jump Parity Odd)
    
    JPO TEK_ESLIK       ; Eger Tek ise atla
    
CIFT_ESLIK:
    MOV AL, 00h         ; Cift eslik icin 00h
    JMP KAYDET

TEK_ESLIK:
    MOV AL, 01h         ; Tek eslik icin 01h

KAYDET:
    STOSB               ; AL'yi [ES:DI]'ye yaz ve DI'yi 1 artir
    ADD SI, 4           ; Bir sonraki DoubleWord'e gec (4 byte)
    LOOP HESAPLA_DONGU  ; CX bitene kadar devam et

    ; --- PORT KONTROL DONGUSU (SONSUZ) ---
    ; Bellege yazdigimiz sonuclari Port 110'dan gelen veriye gore okuyacagiz.

PORT_DONGU:
    IN AL, 110          ; 'Simple' portundan (110) veri oku
    
    ; Gelen veri kontrolu (1 ile 10 arasinda olmali)
    CMP AL, 1
    JB PORT_DONGU       ; 1'den kucukse (0 gibi) bekle
    CMP AL, 10
    JA PORT_DONGU       ; 10'dan buyukse bekle
    
    ; Bellekten okuma islemi
    ; Giris 1 ise -> 0300h adresini okumaliyiz.
    ; Giris 2 ise -> 0301h adresini okumaliyiz.
    ; Index hesabi: Offset = 0300h + (Giris - 1)
    
    DEC AL              ; 0-based index yap (1->0, 2->1...)
    MOV BL, AL          ; Indexi BL'ye al
    MOV BH, 0           ; BX'i temizle
    
    ; 0700h segmentindeki 0300h + BX adresindeki veriyi oku
    MOV AL, ES:[0300h + BX]
    
    MOV AH, 0           ; AX'i temizle
    OUT 199, AX         ; Sonucu 'LED_Display' portuna (199) yaz
    
    JMP PORT_DONGU      ; Surekli kontrol et

CODE ENDS
END START
