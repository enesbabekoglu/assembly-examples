; =================================================================
; OGRENCI BILGILERI
; -----------------------------------------------------------------
; Ogrenci No  : 20360859113
; Ad Soyad    : ENES BABEKOGLU
; Ders Kodu   : BLM312 - Mikroislemciler Laboratuvari
; Odev Konusu : MUL Komutsuz 32-Bit Carpma ve Port Kontrolu
; =================================================================

; =================================================================
; PROGRAMIN AMACI VE CALISMA MANTIGI
; -----------------------------------------------------------------
; Bu program, belirlenen iki adet 32-bitlik sayiyi (SAYI1 ve SAYI2),
; 8086 islemcisinin 'MUL' komutunu kullanmadan, 'Shift and Add'
; (Kaydir ve Ekle) algoritmasi ile carpar.
;
; Olusan 64-bitlik sonuc bellekte tutulur ve Emu8086 sanal portlari
; uzerinden kullaniciya gosterilir.
;
; PORT KULLANIMI:
; - Port 110 (Giris): Sonucun hangi parcasinin goruntulenecegini secer.
;   '1' -> [0-15]   Bitler (Dusuk)
;   '2' -> [16-31]  Bitler (Orta-Dusuk)
;   '3' -> [32-47]  Bitler (Orta-Yuksek)
;   '4' -> [48-63]  Bitler (Yuksek)
; - Port 199 (Cikis): Secilen 16-bitlik sonucu LED panelde gosterir.
; =================================================================

; =================================================================
; EMU8086 SANAL CIHAZ AYARLARI (Otomatik Baslatma)
; =================================================================
#start=simple.exe#
#start=led_display.exe#

DATA SEGMENT
    ; -------------------------------------------------------------
    ; ISLEM YAPILACAK VERILER (32-Bit)
    ; -------------------------------------------------------------
    ; Ozel Test: Ogrenci Numarasi Kullanilarak Olusturulan Degerler
    ; Ogrenci No: 20360859113
    ; 32-bit register'a sigmasi icin ilk 10 hanesini alalim: 2036085911
    
    ; SAYI1 = 2036085911 (Hex: 795E7C97h)
    ; SAYI2 = 2036085911 (Hex: 795E7C97h)
    
    ; ISLEM: 795E7C97h * 795E7C97h
    
    ; Beklenen Sonuc (Decimal): 4,145,645,845,479,079,921
    ; Beklenen Sonuc (Hex)    : 398A 74A6 7986 A111 h
    
    ; Emu8086 Ekraninda (Port 199) Gorunmesi Gerekenler:
    ; '1' (Alt 16)      -> A111
    ; '2' (Orta-Alt)    -> 7986
    ; '3' (Orta-Ust)    -> 74A6
    ; '4' (Ust 16)      -> 398A
    
    ; SAYI1 Tanimlamasi (795E 7C97 h)
    SAYI1_L DW 7C97h    ; Alt (Low) 16 Bit
    SAYI1_H DW 795Eh    ; Ust (High) 16 Bit

    ; SAYI2 Tanimlamasi (795E 7C97 h)
    SAYI2_L DW 7C97h    ; Alt (Low) 16 Bit
    SAYI2_H DW 795Eh    ; Ust (High) 16 Bit

    ; -------------------------------------------------------------
    ; SONUC BELLEK BOLGESI (64-Bit)
    ; -------------------------------------------------------------
    ; Carpim sonucu 4 adet 16-bitlik (DW) hucrede saklanir.
    SONUC   DW 0, 0, 0, 0   ; Toplam 8 Byte (64 Bit)

    ; -------------------------------------------------------------
    ; GECICI DEGISKENLER
    ; -------------------------------------------------------------
    ; Algoritma geregi carpilan sayi sola otelenecegi icin 
    ; 64-bit genisliginde gecici bir alanda (TEMP_A) islenir.
    TEMP_A  DW 0, 0, 0, 0 
    
    ; Carpan sayiyi (SAYI2) bozmamak icin kopyasini burada tutacagiz
    TEMP_CARPAN DW 0, 0  
    
DATA ENDS

CODE SEGMENT
    ASSUME DS:DATA, CS:CODE

START:
    ; Data Segment adresini yukle
    MOV AX, DATA
    MOV DS, AX

    ; *****************************************************************
    ; BOLUM 1: MUL KULLANMADAN CARPMA (SHIFT & ADD ALGORITMASI)
    ; *****************************************************************
    
    ; --- 1.1 Baslangic Durumu Ayarlari ---
    ; Sonuc bellek bolgesini temizle
    MOV WORD PTR [SONUC], 0
    MOV WORD PTR [SONUC+2], 0
    MOV WORD PTR [SONUC+4], 0
    MOV WORD PTR [SONUC+6], 0

    ; SAYI1'i 64-bitlik TEMP_A alanina kopyala
    ; (Alt 32 bit dolu, Ust 32 bit sifir olacak sekilde)
    MOV AX, SAYI1_L
    MOV [TEMP_A], AX        ; TEMP_A[0-15]
    MOV AX, SAYI1_H
    MOV [TEMP_A+2], AX      ; TEMP_A[16-31]
    MOV WORD PTR [TEMP_A+4], 0  ; TEMP_A[32-47] (Sifirla)
    MOV WORD PTR [TEMP_A+6], 0  ; TEMP_A[48-63] (Sifirla)
    
    ; SAYI2'yi TEMP_CARPAN alanina kopyala (SAYI2 orijinal kalsin)
    MOV AX, SAYI2_L
    MOV [TEMP_CARPAN], AX
    MOV AX, SAYI2_H
    MOV [TEMP_CARPAN+2], AX

    ; Dongu Sayaci: 32 bitlik carpma islemi icin 32 adim
    MOV CX, 32

