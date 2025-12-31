; OTOMATIK BASLATMA AYARLARI

#start=simple.exe#
#start=thermometer.exe#
#make_bin#
name "thermostat"

CODE SEGMENT
ASSUME CS:CODE, DS:CODE

START: 

    mov al, 0
    out 127, al
    
    ; COM tipinde genelde DS=CS olur, yine de garantiye aliyoruz
    mov ax, cs
    mov ds, ax

    ; -----------------------------------------------------------------
    ; 1) Hedef sicakligi bir kez oku (Simple I/O - Port 110)
    ; -----------------------------------------------------------------
    in  al, 110
    mov bl, al              ; BL = hedef sicaklik (Tset)

    ; Maksimum +1 tolerans icin esik hesapla: Tset + 1
    mov dl, bl
    inc dl                  ; DL = Tset + 1

ANA_DONGU:
    ; -----------------------------------------------------------------
    ; 2) Anlik sicakligi oku (Thermometer - Port 125)
    ; -----------------------------------------------------------------
    in  al, 125             ; AL = mevcut sicaklik (Tcur)

    ; -----------------------------------------------------------------
    ; 3) Karar: Tcur >= Tset+1 ise isitici KAPALI, degilse ACIK
    ; -----------------------------------------------------------------
    cmp al, dl
    jae ISITICI_KAPAT

ISITICI_AC:
    mov al, 1
    out 127, al             ; 1 = ACIK (heater ON)
    jmp ANA_DONGU

ISITICI_KAPAT:
    mov al, 0
    out 127, al             ; 0 = KAPALI (heater OFF)
    jmp ANA_DONGU

CODE ENDS
END START
