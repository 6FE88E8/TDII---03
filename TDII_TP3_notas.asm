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
    MSE         08h           ; establecimiento de intr
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
	;sega			0200h   ;  dW: adrr adrr+1 
	;segb			0400h   ;       L     H
	;segc			4000h   ;
	;segd			2000h   ;	------a------
	;sege			1000h   ;	|\	  |    /|
	;segf			0100h   ;	| \	  |   /	|
	;segg			0800h   ;   f  o  h  i	b
	;segdot			8000h   ;	|   \ | /	|
	;segi			0004h   ;	|    \|/  	|
	;segj			0010h   ;	--n---g---j--
	;segk			0080h   ;	|    /|\    |
	;segl			0040h   ;	|   / | \ 	|
	;segm			0020h   ;   e  m  l  k	c
	;segn			0008h   ;	| /   |   \	|
	;sego			0001h   ;	|/    |    \|
	;segh			0002h   ;	------d------  dot
	D15p			0
	D15Nro			2
	D15dH			4
	D15uH			6
	D15dM			8
	D15uM			10
	D15dS			12
	D15uS			14

    TiempoDecH      0       ; posiciones array tiempos
    TiempoUniH      1
    TiempoDecM      2
    TiempoUniM      3
    TiempoDecS      4
    TiempoUniS      5
;    EntreTParciales 6
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

    ;D15seg0:    dW  sega|segb|segc|segd|sege|segf|segi|segm
    ;D15seg1:	dW  segb|segc|segi
    ;D15seg2:	dW  sega|segb|segd|segj|segm
    ;D15seg3:	dW  sega|segb|segc|segd|segj
    ;D15seg4:	dW  segb|segc|segf|segg
    ;D15seg5:	dW  sega|segc|segd|segf|segg
    ;D15seg6:	dW  sega|segc|segd|sege|segf|segg
    ;D15seg7:	dW  sega|segg|segi|segm
    ;D15seg8:	dW  sega|segb|segc|segd|sege|segf|segg
    ;D15seg9:	dW  sega|segb|segc|segf|segg
    ;D15dot: 	dW  segdot
    ;D15segP:	dW  sega|segb|sege|segf|segg

;*****************************************************************
;       Datos en RAM
;*****************************************************************
.data       DataRAM
    Cronometro: dB  0, 0, 0, 0, 0, 0    ; cronometro corriendo
    TiempoN0:   dB  0, 0, 0, 0, 0, 0    ; tiempos parciales (TP) 
    TiempoN1:   dB  0, 0, 0, 0, 0, 0
    TiempoN2:   dB  0, 0, 0, 0, 0, 0
    TiempoN3:   dB  0, 0, 0, 0, 0, 0
    TiempoN4:   dB  0, 0, 0, 0, 0, 0
    TiempoN5:   dB  0, 0, 0, 0, 0, 0
    TiempoN6:   dB  0, 0, 0, 0, 0, 0
    TiempoN7:   dB  0, 0, 0, 0, 0, 0
    TiempoN8:   dB  0, 0, 0, 0, 0, 0
    TiempoN9:   dB  0, 0, 0, 0, 0, 0
    NroWrTime:  dB  0       ; cantidad TP guardados
    PtrWrTime:  dW  0       ; puntoreo ultimo TP guardado
    NroRdTime:  dB  0
    PtrRdTime:  dW  0
    DataTecla:  dB  0
    FlagCrn:    dB  0       ; XXXX X|X|activo|corriendo

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
    PUSH	PSW             ; guardo valor de reg a utilizar
    PUSH	H

    IN      AdrrTecl        ; tomo y guardo valor teclado
    STA     DataTecla

    CPI     'P'             ; comparo con pausa
    JNZ     NoPause
    LDA     FlagCrn         ; si el cron esta activo
    ANI     FCrnActivo
    JZ      NoPause
    LDA     FlagCrn
    XRI     FCrnCorriendo   ; complemento corriendo
    STA     FlagCrn         ; (pao si corre y viceversa)

    LXI     H, TiempoN0     ; reseteo contador y ptr RD
    SHLD    PtrRdTime
    MVI     A, 00h
    STA     NroRdTime
    CALL    ShowTitle       ; limpio 15seg
NoPause:

    POP  	H               ; devuelvo valor de reg
    POP     PSW
	EI                      ; habilito intr
	RET

IntRST7:
    RET
IntRST75:
    RET

;*****************************************************************
;       PROGRAMA PRINCIPAL
;*****************************************************************
;  El programa modela un conometro con base de tiempo 100ms y
; apreciacion de 1s presentados en un display de 7 segmentos.
;  En un 15 seg se muestran los valores parciales guardados
; durante el correr del cronometro.
;  El modelo es comandado por un teclado:
;   TECLAS  "A" arranque
;           "P" parada
;           "T" tiempo parcial
;           "S" siguiente
;           "R" reinicio
;---------------------------
Boot:
; configuracion de stack e interrupciones
	LXI     SP, StackAddr    
    MVI     A, MSE|M75|M55
    SIM
    EI
;---------------------------
ResetCrn:
; Limpieza de los datos es RAM
; Valido si:    - FlagCrn es el ultimo dato en RAM (dB)
;               - RAM comienza en XX00h
;               - RAM no contiene mas de FFh datos
	LXI     H, FlagCrn
    MVI     A, 00h
