; Rutinas especiales para ‚sta s¡ntesis. Incluye el fuente completo.

INCLUDE  var.asm
INCLUDE  bra_kbd.asm
INCLUDE  subr.asm

;--------------------------------------------------------------------------
sub_hard  PROC    ;captura int 09 de teclado. Simula teclado Braille.
          PUSH    AX
          IN      AL,tec1
          TEST    AL,80H
          JZ      tec_in
          JMP     brk_cd
tec_in:   MOV     CS:c_halt,1
          CMP     AL,1DH          ;es CTRL ?
          JNE     alterna?
          MOV     CS:f_ctrl,1
          JMP     nocapturo
alterna?: CMP     AL,38H          ;es ALT ?
          JNE     nohot
          MOV     CS:f_alte,1
          JMP     nocapturo
nohot:    CMP     AL,k1           ;es punto 1?
          JNZ     k2?
          OR      CS:codigo,00000001B
          OR      CS:codig2,00000001B
          JMP     end_hard
k2?:      CMP     AL,k2           ;es punto 2?
          JNZ     k3?
          OR      CS:codigo,00000010B
          OR      CS:codig2,00000010B
          JMP     end_hard
k3?:      CMP     AL,k3           ;es punto 3?
          JNZ     k4?
          OR      CS:codigo,00000100B
          OR      CS:codig2,00000100B
          JMP     end_hard
k4?:      CMP     AL,k4           ;es punto 4?
          JNZ     k5?
          OR      CS:codigo,00001000B
          OR      CS:codig2,00001000B
          JMP     end_hard
k5?:      CMP     AL,k5           ;es punto 5?
          JNZ     k6?
          OR      CS:codigo,00010000B
          OR      CS:codig2,00010000B
          JMP     end_hard
k6?:      CMP     AL,k6           ;es punto 6?
          JNZ     ke?
          OR      CS:codigo,00100000B
          OR      CS:codig2,00100000B
          JMP     end_hard
ke?:      CMP     AL,ke           ;es espacio?
          JNZ     no_mia
          OR      CS:codigo,01000000B
          OR      CS:codig2,01000000B
no_mia:   JMP     end_hard
brk_cd:   AND     AL,01111111B
          CMP     AL,1DH          ;es CTRL ?
          JE      nocap
          CMP     AL,38H          ;es ALT ?
          JNE     no_alt
nocap:    JMP     nocapturo
no_alt:   CMP     AL,k1           ;es punto 1?
          JNZ     t2?
          AND     CS:codig2,11111110B
          JMP     todo?
t2?:      CMP     AL,k2           ;es punto 2?
          JNZ     t3?
          AND     CS:codig2,11111101B
          JMP     todo?
t3?:      CMP     AL,k3           ;es punto 3?
          JNZ     t4?
          AND     CS:codig2,11111011B
          JMP     todo?
t4?:      CMP     AL,k4           ;es punto 4?
          JNZ     t5?
          AND     CS:codig2,11110111B
          JMP     todo?
t5?:      CMP     AL,k5           ;es punto 5?
          JNZ     t6?
          AND     CS:codig2,11101111B
          JMP     todo?
t6?:      CMP     AL,k6           ;es punto 6?
          JNZ     te?
          AND     CS:codig2,11011111B
          JMP     todo?
te?:      CMP     AL,ke           ;es espacio?
          JNZ     end_hard
          AND     CS:codig2,10111111B
todo?:    CMP     CS:codig2,0         ;est n todas levantadas ?
          JNZ     end_hard
          IN      AL,tec2
          OR      AL,80H
          OUT     tec2,AL
          AND     AL,7FH
          OUT     tec2,AL
          MOV     AL,20H
          OUT     20H,AL
          MOV     AL,CS:codigo
          MOV     CS:codigo,0
          MOV     CS:codig2,0
          CALL    bra_kbd
          JMP     sal_hard
end_hard: IN      AL,tec2
          OR      AL,80H
          OUT     tec2,AL
          AND     AL,7FH
          OUT     tec2,AL
          MOV     AL,20H
          OUT     20H,AL
sal_hard: POP     AX
          IRET
nocapturo:POP     AX
          JMP     CS:old_hard
sub_hard  ENDP
;----------------------------------------------------------------------------
h_lpp     PROC    ;leer desde principio de pantalla hasta cursor
          CALL    find_cur
          MOV     BX,AX
          INC     BX
          SHR     BX,1
          MOV     DI,0
          CALL    habla
          RET
h_lpp     ENDP
;----------------------------------------------------------------------------
h_lpf     PROC    ;leer desde el cursor hasta el final de pantalla
          CALL    find_cur
          MOV     DI,AX
          MOV     BX,CS:scr_size
          SUB     BX,AX
          INC     BX
          SHR     BX,1
          CALL    habla
          RET
h_lpf     ENDP
;----------------------------------------------------------------------------
cv_num    PROC    ; convierte el n£mero pasado en AL en ASCII en DI.
          PUSH    BX
          MOV     BYTE PTR CS:[DI+2],' ' ;ponemos blanco en la £ltima posici¢n
          OR      AL,AL
          JNS     positivo
          MOV     BYTE PTR CS:[DI],'-'
          INC     DI
          NEG     AL
