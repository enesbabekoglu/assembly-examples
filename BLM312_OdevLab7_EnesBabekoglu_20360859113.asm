; =================================================================
; Ogrenci No  : 20360859113
; Ad Soyad    : ENES BABEKOGLU
; Ders        : BLM312 - Mikroislemciler (Odev 4)
; Konu        : Karekok Hesaplama
; =================================================================

CODE SEGMENT
    ASSUME CS:CODE, DS:CODE, SS:CODE

START:
    ; --- GUVEKLI BASLANGIC VE STACK AYARLARI ---
    CLD             ; Yon bayragini temizle (DI artarak gidecek)
    
    PUSH CS         ; DS registerini Code Segment'e esitle
    POP DS

    CLI             ; Kesmeleri durdur (Stack ayarlarken araya girmesin)
    MOV AX, CS      ; Stack Segmenti (SS) Code Segment ile ayni yap
    MOV SS, AX
    MOV SP, 0FFFEh  ; Stack Pointer'i (SP) segmentin sonuna cek
    STI             ; Kesmeleri tekrar ac

    ; --- BELLEK VE DONGU AYARLARI ---
    MOV AX, 0900h
    MOV ES, AX      ; Hedef Segment = 0900h
    MOV DI, 0200h   ; Hedef Offset  = 0200h

    MOV CX, 101     ; 0-100 arasi toplam 101 sayi
    MOV DX, 0       ; Islenecek sayi (0'dan baslar)

ANA_DONGU:
    MOV BX, DX          ; Sayiyi BX'e al
    CALL KAREKOK_BUL    ; Karekokunu hesapla (Sonuc AL'de)
    STOSB               ; Sonucu [ES:DI]'ye yaz, DI'yi artir
    INC DX              ; Sonraki sayiya gec
    LOOP ANA_DONGU      ; CX bitene kadar devam

    ; --- PROGRAM SONU ---
    MOV AH, 4Ch
    INT 21h

; =================================================================
; ALT PROGRAM: KAREKOK_BUL
; Giris : BX (Sayi) -> Cikis : AL (Karekok Tamsayi)
; Yontem: Tek sayilari (1,3,5...) cikarma
; =================================================================
KAREKOK_BUL PROC
    PUSH BX             ; Registerleri koru
    PUSH SI

    MOV AX, 0           ; Sonuc (Karekok)
    MOV SI, 1           ; Cikarilacak ilk tek sayi

HESAP_DONGUSU:
    CMP BX, SI
    JB BITIR            ; Kalan < Cikan ise bitir

    SUB BX, SI          ; Sayidan tek sayiyi cikar
    ADD SI, 2           ; Sonraki tek sayi (1->3->5...)
    INC AX              ; Sonucu 1 artir
    JMP HESAP_DONGUSU

BITIR:
    POP SI              ; Registerleri geri yukle
    POP BX
    RET
KAREKOK_BUL ENDP

CODE ENDS
END START