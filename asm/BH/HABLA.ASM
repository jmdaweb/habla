; Rutinas especiales para ‚sta s¡ntesis. Incluye el fuente completo.

INCLUDE  var.asm
INCLUDE  serie.asm
INCLUDE  bra_kbd.asm
INCLUDE  subr.asm

;---------------------------------------------------------------------------
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
h_voz     PROC    ; Manda al B.H. los par metros de voz (AL)
          PUSH    BX
          MOV     AH,0
          MOV     BL,10
          DIV     BL
          OR      AX,3030H
          MOV     WORD PTR CS:voz_val, AX
          PUSH    DI
          hb      m_voz
          POP     DI
          POP     BX
          RET
h_voz     ENDP
;----------------------------------------------------------------------------
h_volu    PROC    ; Manda el par metro de volumen al B.H.
          MOV     AL,CS:volu
          MOV     CS:voz_par,'V'
          CALL    h_voz
          RET
h_volu    ENDP
;----------------------------------------------------------------------------
h_velo    PROC    ; Manda el par metro de velocidad al B.H.
          MOV     AL,CS:velo
          MOV     CS:voz_par,'E'
          CALL    h_voz
          RET
h_velo    ENDP
;----------------------------------------------------------------------------
h_tono    PROC    ; Manda el par metro de tono al B.H.
          PUSH    AX
          MOV     AL,CS:tono
          MOV     CS:voz_par,'P'
          CALL    h_voz
          POP     AX
          RET
h_tono    ENDP
;----------------------------------------------------------------------------
h_otros   PROC    ;Configura puntuaci¢n.
          PUSH    DI
          LEA     DI,m_des_punt       ;suponemos desactivar.
          CMP     CS:f_punt,0
          JE      otros_end
          LEA     DI,m_act_punt       ;es activar puntuaci¢n.
 otros_end:CALL    manda_str
          POP     DI
          RET
h_otros   ENDP
;--------------------------------------------------------------------------
h_char    PROC
;Esta rutina habla el caracter actual.
          PUSH    AX
          MOV     CS:f_deletreo,0     ;apagamos el deletreo.
          CALL    c_char
          CALL    act_tono
          CALL    v_char
          CALL    apg_tono
          POP     AX
          RET
h_char    ENDP
;----------------------------------------------------------------------------
apg_tono  PROC    ;apaga tono de may£sculas si est  activado.
          CMP     CS:f_tono,1
          JNE     apg_fin
          SUB     CS:tono,16
          MOV     CS:f_tono,0
          CALL    h_tono
apg_fin:  RET
apg_tono  ENDP
;----------------------------------------------------------------------------
act_tono  PROC    ;activa o desactiva tono de may£scula seg£n AL.
          CMP     AL,'A'
          JB      no_mayu
          CMP     AL,'Z'
          JA      no_mayu
          CMP     CS:f_tono,1
          JE      tono_fin
          ADD     CS:tono,16
          MOV     CS:f_tono,1
          CALL    h_tono
          JMP     tono_fin
no_mayu:  CALL    apg_tono
tono_fin: RET
act_tono  ENDP
;----------------------------------------------------------------------------
v_char    PROC
;Esta rutina habla el caracter recibido en AL.
          PUSH    AX
no_tono:  CMP     AL,espacio
          JNE     s1
          CMP     CS:f_s_s,1          ; habla espacios ?
          JE      s_s
          JMP     fin_char
s_s:      LEA     DI,fo_spc
          JMP     especial
s1:       CMP     AL,'¤'
          JE      es_enne
          CMP     AL,'¥'
          JNE     s3
es_enne:  LEA     DI,fo_enne
          JMP     especial
s3:       CMP     AL,' '
          JNE     s4
          LEA     DI,fo_aa
          JMP     especial
s4:       CMP     AL,'‚'
          JNE     s5
          LEA     DI,fo_ea
          JMP     especial
s5:       CMP     AL,'¡'
          JNE     s6
          LEA     DI,fo_ia
          JMP     especial
s6:       CMP     AL,'¢'
          JNE     s7
          LEA     DI,fo_oa
          JMP     especial
s7:       CMP     AL,'£'
          JNE     s8
          LEA     DI,fo_ua
          JMP     especial
s8:       CMP     AL,'y'
          JE      griega
          CMP     AL,'Y'
          JNE     no_espe
griega:   LEA     DI,fo_griega
especial: CALL    manda_str
          JMP     fin_char
no_espe:  CMP     CS:f_fonetica,1
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
          MOV     CS:f_pantalla,1
          CALL    habla
          JMP     fin_char
no_fonet: CALL    manda
          hb_c    espacio
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
deletrea  PROC
; Esta rutina manda a la puerta serie CX caracteres apuntados por ES:[SI]
; Si AH=1 los deletrea.
          CMP     CX,1
          JA      nxt_char
          CMP     BYTE PTR ES:[SI],"y"
          JE      nxt_char
          CMP     BYTE PTR ES:[SI],"Y"
          JE      nxt_char
          MOV     AH,1