positivo: MOV     AH,0
          MOV     BL,10
          DIV     BL
          OR      AX,3030H
          MOV     WORD PTR CS:[DI], AX
          POP     BX
          RET
cv_num    ENDP
;----------------------------------------------------------------------------
h_volu    PROC    ; Manda el par metro de volumen a Audilogic.
          MOV     AL,CS:volu
          SUB     AL,18
          LEA     DI,volu_val
          CALL    cv_num
          hb      m_volu
          RET
h_volu    ENDP
;----------------------------------------------------------------------------
h_velo    PROC    ; Manda el par metro de velocidad a Audilogic.
          MOV     AL,CS:velo
          SUB     AL,99
          LEA     DI,velo_val
          CALL    cv_num
          hb      m_velo
          RET
h_velo    ENDP
;----------------------------------------------------------------------------
h_tono    PROC    ; Manda el par metro de tono a Audilogic.
          MOV     AL,CS:tono
          SUB     AL,12
          LEA     DI,tono_val
          CALL    cv_num
          hb      m_tono
          RET
h_tono    ENDP
;----------------------------------------------------------------------------
h_otros   PROC    ; Manda el par metro de expresividad a Audiologic.
          MOV     AL,CS:expr
          LEA     DI,expr_val
          CALL    cv_num
          hb      m_expr
          RET
h_otros   ENDP
;----------------------------------------------------------------------------
h_char    PROC
;Esta rutina habla el caracter actual.
          PUSH    AX
          MOV     CS:f_deletreo,0     ;apagamos el deletreo.
          CALL    c_char
          CALL    v_char
          POP     AX
          RET
h_char    ENDP
;----------------------------------------------------------------------------
parla     PROC    ;verbaliza la cadena de BX caracteres apuntada por ES:[DI]
          CMP     CS:f_habla,1           ;si no hay que hablar, salir.
          JNE     parla_end
          CMP     BYTE PTR ES:[DI],quiet ;callar ?
          JNE     no_callo
          MOV     CS:c_halt,1
          CMP     BX,1
          JBE     parla_end
          MOV     BYTE PTR ES:[DI],espacio
no_callo: MOV     CS:c_cod,3             ;lectura de RAM.
          PUSH    AX
          PUSH    ES
          POP     AX
          MOV     CS:c_seg,AX            ;direcci¢n del segmento.
          MOV     CS:c_off,DI            ;    "     del offset.
          MOV     CS:c_len,BX            ;longitud de la cadena.
          MOV     AL,CS:call_type        ;llamada normal.
          CALL    audiolog
          POP     AX
parla_end:RET
parla     ENDP
;----------------------------------------------------------------------------
audiolog  PROC    ;llama a la interrupci¢n de sintesis (de Audiologic).
          PUSH    BX
          PUSH    CX
          MOV     AH,70H
          PUSH    CS
          POP     BX                     ;BX:CX direcci¢n del area de com.
          MOV     CX, OFFSET c_area
          MOV     CS:c_halt,0            ;activamos el habla por si acaso..
          INT     65H                    ;verbaliza!
          POP     CX
          POP     BX
          RET
audiolog  ENDP
;----------------------------------------------------------------------------
v_char    PROC
;Esta rutina habla el caracter recibido en AL.
          MOV     CS:f_pantalla,1
          PUSH    AX
          CMP     CS:f_fonetica,1
          JNE     no_fonet
          CMP     AL,'A'
          JB      no_fonet
          CMP     AL,'Z'
          JBE     mays
          CMP     AL,'a'
          JB      no_fonet
          CMP     AL,'z'
          JBE     mins
          JMP     no_fonet
mays:     SUB     AL,'A'
          JMP     calcu
mins:     SUB     AL,'a'
calcu:    MOV     BL,10
          MUL     BL
          LEA     DI,t_fonetica
          ADD     AX,DI
          MOV     DI,AX
          MOV     BX,10
          CALL    habla
          JMP     fin_char
no_fonet: MOV     BX,1
          LEA     DI,d_zone
          MOV     BYTE PTR CS:[DI],AL
          MOV     CS:f_deletreo,1
          CALL    habla
          MOV     CS:f_deletreo,0
fin_char: POP     AX
          CMP     CS:f_m_may,1
          JNE     no_m_may
          CMP     AL,"¥"
          JE      si_m_may
          CMP     AL,'A'
          JB      no_m_may
          CMP     AL,'Z'
          JA      no_m_may
si_m_may: hb      m_may
no_m_may: RET
v_char    ENDP
;----------------------------------------------------------------------------
habla     PROC
; Esta rutina es la principal de verbalizacion. Habla BX caracteres apuntados
; por ES:[DI].
          CMP     BX,0
          JA      no_vacio
          RET