ALGORITMA_DONGUSU:
    ; --- 1.2 Carpan Sayinin (TEMP_CARPAN) LSB Kontrolu ---
    ; TEMP_CARPAN'i saga otele. En sagdaki bit Carry Flag'e (CF) duser.
    ; Islem dogrudan bellek uzerinde yapilir.
    SHR WORD PTR [TEMP_CARPAN+2], 1  ; Ust kismi saga kaydir -> Tasan bit CF olur
    RCR WORD PTR [TEMP_CARPAN], 1    ; Alt kismi CF ile beraber kaydir -> Islem biti CF olur

    JNC TOPLAMA_ATLAMA  ; Eger CF=0 ise (bit 0), toplama yapilmaz.

    ; --- 1.3 Toplama Islemi (Sonuc = Sonuc + TEMP_A) ---
    ; Eger bit 1 ise, o anki agirlikli deger (TEMP_A) sonuca eklenir.
    ; 64-bit toplama islemi parca parca yapilir.
    MOV AX, [TEMP_A]
    ADD [SONUC], AX     ; Alt 16 bit topla

    MOV AX, [TEMP_A+2]
    ADC [SONUC+2], AX   ; Elde varsa ekle

    MOV AX, [TEMP_A+4]
    ADC [SONUC+4], AX   ; Elde varsa ekle

    MOV AX, [TEMP_A+6]
    ADC [SONUC+6], AX   ; Elde varsa ekle

TOPLAMA_ATLAMA:
    ; --- 1.4 Sola Oteleme (TEMP_A = TEMP_A << 1) ---
    ; Bir sonraki bit agirligi icin TEMP_A sola kaydirilir.
    SHL [TEMP_A], 1     ; En alt parcayi sola kaydir -> Tasan CF olur
    RCL [TEMP_A+2], 1   ; CF ile beraber 2. parcayi dondur
    RCL [TEMP_A+4], 1   ; CF ile beraber 3. parcayi dondur
    RCL [TEMP_A+6], 1   ; CF ile beraber 4. parcayi dondur

    ; Donguyu devam ettir
    LOOP ALGORITMA_DONGUSU


    ; *****************************************************************
    ; BOLUM 2: I/O PORT KONTROLU VE GOSTERIM
    ; *****************************************************************
    ; Port 110: Giris Portu (Simple I/O)
    ; Port 199: Cikis Portu (LED Display)

PORT_DINLEME:
    ; Port 110'dan veri oku
    IN AL, 110
    
    ; Girilen degeri kontrol et (Hem Hex hem ASCII destegi)
    
    ; --- Secenek 1: En Alt 16 Bit ---
    CMP AL, 1
    JE GOSTER_BOLUM_1
    CMP AL, 31h         ; Klavye '1' tusu
    JE GOSTER_BOLUM_1

    ; --- Secenek 2: Orta-Alt 16 Bit ---
    CMP AL, 2
    JE GOSTER_BOLUM_2
    CMP AL, 32h         ; Klavye '2' tusu
    JE GOSTER_BOLUM_2

    ; --- Secenek 3: Orta-Ust 16 Bit ---
    CMP AL, 3
    JE GOSTER_BOLUM_3
    CMP AL, 33h         ; Klavye '3' tusu
    JE GOSTER_BOLUM_3
    
    ; --- Secenek 4: En Ust 16 Bit ---
    CMP AL, 4
    JE GOSTER_BOLUM_4
    CMP AL, 34h         ; Klavye '4' tusu
    JE GOSTER_BOLUM_4

    ; Gecerli bir giris yoksa dinlemeye devam et
    JMP PORT_DINLEME

GOSTER_BOLUM_1:
    MOV AX, [SONUC]     ; Sonucun 0-15. bitleri
    OUT 199, AX
    JMP PORT_DINLEME

GOSTER_BOLUM_2:
    MOV AX, [SONUC+2]   ; Sonucun 16-31. bitleri
    OUT 199, AX
    JMP PORT_DINLEME

GOSTER_BOLUM_3:
    MOV AX, [SONUC+4]   ; Sonucun 32-47. bitleri
    OUT 199, AX
    JMP PORT_DINLEME

GOSTER_BOLUM_4:
    MOV AX, [SONUC+6]   ; Sonucun 48-63. bitleri
    OUT 199, AX
    JMP PORT_DINLEME

    ; Programin isletim sistemine donusu (Sonsuz dongu nedeniyle ulasilmaz)
    MOV AH, 4Ch
    INT 21h

CODE ENDS
END START