; Rutinas especiales para ‚sta s¡ntesis. Incluye el fuente completo.

INCLUDE  var.asm
INCLUDE  subr.asm

;--------------------------------------------------------------------------
conf_serie PROC
; Rutina para configurar el puerto serie.
          CMP     CS:f_no_serie,1    ;configuramos par metros puerto ?
          JE      conf_end           ;no.
          MOV     AH,00              ;si, configuramos par metros standard.
          MOV     DH,0
          MOV     DL,CS:com
          MOV     AL,standard
          INT     14H
conf_end: RET
conf_serie ENDP
;---------------------------------------------------------------------------
h_lpp     PROC    ;leer desde principio de pantalla hasta cursor (Ver. Ciber)
          CALL    look_cur
          MOV     DL,0
lpp_loop: CMP     DL,DH
          JE      nomas
          MOV     AL,DL
          MOV     CH,0
          MOV     CL,80
          PUSH    DX
          CALL    part_line
          POP     DX
          INC     DL
          JMP     lpp_loop
nomas:    CALL    h_llp
          RET
h_lpp     ENDP
;----------------------------------------------------------------------------
h_lpf     PROC    ;leer desde el cursor hasta el final de pantalla(Ver.Ciber)
          CALL    h_llf
lpf_loop: INC     DH
          CMP     DH,CS:last_line           ;estamos en la £ltima fila?
          JA      lpf_end
          MOV     AL,DH
          MOV     CH,0
          MOV     CL,80
          PUSH    DX
          CALL    part_line
          POP     DX
          JMP     lpf_loop
lpf_end:  RET
h_lpf     ENDP
;----------------------------------------------------------------------------
h_otros   PROC    ;activar otros par metros del ciber.
          MOV     CS:voz_par,'g'
          MOV     AL,CS:cib1
          CALL    h_voz
          MOV     CS:voz_par,'h'
          MOV     AL,CS:cib2
          CALL    h_voz
          MOV     CS:voz_par,'i'
          MOV     AL,CS:cib3
          CALL    h_voz
          MOV     CS:voz_par,'j'
          MOV     AL,CS:cib4
          CALL    h_voz
          MOV     CS:voz_par,'k'
          MOV     AL,CS:cib5
          CALL    h_voz
          MOV     CS:voz_par,'f'
          MOV     AL,CS:cib6
          CALL    h_voz
          RET
h_otros   ENDP
;----------------------------------------------------------------------------
h_voz     PROC    ; Manda al Cibervoz los par metros de voz (AL)
          ADD     AL,'0'
          MOV     BYTE PTR CS:voz_val, AL
          PUSH    DI
          hb      m_voz
          hb_c    rc
          POP     DI
          RET
h_voz     ENDP
;----------------------------------------------------------------------------
h_volu    PROC    ; Manda el par metro de volumen al B.H.
          MOV     AL,CS:volu
          MOV     CS:voz_par,'d'
          CALL    h_voz
          RET
h_volu    ENDP
;----------------------------------------------------------------------------
h_velo    PROC    ; Manda el par metro de velocidad al B.H.
          MOV     AL,CS:velo
          MOV     CS:voz_par,'b'
          CALL    h_voz
          RET
h_velo    ENDP
;----------------------------------------------------------------------------
h_tono    PROC    ; Manda el par metro de tono al B.H.
          PUSH    AX
          MOV     AL,CS:tono
          MOV     CS:voz_par,'a'
          CALL    h_voz
          POP     AX
          RET
h_tono    ENDP
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
          MOV     CS:f_vchar,1
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
          hb_c    speak
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
no_m_may: MOV     CS:f_vchar,0
          CMP     CS:f_deletreo,1
          JE      deleter
          hb_c    speak
deleter:  RET
v_char    ENDP
;----------------------------------------------------------------------------
deletrea  PROC
; Esta rutina manda a la puerta serie CX caracteres apuntados por ES:[SI]
          CMP     CX,1
          JA      nxt_char
          CMP     BYTE PTR ES:[SI],"y"
          JE      nxt_char
          CMP     BYTE PTR ES:[SI],"Y"
          JE      nxt_char
nxt_char: MOV     AL,ES:[SI]
          CMP     AL,quiet
          JE      otro_c
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
          MOV     SI,DI
          MOV     CX,BX
          CALL    deletrea
habla_out:POP     BX       ;recuperamos longitud del texto.
          CMP     CS:f_all_spc,1
          JNE     way_out
          CMP     BX,1
          JA      mas_d_1
          CMP     CS:f_s_s,1
          JNE     way_out
          hb      fo_spc
          JMP     way_out
mas_d_1:  CMP     CS:f_s_l,1
          JNE     sirc
          hb      m_nada   ;decir mensaje de vac¡o.
sirc:     hb_c    rc
way_out:  CMP     CS:f_lecto,1
          JE      norc
          hb_c    rc
norc:     RET
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
          CMP     AL,0
          JNE     no_0
          MOV     AL,' '
no_0:     CMP     CS:f_graf,1
          JE      vale_todo
          CMP     AL,' '
          JAE     noctrl
          CMP     AL,quiet
          JE      vale_todo
          CMP     AL,abort
          JE      vale_todo
          CMP     AL,rc
          JE      vale_todo
          CMP     AL,orden
          JE      vale_todo
          JMP     no_habla
noctrl:   CMP     AL,169
          JAE     no_habla
vale_todo:PUSH    DX
          PUSH    AX
          MOV     AH,01
          MOV     DH,0
          MOV     DL,CS:com
          INT     14H
          POP     AX
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
out_manda:CMP     CS:f_vchar,1
          JE      en_vchar
          MOV     AL,rc
          CALL    manda
en_vchar: POP     AX
          RET
manda_str ENDP
;----------------------------------------------------------------------------
; Subrutina de instalaci¢n del programa. Esta parte no permanece residente.
instalar   PROC
          ASSUME  ES:interrup  ;segmento de tabla de interrupciones.

en_pantalla   DB "HABLA Versi¢n 3.30 CIBERVOZ Nov. 1.996  C.M.F." ,nl,cr,"$"
saludo        DB "Habla Versi¢n 3.30 $"

INCLUDE  main.asm
