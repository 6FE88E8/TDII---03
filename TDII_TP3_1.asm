;*****************************************************************
;       Técnicas Digitales II - Trabajo Práctico N2
;       Actividad: Simulación del 8085 - Ordenamiento de datos
;       FERRER, Ezequiel
;*****************************************************************
; Requiere (simulacion):
;   - Teclado en puerto 20h
;   - Display 7seg desde puerto 35h
;   - Display 15seg desde puerto 55h

;*****************************************************************
;       Definición de Etiquetas
;*****************************************************************
.define
	BootAddr        0000h
	StackAddr       FFFFh
	DataROM         8000h
    DataRAM         C000h

	AddrIntRST1		0008h     ; direcciones de intr
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
    MSE         08h    ; establecimiento de intr
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
    D7Sdot          80h   ; ----d---- h
    D7sgd           7
    D7dsgd          6
    D7min           5
    D7dmin          4
    D7hra           3
    D7dhra          2
    D7nada1         1
    D7nada2         0
    
	AddrD15seg		55h
	sega			0200h   ;
	segb			0400h   ;
	segc			4000h   ;	------a------
	segd			2000h   ;	|\	  |    /|
	sege			1000h   ;	| \	  |   /	|
	segf			0100h   ;   f  o  h  i	b
	segg			0800h   ;	|   \ | /	|
	segh			0002h   ;	|    \|/  	|
	segi			0004h   ;	--n---g---j--
	segj			0010h   ;	|    /|\    |
	segk			0080h   ;	|   / | \ 	|
	segl			0040h   ;   e  m  l  k	c
	segm			0020h   ;	| /   |   \	|
	segn			0008h   ;	|/    |    \|
	sego			0001h   ;	------d------  p
	segdot			8000h   ;
	DIG0			0
	DIG1			2
	DIG2			4
	DIG3			6
	DIG4			8
	DIG5			10
	DIG6			12
	DIG7			14

    TiempoDecH      0       ; posiciones array tiempos
    TiempoUniH      1
    TiempoDecM      2
    TiempoUniM      3
    TiempoDecS      4
    TiempoUniS      5

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

    D15seg0:    dW  sega|segb|segc|segd|sege|segf|segi|segm
    D15seg1:	dW  segb|segc|segi
    D15seg2:	dW  sega|segb|segd|segj|segm
    D15seg3:	dW  sega|segb|segc|segd|segj
    D15seg4:	dW  segb|segc|segf|segg
    D15seg5:	dW  sega|segc|segd|segf|segg
    D15seg6:	dW  sega|segc|segd|sege|segf|segg
    D15seg7:	dW  sega|segg|segi|segm
    D15seg8:	dW  sega|segb|segc|segd|sege|segf|segg
    D15seg9:	dW  sega|segb|segc|segf|segg
    D15dot: 	dW  segdot
    D15segP:	dW  sega|segb|sege|segf|segg

;*****************************************************************
;       Datos en RAM
;*****************************************************************
.data       DataRAM
    Cronometro: dB  0, 0, 0, 0, 0, 0
    TiempoN1:   dB  0, 0, 0, 0, 0, 0

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
;   TECLAS  Arranque
;           Parada
;           Tiempo
;           Siguiente

Boot:
	LXI     SP, StackAddr

Main:
Running:
    CALL    BaseTime
    CALL    UpChron
    CALL    PrintChron
    JMP     Running

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
;       FUNCION BaseTime
;*****************************************************************
;  Debe ser de 100ms            PROCESSOR   TIME(us)
;  Instruction cycle time:      8085AH      1.3
;                               8085AH-1    0.67
;                               8085AH-2    0.8
BaseTime:
    LXI     B, 03E8h            ; 10
DelayLoop:
    CALL    LoseTime            ; 18 (+52)
    DCX     B                   ; 6
    MOV     A, B                ; 4
    ORA     C                   ; 7
    JNZ     DelayLoop           ; 7/10
    RET                         ; 10

LoseTime:
    ANI     FFh                 ; 7
    ANI     FFh
    ANI     FFh
    ANI     FFh
    ANI     FFh
    ANI     FFh
    RET                         ; 10
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