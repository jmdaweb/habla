; Rutinas especiales para ‚sta s¡ntesis. Incluye el fuente completo.

INCLUDE  var.asm
INCLUDE  serie.asm
INCLUDE  bra_kbd.asm
INCLUDE  subr.asm

;--------------------------------------------------------------------------
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
no_concat:LEA     DI,d_zone
loop_send:MOV     AL, BYTE PTR CS:[DI]
          CALL    manda
          INC     DI
          CMP     DI,SI
          JB      loop_send
          hb_c    speak                 ;hablalo!
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
          PUSH    AX
          hb_c    quiet
          POP     AX
calla_end:RET
callate   ENDP
;----------------------------------------------------------------------------
manda     PROC
; Esta rutina manda el caracter en AL por la puerta serie.
          CMP     CS:f_habla,1
          JNE     no_habla
          CMP     CS:f_graf,1
          JE      vale_todo
          CMP     AL,' '
          JAE     noctrl
          CMP     AL,quiet
          JE      vale_todo
          CMP     AL,speak
          JE      vale_todo
          JMP     no_habla
noctrl:   CMP     AL,169
          JAE     no_habla
vale_todo:
          PUSH    DX
          PUSH    AX
          MOV     DX,CS:puerto_MSR
espero1:  IN      AL,DX
          AND     AL,00100000B
          CMP     AL,0
          JE      espero1
          MOV     DX,CS:puerto_LSR
espero2:  IN      AL,DX
          AND     AL,00100000B
          CMP     AL,0
          JE      espero2
          POP     AX
          MOV     DX,CS:puerto_THR
          OUT     DX,AL
          POP     DX
no_habla: RET
manda     ENDP
;----------------------------------------------------------------------------
manda_str PROC
; Esta rutina manda por la puerta serie una cadena apuntada por CS:[DI]
; y que finaliza con un '$'.
          PUSH    AX
lazo_str:
          MOV     AL,CS:[DI]
          CMP     AL,'$'
          JE      out_manda
          INC     DI
          CALL    manda
          JMP     lazo_str
out_manda:hb_c    speak
          POP     AX
          RET
manda_str ENDP
;----------------------------------------------------------------------------
; Subrutina de instalaci¢n del programa. Esta parte no permanece residente.
instalar   PROC
          ASSUME  ES:interrup  ;segmento de tabla de interrupciones.

en_pantalla       DB "HABLA Versi¢n 3.30 PC HABLADO"
                  DB " Nov. 1.996 C.M.F. (Para Terminal 1.11)" ,nl,cr,"$"
saludo            DB "Habla Versi¢n 3 30 $"

INCLUDE   main.asm
