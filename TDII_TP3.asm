;*****************************************************************
;       Técnicas Digitales II - Trabajo Práctico N3
;       Actividad: SimulaciOn del 8085 - Cronometro con segundos
;       FERRER, Ezequiel
;*****************************************************************
; Requiere (simulacion):
;   - Teclado en puerto 20h
;   - Display 7seg desde puerto 35h
;   - Display 15seg desde puerto 55h
;   - Opciones//Ejecucion//Velocidad: 100%
;   - Opciones//Interrupciones: RST 6.5 por teclado

;*****************************************************************
;       Definición de Etiquetas
;*****************************************************************
.define
	BootAddr        0000h
	StackAddr       FFFFh
	DataROM         8000h
    DataRAM         C000h

	AddrIntRST1		0008h
	AddrIntRST2		0010h
	AddrIntRST3		0018h
	AddrIntRST4		0020h
	AddrIntTRAP		0024h
	AddrIntRST5		0028h
	AddrIntRST55	002Ch
	AddrIntRST6		0030h
	AddrIntRST65	0034h
	AddrIntRST7		0038h
	AddrIntRST75	003Ch
    MSE         08h
    M75         04h
    M65         02h
    M55         01h
    
    AdrrTecl        20h
    
	AddrD7seg       35h   ;	----a----
	D7Sa			02h   ;	|       |
	D7Sb			04h   ;	f       b
	D7Sc			40h   ; |       |
	D7Sd			20h   ;	----g----
	D7Se			10h   ;	|       |
	D7Sf			01h   ;	e       c
	D7Sg			08h   ;	|       |
    D7Sdot          80h   ; ----d---- dot
    D7sgd           7
    D7dsgd          6
    D7min           5
    D7dmin          4
    D7hra           3
    D7dhra          2
    D7nada1         1
    D7nada2         0
    
	AddrD15seg		55h
	D15p			0
	D15Nro			2
	D15dH			4
	D15uH			6
	D15dM			8
	D15uM			10
	D15dS			12
	D15uS			14

    TiempoDecH      0
    TiempoUniH      1
    TiempoDecM      2
    TiempoUniM      3
    TiempoDecS      4
    TiempoUniS      5
    MaxCantTiempos  10
    
    FCrnCorriendo   01h
    FCrnActivo      02h

.data       C042h       ; ubica en simulador & solo p/ visualizar
;*****************************************************************
;       Datos en ROM
;*****************************************************************
.data       DataROM
    D7seg0:     dB  D7Sa|D7Sb|D7Sc|D7Sd|D7Se|D7Sf
    D7seg1:     dB  D7Sb|D7Sc
    D7seg2:     dB  D7Sa|D7Sb|D7Sd|D7Se|D7Sg
    D7seg3:     dB  D7Sa|D7Sb|D7Sc|D7Sd|D7Sg
    D7seg4:     dB  D7Sb|D7Sc|D7Sf|D7Sg
    D7seg5:     dB  D7Sa|D7Sc|D7Sd|D7Sf|D7Sg
    D7seg6:     dB  D7Sa|D7Sc|D7Sd|D7Se|D7Sf|D7Sg
    D7seg7:     dB  D7Sa|D7Sb|D7Sc
    D7seg8:     dB  D7Sa|D7Sb|D7Sc|D7Sd|D7Se|D7Sf|D7Sg
    D7seg9:     dB  D7Sa|D7Sb|D7Sc|D7Sf|D7Sg

;*****************************************************************
;       Datos en RAM
;*****************************************************************
.data       DataRAM
    Cronometro: dB  0, 0, 0, 0, 0, 0
    TiempoN0:   dB  0, 0, 0, 0, 0, 0
    TiempoN1:   dB  0, 0, 0, 0, 0, 0
    TiempoN2:   dB  0, 0, 0, 0, 0, 0
    TiempoN3:   dB  0, 0, 0, 0, 0, 0
    TiempoN4:   dB  0, 0, 0, 0, 0, 0
    TiempoN5:   dB  0, 0, 0, 0, 0, 0
    TiempoN6:   dB  0, 0, 0, 0, 0, 0
    TiempoN7:   dB  0, 0, 0, 0, 0, 0
    TiempoN8:   dB  0, 0, 0, 0, 0, 0
    TiempoN9:   dB  0, 0, 0, 0, 0, 0
    NroWrTime:  dB  0
    PtrWrTime:  dW  0
    NroRdTime:  dB  0
    PtrRdTime:  dW  0
    DataTecla:  dB  0
    FlagCrn:    dB  0

