; -----------------------------------------------------------------
; Ogrenci No  : 20360859113
; Ad Soyad    : ENES BABEKOGLU
; =================================================================

; =================================================================
; BELLEK ADRESI ACIKLAMASI
; -----------------------------------------------------------------
; Siralanacak veriler (dizi), Data Segment'in baslangic adresi olan
; DS:0000h ofset adresinden itibaren bellekte tutulmaktadir.
; Toplam 10 adet 1 byte'lik isaretsiz sayi oldugu icin veriler
; [DS:0000h] ile [DS:0009h] adres araliginda yer alir.
; =================================================================

DATA SEGMENT
    ; Siralanacak 10 adet rastgele isaretsiz sayi (1 Byte)
    SAYILAR DB 20, 3, 60, 8, 59, 1, 13, 22, 5, 100
    
    ; Dizinin eleman sayisi (10 adet)
    BOYUT   DW 10
DATA ENDS

CODE SEGMENT
    ASSUME DS:DATA, CS:CODE

START:
    ; Veri segmentinin adresini ayarla
    MOV AX, DATA    ; Data segmentin adresini AX'e yukle
    MOV DS, AX      ; AX'i DS yazmacina tasi

    ; --- SELECTION SORT (SECMELI SIRALAMA) BASLANGICI ---
    ; Algoritma: Dizinin basindan baslayarak (Current), kalan kýsýmdaki
    ; en kucuk sayiyi (Smallest) bulup yer degistirme mantigi.

    MOV CX, 9       ; Dis dongu sayaci. 10 eleman oldugu icin 9 tur yeterlidir.
                    ; Son eleman zaten mecburen en buyuk kalacaktir.
    
    LEA SI, SAYILAR ; SI yazmaci 'Gecerli' (Current) indeksi tutacak.
                    ; Dizinin baslangic adresini SI'ya yukledik.

DIS_DONGU:
    ; Dis dongu her dondugunde, o anki konumu (SI) en kucuk kabul ederiz.
    MOV BX, SI      ; BX yazmaci 'En Kucuk' (Smallest) sayinin adresini tutacak.

    ; Ic dongu icin hazirlik: Walker = Current + 1
    ; Yani taramaya her zaman SI'dan bir sonraki elemandan baslayacagiz.
    MOV DI, SI      
    INC DI          ; DI yazmaci 'Gezici' (Walker) gorevi gorecek.

    ; Ic dongunun kac kere donecegini hesapla.
    ; Kalan eleman sayisi kadar donmeli (CX degeri bunu tutuyor).
    MOV DX, CX      ; Ic dongu sayaci olarak DX kullanilacak.

IC_DONGU:
    ; --- KARSILASTIRMA ADIMI ---
    ; Gezici (DI) ile En Kucuk (BX) icerigini kiyasla
    MOV AL, [DI]    ; Gezici elemanin degerini AL'ye al
    CMP AL, [BX]    ; En kucuk kabul ettigimiz degerle kiyasla
    
    JAE PAS_GEC     ; Eger Walker >= Smallest ise atla (JAE: Jump if Above or Equal)

    ; Eger Walker < Smallest ise, yeni bir en kucuk sayi bulduk demektir.
    ; En kucuk elemanin adresini guncelle.
    MOV BX, DI      ; Artik 'En Kucuk' adresi, DI'nin oldugu yerdir.

PAS_GEC:
    INC DI          ; Geziciyi bir sonraki elemana ilerlet
    DEC DX          ; Ic dongu sayacini bir azalt
    JNZ IC_DONGU    ; Sayac 0 olana kadar ic donguye devam et

    ; --- TAKAS (SWAP) ADIMI ---
    ; Ic dongu bitti. Su an BX'te en kucuk elemanin adresi var.
    ; Eger en kucuk sayi zaten bastaki (SI) ise degistirmeye gerek yok.
    
    CMP BX, SI      ; Adresler ayni mi?
    JE TAKAS_YOK    ; Ayniysa takas yapma, atla.

    ; Takas Islemi: [SI] <-> [BX]
    MOV AL, [SI]    ; Gecerli (Current) degeri yedekle
    MOV AH, [BX]    ; Bulunan en kucuk degeri al
    MOV [SI], AH    ; En kucugu basa (SI) koy
    MOV [BX], AL    ; Yedegi (buyugu) en kucugun eski yerine koy

TAKAS_YOK:
    INC SI          ; Dis dongu bir sonraki elemana gecsin
    LOOP DIS_DONGU  ; CX azalt ve 0 degilse DIS_DONGU etiketine git

    ; --- PROGRAM SONLANDIRMA ---
    ; Isletim sistemine donus
    MOV AH, 4Ch
    INT 21h

CODE ENDS
END START