nxt_char: MOV     AL,ES:[SI]
          CMP     AL,quiet
          JE      otro_c
          CMP     AH,1
          JE      uno_a_uno
          CMP     CS:f_deletreo,1
          JE      uno_a_uno
          CALL    manda
          JMP     otro_c
uno_a_uno:PUSH    AX
          PUSH    BX
          PUSH    CX
          PUSH    DI
          CALL    v_char
          POP     DI
          POP     CX
          POP     BX
          POP     AX
otro_c:   ADD     SI,CS:f_pantalla
          LOOP    nxt_char
          RET
deletrea  ENDP
;----------------------------------------------------------------------------
habla     PROC
; Esta rutina es la principal de verbalizacion. Habla BX caracteres apuntados
; por ES:[DI]. Adem s hace un analisis de cada palabra para ver si es
; pronunciable o no, y si no lo es la deletrea, por ej. "cls".
          CMP     BX,0
          JA      no_vacio
          RET
no_vacio: PUSH    BX
          MOV     CS:f_all_spc,1
          CMP     CS:f_pantalla,2       ;Es de la memoria de pantalla.
          JE      de_pan
          CMP     CS:f_pantalla,3       ;Es de un segmento externo
          JE      de_fuera
          PUSH    CS                    ;=1, es de la memoria de programa.
          POP     ES
          JMP     find_spc
de_fuera: MOV     CS:f_pantalla,1
          JMP     find_spc
de_pan:   MOV     AX,CS:pantalla
          MOV     ES,AX
find_spc: CMP     BYTE PTR ES:[DI],espacio
          JNE     find_wrd
          ADD     DI,CS:f_pantalla
          DEC     BX
          JNZ     find_spc
          JMP     habla_out
find_wrd: MOV     CS:f_all_spc,0
          MOV     CS:f_num,1 ;suponemos que la palabra es un n£mero.
          MOV     SI,DI
          MOV     AH,1
          MOV     CX,1
find_vcl: MOV     AL,BYTE PTR ES:[DI]
          CMP     AL,"."
          JE      si_num
          CMP     AL,";"
          JE      si_num
          CMP     AL,"0"
          JB      no_num
          CMP     AL,"9"
          JBE     si_num
no_num:   MOV     CS:f_num,0
si_num:   PUSH    CX         ;vamos a averiguar a ver si es un caracter
          PUSH    DI         ; que haga la palabra verbalizable.
          PUSH    ES
          PUSH    CS
          POP     ES
          CLD
          LEA     DI,vocaliza
          MOV     CX,long_vocaliza
          REPNE   SCASB             ;es vocal o numero ?
          JNZ     no_vocal
          MOV     AH,0
no_vocal: POP     ES
          POP     DI
          POP     CX
          ADD     DI,CS:f_pantalla
          DEC     BX
          JZ      wrd_end
          MOV     AL,BYTE PTR ES:[DI]
          CMP     AL,espacio
          JE      wrd_end
          CMP     AL,";"
          JE      wrd_end
          CMP     AL,":"
          JE      wrd_end
          CMP     AL,"/"
          JE      wrd_end
          CMP     AL,"\"
          JE      wrd_end
          CMP     AL,"-"
          JE      wrd_end
          CMP     AL,"["
          JE      wrd_end
          CMP     AL,"]"
          JE      wrd_end
          CMP     AL,"{"
          JE      wrd_end
          CMP     AL,"}"
          JE      wrd_end
          CMP     CS:f_num,1
          JE      es_num
          CMP     AL,"."
          JE      wrd_end
          CMP     AL,","
          JE      wrd_end
es_num:   INC     CX
          JMP     find_vcl
wrd_end:  CALL    deletrea
habla_out:hb_c    espacio
          CMP     BX,0
          JBE     habla_end
          JMP     find_spc
habla_end:POP     BX       ;recuperamos longitud del texto.
          CMP     CS:f_all_spc,1
          JNE     way_out
          CMP     BX,1
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
          hb_c    quiet
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
          JNE     nograf
          CMP     AL,'*'              ;modificaci¢n para que con icad
          JNE     es_mq?              ;hable el * y el >.
          PUSH    DI
          MOV     DI,OFFSET fo_ast
          JE      es_ast_mq
es_mq?:   CMP     AL,'>'
          JNE     vale_todo
          PUSH    DI
          MOV     DI,OFFSET fo_mq
es_ast_mq:CALL    manda_str
          POP     DI
          JMP     no_habla
nograf:   CMP     AL,' '
          JAE     noctrl
          CMP     AL,quiet
          JE      vale_todo
          CMP     AL,orden
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
out_manda:POP     AX
          RET
manda_str ENDP
;----------------------------------------------------------------------------
; Subrutina de instalaci¢n del programa. Esta parte no permanece residente.
instalar   PROC
          ASSUME  ES:interrup  ;segmento de tabla de interrupciones.

en_pantalla       DB      "HABLA Braille Hablado Ver. 3.30"
                  DB      " Nov. 1.996  C.M.F." ,nl,cr,"$"
saludo            DB      "Habla Versi¢n 3 . 30 $"

;----------------------------------------------------------------------------
INCLUDE   main.asm