;*****************************************************************
;       Arranque del 8085
;*****************************************************************
.org        BootAddr
    JMP     Boot

;*****************************************************************
;       Vector de INTR
;*****************************************************************
.org        AddrIntRST1
    JMP	IntRST1
.org        AddrIntRST2
    JMP	IntRST2
.org    	AddrIntRST3
    JMP	IntRST3
.org    	AddrIntRST4
    JMP	IntRST4
.org    	AddrIntTRAP
    JMP	IntTRAP
.org    	AddrIntRST5
    JMP	IntRST5
.org    	AddrIntRST55
    JMP	IntRST55
.org    	AddrIntRST6
    JMP	IntRST6
.org        AddrIntRST65
    JMP	IntRST65
.org    	AddrIntRST7
    JMP	IntRST7
.org    	AddrIntRST75
    JMP	IntRST75

;*****************************************************************
;       Definiciones de INTR
;*****************************************************************
IntRST1:
    RET
IntRST2:
    RET
IntRST3:
    RET
IntRST4:
    RET
IntTRAP:
    RET
IntRST5:
    RET
IntRST55:
    RET
IntRST6:
    RET

IntRST65:
    PUSH	PSW
    PUSH	H

    IN      AdrrTecl
    STA     DataTecla

    CPI     'P'
    JNZ     NoPause
    LDA     FlagCrn
    ANI     FCrnActivo
    JZ      NoPause
    LDA     FlagCrn
    XRI     FCrnCorriendo
    STA     FlagCrn

    LXI     H, TiempoN0
    SHLD    PtrRdTime
    MVI     A, 00h
    STA     NroRdTime
    CALL    ShowTitle
NoPause:

    POP  	H
    POP     PSW
	EI
	RET

IntRST7:
    RET
IntRST75:
    RET

;*****************************************************************
;       PROGRAMA PRINCIPAL
;*****************************************************************
Boot:
	LXI     SP, StackAddr    
    MVI     A, MSE|M75|M55
    SIM
    EI
;---------------------------
ResetCrn:
	LXI     H, FlagCrn
    MVI     A, 00h
CleanRAM:
	MOV     M, A
	DCX     H
	CMP     L
	JNZ     CleanRAM

    LXI     H, TiempoN0
    SHLD    PtrWrTime
    SHLD    PtrRdTime

    CALL    PrintChron
    CALL    ShowTitle
;---------------------------
Main:
    LDA     DataTecla
    CPI     'A'
    JNZ     Main
    MVI     A, FCrnActivo|FCrnCorriendo
    STA     FlagCrn
;---------------------------
Running:
    LDA     FlagCrn
    ANI     FCrnCorriendo
    JZ      Stoped
    LDA     10
ASecond:
    CALL    BaseTime
    DCR     A
    JNZ     ASecond
    CALL    UpChron
    CALL    PrintChron

    LDA     DataTecla
	CPI     'T'
	CZ   	SaveTime    
    JMP     Running
;---------------------------
Stoped:
    LDA     DataTecla
    CPI 	'P'
    JZ   	Running
    CPI     'S'
	CZ      ShowTimes
    CPI     'R'
	JZ      ResetCrn
    JMP     Stoped
;---------------------------
    HLT

;*****************************************************************
;       FUNCION SaveTime
;*****************************************************************
SaveTime:
    LDA     NroWrTime
    CPI     MaxCantTiempos
    RZ
    INR     A
    STA     NroWrTime
    LHLD    PtrWrTime
    
    LDA     Cronometro+TiempoDecH
    MOV     M, A
    INX     H
    LDA     Cronometro+TiempoUniH
    MOV     M, A
    INX     H
    
    LDA     Cronometro+TiempoDecM
    MOV     M, A
    INX     H
    LDA     Cronometro+TiempoUniM
    MOV     M, A
    INX     H
    
    LDA     Cronometro+TiempoDecS
    MOV     M, A
    INX     H
    LDA     Cronometro+TiempoUniS
    MOV     M, A
    INX     H

    SHLD    PtrWrTime
    MVI     A, 'P'
    STA     DataTecla
    RET