CleanRAM:
	MOV     M, A
	DCX     H
	CMP     L
	JNZ     CleanRAM

    LXI     H, TiempoN0     ; inicializacion de punteros
    SHLD    PtrWrTime
    SHLD    PtrRdTime

    CALL    PrintChron      ; limpieza de displays
    CALL    ShowTitle
    ;JMP     Main
;---------------------------
Main:
;  Programa principal, solo inicia cronometro con "A"
;  El estado es transitorio una vez iniciado no volvera
; a main si no es reseteado el cronometro.
    LDA     DataTecla
    CPI     'A'
    JNZ     Main
    MVI     A, FCrnActivo|FCrnCorriendo
    STA     FlagCrn
    ;JMP     Running
;---------------------------
Running:
;  Mientras el flag corriendo este en alto, el programa ciclara en 
; el siguiente codigo.
    LDA     FlagCrn
    ANI     FCrnCorriendo   ; si no corre salta a Stoped
    JZ      Stoped
    LDA     10              ; 10x(100ms)= 1s
ASecond:
    CALL    BaseTime
    DCR     A
    JNZ     ASecond         ; en bucle hasta 1s (A=0)
    CALL    UpChron         ; incremento el array cronometro
    CALL    PrintChron      ; muestro en 7seg

    LDA     DataTecla       ; si T(iempo parcial) es presionado
	CPI     'T'
	CZ   	SaveTime        ; guardo el valor del array cronometro
    JMP     Running
;---------------------------
Stoped:
;  Mientras el flag corriendo este en bajo (y activo en alto),
; el programa ciclara alternando entre el siguiente codigo
; y Running si la tecla en memoria es P.
;  Solo con el cronometro detenido pueden visualizarse los TP
; tambien puede ser R(reiniciado).
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
;  La funcion guarda el valor del cronometro en el correspondiente
; TP de acuerdo al valor del puntero WR
; IN:none  OUT:none  R:A,H,L
SaveTime:
    LDA     NroWrTime           ; cargo cant tiempos guardados
    CPI     MaxCantTiempos      ; si no alcanza el maximo
    RZ
    INR     A                   ; incremento valor y guardo
    STA     NroWrTime
    LHLD    PtrWrTime           ; cargo en memoria direccion por ptr

;  Cargo el valor del cronometro y lo guardo en la direccion de
; memoria y la incremento rp H y paso al siguente valor del cron
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

    SHLD    PtrWrTime           ; cargo valor nuevo para ptr WR
    MVI     A, 'P'              ; seteo tecla como P para el
    STA     DataTecla           ;ciclo de Stop
    RET

;*****************************************************************
;       FUNCION ShowTimes
;*****************************************************************
;  La funcion toma el valor del TP correspondiente lo codicodifica
; y lo smuestra por el 15seg
; IN:none  OUT:none  R:A,H,L
ShowTimes:
    LXI     H, NroWrTime        ; cargo en memoria direccion cant WR
    LDA     NroRdTime           ; comparo cant RD con memoria
    CMP     M
    RZ                          ; retorno si ya mostre los guardados

    CALL    CodifTo7s   ; trato el 15seg como 7seg por simplicidad
    ORI     D7Sdot      ; agrego punto
    OUT     AddrD15seg+D15Nro+1

    MVI     A, D7Sa|D7Sb|D7Se|D7Sf|D7Sg    ; cargo "P"
    OUT     AddrD15seg+D15p+1

; cargo el puntero RD para tomar los datos guardados en memoria
    LHLD    PtrRdTime

; uno a uno seteo los valores de salida para el 15seg
; todos representables por el segundo byte de cada digito
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

    LDA     NroRdTime       ; incremento el cont RD 
    INR     A
    STA     NroRdTime
    SHLD    PtrRdTime       ; guardo valor nuevo de ptr RD
    MVI     A, 'P'          ; seteo tecla en "P" para rutina Stoped
    STA     DataTecla
    RET
;---------------------------
	HLT

;*****************************************************************
;       FUNCION BaseTime
;*****************************************************************
;  Ejecuta instrucciones de manera que los ciclos llegen a los 100ms
; IN:none  OUT:none  R:A,B,C,H,L
;                               PROCESSOR   TIME(us)    
;  Instruction cycle time:      8085AH      1.3          76923
;                               8085AH-1    0.67        149254
;                               8085AH-2    0.8         125000
; [12+12+10+B.(70+6+4+7+10)-3+10+10+10]= X
; 1,3ms.X = 100ms
BaseTime:
	PUSH	H                   ; 12
	PUSH	PSW                 ; 12
    LXI     B, 004Fh            ; 10
DelayLoop:
    CALL    LoseTime            ; 18(+52)
    DCX     B                   ; 6
    MOV     A, B                ; 4
    ORA     C                   ; 7
    JNZ     DelayLoop           ; 7/10
    
	POP     PSW                 ; 10
	POP    	H                   ; 10
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
;  La funcion eleva el valor del cronometro sistema sexagesimal
; IN:none  OUT:none  R:A
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
;  Imprime en 7seg decodificando el array cronometro
; IN:none  OUT:none  R:A
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
;  Codifica los caracteres decimales a 7seg
; IN:A  OUT:A  R:A
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
;  Imprime en el 15seg "-cronom-"
; IN:none  OUT:none  R:A
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