no_vacio: PUSH    BX
          MOV     CX,BX
          MOV     CS:f_all_spc,1        ;suponemos mensaje de blancos.
          MOV     DL,0                  ;DL contiene el £ltimo car. en d_zone
          LEA     SI,d_zone             ;direcci¢n de la zona de copia.
          CMP     CS:f_pantalla,2       ;Es de la memoria de pantalla.
          JE      de_pan
          CMP     CS:f_pantalla,3       ;Es de un segmento externo
          JE      de_fuera
          PUSH    CS                    ;=1, es de la memoria de programa.
          POP     ES
          JMP     copiando
de_fuera: MOV     CS:f_pantalla,1
          JMP     copiando
de_pan:   MOV     AX,CS:pantalla
          MOV     ES,AX
copiando: MOV     AL,BYTE PTR ES:[DI]
          CMP     CS:f_deletreo,1
          JE      mira_punt
          CMP     CS:f_punt,1
          JNE     no_punt
mira_punt:MOV     BL,AL
          SUB     BH,BH
          SHL     BX,1
          CMP     CS:tabla[BX],0
          JE      no_punt
          CMP     CS:tabla2[BX],1 ;vemos si debemos hablarlo si no
          JE      sig_punt        ;estamos en deltreo. Por las acentuadas.
          CMP     CS:f_deletreo,1
          JNE     no_punt
sig_punt: MOV     CS:f_all_spc,0
          MOV     BYTE PTR CS:[SI],espacio
          INC     SI
          PUSH    DI
          MOV     DI,CS:tabla[BX]
lazo_punt:MOV     AL, BYTE PTR CS:[DI]
          CMP     AL,"$"
          JE      fin_punt
          MOV     BYTE PTR CS:[SI],AL
          INC     SI
          INC     DI
          JMP     lazo_punt
fin_punt: POP     DI
          JMP     si_spc
no_punt:  CMP     AL,espacio
          JNE     lomuevo
          CMP     DL,espacio            ;el anterior era tb. un espacio ?
          JNE     si_spc                ;no, hay que ponerlo.
          JE      paso_spc              ;si, no repetimos.
lomuevo:  MOV     BYTE PTR CS:[SI],AL
          MOV     CS:f_all_spc,0        ;no est  vac¡o.
          CMP     CS:f_deletreo,1
          JNE     is_empty
          INC     SI
si_spc:   MOV     BYTE PTR CS:[SI],espacio
is_empty: MOV     DL, BYTE PTR CS:[SI]  ;DL contiene el car cter anterior.
          INC     SI
paso_spc: ADD     DI,CS:f_pantalla
          LOOP    copiando
          POP     BX                    ;recuperamos longitud de cadena.
          CMP     CS:f_all_spc,1        ;est  en blanco?
          JE      en_blanco
          CMP     CS:f_concat,1
          JNE     no_concat
          MOV     BYTE PTR CS:[SI],'_'
          INC     SI
no_concat:PUSH    CS
          POP     ES
          LEA     DI,d_zone
          MOV     BX,SI
          SUB     BX,DI
          CALL    parla                 ;hablalo!
          JMP     way_out
en_blanco:CMP     BX,1
          JA      mas_d_1
          CMP     CS:f_s_s,1
          JNE     way_out
          hb      fo_spc
          JMP     way_out
mas_d_1:  CMP     CS:f_s_l,1
          JNE     way_out
          hb      m_nada   ;decir mensaje de vac¡o.
way_out:  RET
habla     ENDP
;----------------------------------------------------------------------------
callate   PROC             ;Esta rutina calla el £ltimo mensaje mandado
          CMP     CS:f_lecto,1 ;si estamos leyendo automat. que no se calle
          JE      calla_end
          MOV     CS:c_halt,1
calla_end:RET
callate   ENDP
;----------------------------------------------------------------------------
manda     PROC ;Manda el car cter recibido en AL al sintetizador.
          PUSH    BX
          PUSH    DI
          PUSH    ES
          MOV     BX,1
          PUSH    CS
          POP     ES
          MOV     DI, OFFSET d_zone
          MOV     CS:d_zone[0],AL
          CALL    parla
          POP     ES
          POP     DI
          POP     BX
          RET
manda     ENDP
;----------------------------------------------------------------------------
manda_str PROC
; Esta rutina manda al sintetizador una cadena apuntada por CS:[DI]
; y que finaliza con un '$'.
          PUSH    AX
          PUSH    BX
          PUSH    ES
          MOV     BX,0       ;calcular longitud de cadena en BX.
          PUSH    DI         ;guardamos puntero.
lazo_str: CMP     BYTE PTR CS:[DI],'$'
          JE      eos
          INC     DI
          INC     BX
          JMP     lazo_str
eos:      POP     DI         ;recuperamos puntero.
          PUSH    CS
          POP     ES
          CALL    parla
          POP     ES
          POP     BX
          POP     AX
          RET
manda_str ENDP
;----------------------------------------------------------------------------
; Subrutina de instalaci¢n del programa. Esta parte no permanece residente.
instalar   PROC
          ASSUME  ES:interrup  ;segmento de tabla de interrupciones.

en_pantalla       DB "HABLA Versi¢n 3.30 Habla en PC HABLADO"
                  DB " Nov. 1.996 C.M.F. ",nl,cr,"$"
saludo            DB "Habla Versi¢n 3 30 $"

INCLUDE   main.asm