;*****************************************************************
;       FUNCION ShowTimes
;*****************************************************************
ShowTimes:
    LXI     H, NroWrTime
    LDA     NroRdTime
    CMP     M
    RZ

    CALL    CodifTo7s
    ORI     D7Sdot
    OUT     AddrD15seg+D15Nro+1

    MVI     A, D7Sa|D7Sb|D7Se|D7Sf|D7Sg
    OUT     AddrD15seg+D15p+1

    LHLD    PtrRdTime

    MVI     A, 00h
    OUT     AddrD15seg+D15dH
	MOV    	A, M
    CALL    CodifTo7s
	OUT    	AddrD15seg+D15dH+1
    INX     H
    MVI     A, 00h
    OUT     AddrD15seg+D15uH
	MOV    	A, M
    CALL    CodifTo7s
    ORI     D7Sdot
	OUT    	AddrD15seg+D15uH+1
    INX     H

    MVI     A, 00h
    OUT     AddrD15seg+D15dM
	MOV    	A, M
    CALL    CodifTo7s
	OUT    	AddrD15seg+D15dM+1
    INX     H
    MVI     A, 00h
    OUT     AddrD15seg+D15uM
	MOV    	A, M
    CALL    CodifTo7s
    ORI     D7Sdot
	OUT    	AddrD15seg+D15uM+1
    INX     H

    MVI     A, 00h
    OUT     AddrD15seg+D15dS
	MOV    	A, M
    CALL    CodifTo7s
	OUT    	AddrD15seg+D15dS+1
    INX     H
    MVI     A, 00h
    OUT     AddrD15seg+D15uS
	MOV    	A, M
    CALL    CodifTo7s
    ORI     D7Sdot
	OUT    	AddrD15seg+D15uS+1
    INX     H

    LDA     NroRdTime
    INR     A
    STA     NroRdTime
    SHLD    PtrRdTime
    MVI     A, 'P'
    STA     DataTecla
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION BaseTime
;*****************************************************************
BaseTime:
	PUSH	H
	PUSH	PSW
    LXI     B, 0066h
DelayLoop:
    CALL    LoseTime
    DCX     B
    MOV     A, B
    ORA     C
    JNZ     DelayLoop

	POP     PSW
	POP    	H
    RET

LoseTime:
    ANI     FFh
    ANI     FFh
    ANI     FFh
    ANI     FFh
    ANI     FFh
    ANI     FFh
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION UpChron
;*****************************************************************
UpChron:
    LDA     Cronometro+TiempoUniS
    CPI     09h
    JZ      UpChronDseg
    INR     A
    STA     Cronometro+TiempoUniS
    RET
UpChronDseg:
    MVI     A, 00h
    STA     Cronometro+TiempoUniS
    LDA     Cronometro+TiempoDecS
    CPI     05h
    JZ      UpChronUmin
    INR     A
    STA     Cronometro+TiempoDecS
    RET
;---------------------------
UpChronUmin:
    MVI     A, 00h
    STA     Cronometro+TiempoDecS
    LDA     Cronometro+TiempoUniM
    CPI     09h
    JZ      UpChronDmin
    INR     A
    STA     Cronometro+TiempoUniM
    RET
UpChronDmin:
    MVI     A, 00h
    STA     Cronometro+TiempoUniM
    LDA     Cronometro+TiempoDecM
    CPI     05h
    JZ      UpChronUhra
    INR     A
    STA     Cronometro+TiempoDecM
    RET
;---------------------------
UpChronUhra:
    MVI     A, 00h
    STA     Cronometro+TiempoDecM
    LDA     Cronometro+TiempoUniH
    CPI     09h
    JZ      UpChronDhra
    INR     A
    STA     Cronometro+TiempoUniH
    CPI     04h
    JZ      OutRankChron
    RET
UpChronDhra:
    MVI     A, 00h
    STA     Cronometro+TiempoUniH
    LDA     Cronometro+TiempoDecH
    INR     A
    STA     Cronometro+TiempoDecH
    RET
;---------------------------
OutRankChron:
    LDA     Cronometro+TiempoDecH
    CPI     02h
    JZ      UCountADay
    RET
UCountADay:
    MVI     A, 00h
    STA     Cronometro+TiempoUniH
    STA     Cronometro+TiempoDecH
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION PrintChron
;*****************************************************************
PrintChron:
    LDA     Cronometro+TiempoDecH
    CALL    CodifTo7s
    OUT     AddrD7seg+D7dhra
    LDA     Cronometro+TiempoUniH
    CALL    CodifTo7s
    ORI     D7Sdot
    OUT     AddrD7seg+D7hra

    LDA     Cronometro+TiempoDecM
    CALL    CodifTo7s
    OUT     AddrD7seg+D7dmin
    LDA     Cronometro+TiempoUniM
    CALL    CodifTo7s
    ORI     D7Sdot
    OUT     AddrD7seg+D7min

    LDA     Cronometro+TiempoDecS
    CALL    CodifTo7s
    OUT     AddrD7seg+D7dsgd
    LDA     Cronometro+TiempoUniS
    CALL    CodifTo7s
    OUT     AddrD7seg+D7sgd
    
    MVI     A, D7Sg
    OUT     AddrD7seg+D7nada1
    OUT     AddrD7seg+D7nada2
    
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION CodifTo7s
;*****************************************************************
CodifTo7s: 
    CPI     00h
    JNZ     Cod7sUno
    LDA     D7seg0
    RET
Cod7sUno:
    CPI     01h
    JNZ     Cod7sDos
    LDA     D7seg1
    RET
Cod7sDos:
    CPI     02h
    JNZ     Cod7sTres
    LDA     D7seg2
    RET
Cod7sTres:
    CPI     03h
    JNZ     Cod7sCuatro
    LDA     D7seg3
    RET
Cod7sCuatro:
    CPI     04h
    JNZ     Cod7sCinco
    LDA     D7seg4
    RET
Cod7sCinco:
    CPI     05h
    JNZ     Cod7sSeis
    LDA     D7seg5
    RET
Cod7sSeis:
    CPI     06h
    JNZ     Cod7sSiete
    LDA     D7seg6
    RET
Cod7sSiete:
    CPI     07h
    JNZ     Cod7sOcho
    LDA     D7seg7
    RET
Cod7sOcho:
    CPI     08h
    JNZ     Cod7sNueve
    LDA     D7seg8
    RET
Cod7sNueve:
    CPI     09h
    JNZ     Cod7sError
    LDA     D7seg9
    RET
Cod7sError:
    LDA     D7Sg
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION ShowTitle
;*****************************************************************
ShowTitle:
    MVI     A, 00h
    OUT     AddrD15seg+D15p
    MVI     A, D7Sg
    OUT     AddrD15seg+D15p+1

    MVI     A, 00h
    OUT     AddrD15seg+D15Nro
    MVI     A, D7Sa|D7Sd|D7Se|D7Sf
    OUT     AddrD15seg+D15Nro+1

    MVI     A, D7Sdot
    OUT     AddrD15seg+D15dH
    MVI     A, D7Sa|D7Sb|D7Se|D7Sf|D7Sg
    OUT     AddrD15seg+D15dH+1

    MVI     A, 00h
    OUT     AddrD15seg+D15uH
    MVI     A, D7Sa|D7Sb|D7Sc|D7Sd|D7Se|D7Sf
    OUT     AddrD15seg+D15uH+1

    MVI     A, D7Sf|D7Sdot
    OUT     AddrD15seg+D15dM
    MVI     A, D7Sb|D7Sc|D7Se|D7Sf
    OUT     AddrD15seg+D15dM+1

    MVI     A, 00h
    OUT     AddrD15seg+D15uM
    MVI     A, D7Sa|D7Sb|D7Sc|D7Sd|D7Se|D7Sf
    OUT     AddrD15seg+D15uM+1

    MVI     A, D7Sb|D7Sf
    OUT     AddrD15seg+D15dS
    MVI     A, D7Sb|D7Sc|D7Se|D7Sf
    OUT     AddrD15seg+D15dS+1

    MVI     A, 00h
    OUT     AddrD15seg+D15uS
    MVI     A, D7Sg
    OUT     AddrD15seg+D15uS+1

    RET
;---------------------------
	HLT