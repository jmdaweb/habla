; Rutinas comunes a todos los Hablas.

;---------------------------------------------------------------------------
IF SINTE EQ BS OR SINTE EQ CIBER OR SINTE EQ AUDIO OR SINTE EQ PCH 
                  ;no cargues si es ENPCH.
sub_hard  PROC    ;subrutina que sustituye a la int09 de teclado.
          PUSH    AX
          PUSH    ES
          MOV     AX, 40H        ;direccionamos kb_flag.
          MOV     ES,AX
          MOV     AL,BYTE PTR ES:kb_flag
          POP     ES
          AND     AL,01100000B   ;vemos variaci¢n de Ins, Caps_Lock y Num_lock
          CMP     AL,CS:f_bloq_mays
          MOV     CS:f_bloq_mays,AL
          JE      no_chg
          MOV     AH,1           ;pitido de encendido
          JA      sound
          MOV     AH,0           ;pitido de apagado
sound:    CALL    sonido
no_chg:   CMP     CS:f_no_hard,1 ;pasar de capturar teclado ?
          JE      sal_hard       ;si, salte.
          IN      AL,tec1        ;no, sigue.
          TEST    AL,80H         ;es pulsaci¢n de tecla ?
          JZ      in_hard        ;si, sigue.
sal_hard: JMP     end_hard       ;no, salte. (debe ser liberaci¢n de tecla).
in_hard:  CMP     CS:f_lecto,1
          JNE     no_in_lec
          JMP     hardkey
no_in_lec:PUSH    ES
          PUSH    AX
          MOV     AX,  40H       ;direccionamos kb_flag.
          MOV     ES,AX
          MOV     AL,BYTE PTR ES:kb_flag
          AND     AL,00001100B   ;se pulso la hotkey izquierda ?
          CMP     AL,CS:hotkey
          JZ      hot_yes
          MOV     AL,BYTE PTR ES:kb_flag2
          AND     AL,00001100B   ;se pulso la hotkey derecha ?
          CMP     AL,CS:hotkey
          JZ      hot_yes
          POP     AX
          POP     ES
          JMP     end_hard
hot_yes:  POP     AX
          POP     ES
          CMP     AL,k_quiet    ;se pulso alguna de nuestras teclas?
          JZ      hardk
          CMP     AL,k_habla
          JZ      hardk
          CMP     AL,k_wait
          JZ      hardk
          CMP     AL,k_invalid
          JZ      hardk
          CMP     AL,k_rev
          JZ      hardk
          CMP     AL,k_rev2
          JZ      hardk
          CMP     AL,k_m_tecla
          JZ      hardk
          CMP     AL,k_m_video
          JZ      hardk
          CMP     AL,k_m_may
          JZ      hardk
          CMP     AL,k_s_s
          JZ      hardk
          CMP     AL,k_s_l
          JZ      hardk
          CMP     AL,k_m_rev
          JZ      hardk
          CMP     AL,k_scr
          JZ      hardk
          CMP     AL,k_live
          JZ      hardk
          CMP     AL,k_soft
          JZ      hardk
          CMP     AL,k_soft2
          JZ      hardk
          CMP     AL,k_kbd
          JZ      hardk
          CMP     AL,k_graf
          JZ      hardk
          CMP     AL,k_str
          JZ      hardk
          CMP     AL,k_wind
          JZ      hardk
          CMP     AL,k_att
          JZ      hardk
          CMP     AL,k_cc
          JZ      hardk
          CMP     AL,k_word
hardk:    JZ      hardkey
          CMP     AL,k_fra
          JZ      hardkey
          CMP     AL,k_char
          JZ      hardkey
          CMP     AL,k_case
          JZ      hardkey
          CMP     AL,k_color
          JZ      hardkey
          CMP     AL,k_ascii
          JZ      hardkey
          CMP     AL,k_pos
          JZ      hardkey
          CMP     AL,k_vc
          JZ      hardkey
          CMP     AL,k_lpp
          JZ      hardkey
          CMP     AL,k_lpf
          JZ      hardkey
          CMP     AL,k_llp
          JZ      hardkey
          CMP     AL,k_llf
          JZ      hardkey
          CMP     AL,k_line
          JZ      hardkey
          CMP     AL,k_coc
          JZ      hardkey
          CMP     AL,k_auto
          JZ      hardkey
          CMP     AL,k_lecto
          JZ      hardkey
          CMP     AL,k_state
          JZ      hardkey
          CMP     AL,k_stat2
          JZ      hardkey
end_hard: POP     AX                ;no es ninguna de las nuestras..
          JMP     CS:old_hard       ;salimos.
hardkey:  CMP     CS:f_invalid,1    ;hacemos caso a esta pulsaci¢n ?
          JNE     si_valid          ;si.
          MOV     CS:f_invalid,0    ;no, salte...
          JMP     end_hard
si_valid: MOV     CS:old_ax,AX
          INT     nue_hard          ;llamamos a la int9h real..
          CALL    clr_buff          ;..y vaciamos el buffer.
          MOV     AX,CS:old_ax
          CMP     CS:f_lecto,1
          JNE     no_lec
          MOV     CS:f_lecto,0
          CALL    clr_buff
IF SINTE EQ AUDIO OR SINTE EQ ENPCH
          MOV     CS:fin_lecto,1
          JMP     exit_hard
no_lec:   MOV     CS:c_halt,1
ELSE
          PUSH    DI
          hb      m_lecto_fin
          POP     DI
          JMP     exit_hard
no_lec:   
ENDIF
          MOV     AH,AL
          CALL    hot
exit_hard:POP     AX
          IRET
sub_hard  ENDP
ENDIF
;----------------------------------------------------------------------------
; habla el buffer de video y lo vacia.
h_b_video PROC
          MOV     DI,OFFSET buf_video
          MOV     BX,CS:n_video
          MOV     CS:n_video,0
          CALL    habla
aun_no:   RET
h_b_video ENDP
;----------------------------------------------------------------------------
; Rutina que intercepta las llamadas a las rutinas de teclado de la BIOS.
sub_tecla PROC
tecla_in: PUSH    AX
          AND     AH,11101111B   ;resta 16. Por si es MS-DOS ver 4.01
          MOV     CS:param,AH    ;guardamos par metro de servicio elegido
          POP     AX
          CMP     CS:f_auto,2    ;b£squeda de softcursor activada ?
          JE      pdte
          CMP     CS:f_linea,1   ;primero vemos si hay algo pdte. de hablar
          JE      pdte
          CMP     CS:f_palabra,1
          JE      pdte
          CMP     CS:f_caracter,1
          JE      pdte
          CMP     CS:f_lista,1
          JE      pdte
          CMP     CS:f_del,1
          JE      pdte
          CMP     CS:f_sup,1
          JE      pdte
          CMP     CS:f_plc,1     ;pdte. hablar desde pcpio. l¡nea hasta cur.?
          JE      pdte
          CMP     CS:f_uc,2      ;unir cursores activado ?
          JE      pdte
          CMP     CS:f_pdte_video,1  ;pdte. hablar buffer de video. ?
          JNE     no_pd
          CMP     CS:param,00    ;s¢lo si es servicio 00 habla buf. video.
          JE      e_pdte
no_pd:    JMP     no_pdte        ;no hay nada pendiente
pdte:     CMP     CS:param,00    ;si es servicio 00 , ejecuta pdte.
          JE      e_pdte
          INC     CS:count       ;si no es 00, contar hasta que se pueda
          PUSH    AX             ;mirar el pdte.
          MOV     AL,multiplo    ;contamos hasta multiplo veces t_count.
          MUL     CS:t_count
          CMP     CS:count,AX    ;mirar el pdte.
          POP     AX
          JAE     e_pdte         ;ya hemos contado, ejecuta pdte.
          JMP     no_pdte        ;todavia no, hasta la pr¢xima.
e_pdte:   MOV     CS:count,0
          CMP     CS:f_uc,2      ;es unir cursores ?
          JNE     e_pdte2
          CALL    union_c
          JMP     no_pdte
e_pdte2:  MOV     CS:flag,act    ;si hay algo pendiente
          guarda                 ;guarda entorno
          CMP     CS:f_auto,2
          JNE     pdte_plc?
          MOV     CS:f_auto,0
          CALL    scan_soft
          JMP     pdte_fin
pdte_plc?:CMP     CS:f_plc,1     ;pdte hablar desde ppio.l¡nea hasta cursor?
          JNE     pdte_lin?
          MOV     CS:f_plc,0
          CALL    callate
          CALL    h_llp
          JMP     pdte_fin
pdte_lin?:CMP     CS:f_linea,1
          JNE     pdte_pal?
          JMP     pdte_lin
pdte_pal?:CMP     CS:f_palabra,1
          JNE     pdte_car?
          JMP     pdte_pal
pdte_car?:CMP     CS:f_caracter,1
          JNE     pdte_lis?
          JMP     pdte_car
pdte_lis?:CMP     CS:f_lista,1
          JNE     pdte_vid?
          JMP     pdte_lis
pdte_vid?:CMP     CS:f_pdte_video,1
          JNE     pdte_sup?
          JMP     pdte_vid
pdte_sup?:CMP     CS:f_sup,1
          JNE     pdte_del?
          JMP     pdte_sup
pdte_del?:CMP     CS:f_del,1
          JNE     salta
          MOV     CS:f_del,0
          CALL    look_cur
          CMP     DL,CS:del_colu
          JNE     cambio
          CMP     DH,CS:del_fila
          JNE     cambio
          MOV     CS:f_spc_del,0;no se ha borrado nada.
          CALL    m_beep
cambio:   hb_c    quiet         ;mandamos mensaje y el car cter borrado
          MOV     AL,CS:borrado
          CALL    v_char
          CMP     CS:n_video,0  ;actualizar buffer de video?
          JE      act_b_t
          DEC     CS:n_video
act_b_t:  CMP     CS:n_tecla,0  ;actualizar buffer de teclado?
          JE      salta
          DEC     CS:n_tecla
salta:    JMP     pdte_fin
pdte_lin: MOV     CS:f_linea,0   ;pendiente hablar linea?
          CMP     CS:f_soft,4    ;softcursor inteligente ?
          JB      no_chk_in
          CALL    chk_inteli
no_chk_in:CMP     CS:f_m_rev,5
          JE      salta
          CMP     CS:f_m_rev,1
          JE      pdte_pal
          CMP     CS:f_m_rev,2
          JE      pdte_car
          CMP     CS:f_m_rev,3
          JE      pdte_lis
          CMP     CS:f_m_rev,4
          JE      pdte_win
          CALL    h_linea        ;pendiente hablar la l¡nea
          JMP     pdte_fin
pdte_pal: CALL    callate
          CALL    h_word         ;pendiente hablar la palabra
          MOV     CS:f_palabra,0
          JMP     pdte_fin
pdte_car: CALL    callate
          CALL    h_char         ;pendiente hablar el caracter
          MOV     CS:f_caracter,0
          JMP     pdte_fin
pdte_lis: CALL    h_lis          ;pendiente hablar columna
          MOV     CS:f_lista,0
          JMP     pdte_fin
pdte_vid: MOV     CS:f_pdte_video,0
          CALL    h_b_video
          JMP     pdte_fin
pdte_sup: MOV     CS:f_sup,0
          hb_c    quiet
          MOV     AL,CS:borrado
          CALL    v_char
          JMP     pdte_fin
pdte_win: CALL    h_wind
pdte_fin: recupera               ;recupera entorno
          MOV     CS:flag,no_act

no_pdte:  CMP     CS:param,00
          JNE     no_wt          ;es una llamada al servicio de leer teclado?
          CMP     CS:f_wait,1    ;est  en espera ?
          JNZ     no_wt
          MOV     CS:f_wait,0    ;si, activa de nuevo el habla.
          MOV     CS:f_habla,1
          PUSH    DI
          hb      m_listo
          POP     DI

no_wt:    INT     nue_tecla      ;llamamos rutina antigua de teclado
          PUSHF
          CMP     CS:param,00    ;rutina de leer caracter pulsado ? (serv.00)
          JE      sigue          ;si, sigue
          JMP     fuera_rec      ;no, vete recuperando ZFLAG
sigue:    POPF
          CMP     CS:f_rev,1     ;si estamos en revisi¢n, salte
          JE      eso_no
          CMP     CS:f_uc,0      ;si estamos uniendo cursores, salte
          JE      no_en_uc
          CMP     CS:f_uc,2
          JE      eso_no
          MOV     CS:f_uc,0
eso_no:   IRET
no_en_uc: CMP     CS:f_auto,1    ;activa la b£squeda de un softcursor ?
          JNE     no_auto
          MOV     CS:f_auto,2
          MOV     CS:f_no_hard,0
          MOV     CS:count,0
no_auto:  CMP     CS:flag,act    ;estaba ya activa ?
          JNE     va_bien        ;no, sigue
          IRET                   ;si, vete.
va_bien:  MOV     CS:flag,act    ;activa
          guarda                 ;guarda entorno
          MOV     CS:f_pantalla,1
          MOV     CS:f_fonetica,0
          MOV     CS:f_deletreo,0
          CMP     AH,53H         ;c¢digo de la tecla suprimir
          JNE     no_sup
          CALL    c_char         ;Sup pulsado, averiguar car cter borrado
          MOV     CS:borrado,AL
          MOV     CS:f_sup,1
          JMP     fuera_t
no_sup:   CMP     AL,retroceso   ;es retroceso?
          JNE     no_retro
          CALL    c_char         ;retroceso pulsado, averiguar car cter
          DEC     DI             ;que se va ha borrar y posici¢n del cursor.
          DEC     DI
          MOV     AL,BYTE PTR ES:[DI]
          MOV     CS:borrado,AL
          CALL    look_cur
          MOV     CS:del_fila,DH
          MOV     CS:del_colu,DL
          MOV     CS:f_spc_del,1;el pr¢ximo espacio pintado no vale.
          MOV     CS:f_del,1
          MOV     CS:count,0
          JMP     fuera_t
no_retro: CMP     AL,00          ;ASCII=0, e.d. teclas de cursor.
          JE      teclas_ok
          CMP     AL,0E0H        ;ASCII=E0, e.d. teclas de cursor en expandido
          JNE     proceso        ;proceso normal de car cter.
teclas_ok:CMP     AH,k_arrb      ;flecha arriba pulsada ?
          JE      p_lin
          CMP     AH,k_abjo      ;flecha abajo pulsada ?
          JNE     palabra?
p_lin:    MOV     CS:f_linea,1   ;pdte, hablar l¡nea
          MOV     CS:count,0
          JMP     fuera_t
palabra?: CMP     AH,k_c_izqd    ;control-izda o control-drecha?
          JE      p_pal
          CMP     AH,k_c_drch
          JNE     caracter?
p_pal:    MOV     CS:f_palabra,1 ;pdte. hablar palabra
          MOV     CS:count,0
          JMP     fuera_t
caracter?:CMP     AH,k_izqd      ;izquierda,derecha?
          JE      p_car
          CMP     AH,k_drch
          JNE     proceso
p_car:    MOV     CS:f_caracter,1 ;pdte. hablar caracter.
          MOV     CS:count,0
          JMP     fuera_t
proceso:  CMP     CS:f_form,0    ;vemos lo del formulario...
          JE      no_form        ;no est  activo
          CMP     AL,rc          ;es Intro?
          JE      is_intro
          CMP     AL,9           ;es Tab?
          JNE     no_form        ;ni Intro ni Tab, fuera...
          CMP     CS:f_form,1    ;es Tab, se activa s¢lo con Intro?
          JE      no_form        ;si, no vale con Tab.
          JNE     act_form       ;no, si vale con Tab.
is_intro: CMP     CS:f_form,2    ;se activa s¢lo con Tab?
          JE      no_form        ;si, no vale con Intro.
act_form: MOV     CS:f_plc,1     ;activamos pdte hablar desde prinp.l¡nea...
          MOV     CS:count,0
no_form:  CMP     CS:modo_tecla,2;modo teclado desactivado ?
          JE      fuera_t
          PUSH    CS             ;proceso normal de caracter.
          POP     DS
          MOV     DI,OFFSET buf_tecla
          ADD     DI,CS:n_tecla
          MOV     CS:[DI],AL     ;no, guardamos en el buffer
          INC     CS:n_tecla
          INC     DI
          CMP     DI,OFFSET fin_buf_tecla  ;fin del buffer ?
          JE      habla_rc                 ;si, h blalo
          CMP     AL,rc                    ;cambio de linea?
          JE      habla_rc                 ;si, habla buffer
          CMP     CS:modo_tecla,1          ;modo palabra?
          JNE     habla_rc                 ;no, modo caracter
          CMP     AL,espacio               ;si, es un espacio ?
          JE      habla_rc                 ;si, habla palabra.
          JMP     fuera_t                  ;no, salte.
habla_rc: CALL    h_b_tecla             ;habla buffer teclado.
fuera_t:  recupera                      ;recupera entorno
          MOV     CS:flag,no_act
          IRET

fuera_rec:MOV     CS:param,0FFH
          POPF
          MOV     CS:old_ax,AX   ;todo lo que viene ahora es para guardar
          MOV     CS:old_bx,BX   ;en la pila el ZFLAG antes de la direcci¢n
          MOV     CS:old_cx,CX   ;de retorno.
          POP     AX
          POP     BX
          POP     CX
          PUSHF
          PUSH    BX
          PUSH    AX
          MOV     AX,CS:old_ax
          MOV     BX,CS:old_bx
          MOV     CX,CS:old_cx
          IRET
sub_tecla ENDP
;----------------------------------------------------------------------------
h_b_tecla PROC    ; habla el buffer de teclado y lo vacia.
          MOV     DI,OFFSET buf_tecla
          MOV     BX,CS:n_tecla
          MOV     CS:n_tecla,0
          CALL    habla
          RET
h_b_tecla ENDP
;----------------------------------------------------------------------------
sub_clock PROC
; subrutina que captura la interrupci¢n hardware 08H de reloj.
          INT     nue_clock
          PUSHF
          CMP     CS:f_clock,0   ;se ha activado el contador para sonido ?
          JE      no_sound       ;no, sigue.
          DEC     CS:f_clock     ;si, decrementa.
          JNZ     no_sound       ;si no es cero sigue sonando.
          PUSH    AX
          IN      AL,61H         ;si es cero, desactivar sonido.
          AND     AL,11111100B
          OUT     61H,AL
          POP     AX
no_sound: CMP     CS:f_lecto,1
          JNE     no_lecto
          PUSH    AX
          INC     CS:cuenta
          MOV     AL,CS:cuenta
          CMP     AL,c_pausa
          POP     AX
          JA      baja_cur
          JMP     no_lecto
baja_cur: save_base
          MOV     CS:cuenta,0
          MOV     AL,0
          MOV     AH,k_abjo
          CALL    entrada
          rest_base
no_lecto: 
IF SINTE EQ AUDIO OR SINTE EQ ENPCH
          CMP     CS:fin_lecto,1
          JNE     nofin
          CMP     CS:c_ret,0
          JE      nofin
          MOV     CS:fin_lecto,0
          PUSH    DI
          hb      inter_on
          POP     DI
nofin:    
ENDIF
          CMP     CS:f_auto,2    ;vemos si hay algo pendiente de hablar,
          JE      pdt            ;y si lo hay, simulamos como si se hubiese
          CMP     CS:f_linea,1   ;pulsado una tecla para que llame a la rutina
          JE      pdt            ;de leer teclado (sub_tecla) y se ejecute
          CMP     CS:f_palabra,1 ;el pendiente que quede.
          JE      pdt
          CMP     CS:f_caracter,1
          JE      pdt
          CMP     CS:f_lista,1
          JE      pdt
          CMP     CS:f_del,1
          JE      pdt
          CMP     CS:f_sup,1
          JE      pdt
          CMP     CS:f_uc,2
          JNE     no_pdt
pdt:      PUSH    AX
          IN      AL,tec1     ;esto es para que se crea que se ha pulsado
          AND     AL,7FH      ;una tecla.(le apago el MSB en tec1)
          OUT     tec1,AL
          POP     AX
no_pdt:   CMP     CS:f_rev,1
          JE      no_inteli      ;si estamos en revisi¢n no comprobamos ni
          CMP     CS:f_live,0    ;lineas vivas ni cursor inteligente.
          JE      no_viva
          INC     CS:count_clock
          CMP     CS:count_clock,c_clock
          JB      no_viva
          MOV     CS:count_clock,0
          CALL    tst_vivas      ;revisa l¡neas vivas.
          CALL    tst_vivos      ;revisa car cteres vivos.
no_viva:  CMP     CS:f_soft,4    ;cursor inteligente ?.
          JB      no_inteli
          INC     CS:count_clock2
          CMP     CS:count_clock2,c_clock
          JB      no_inteli
          MOV     CS:count_clock2,0
          CALL    chk_inteli     ;revisa si se ha movido el softcursor.
no_inteli:CMP     CS:f_k_rev,0   ;entramos en revision ?
          JE      clock_end      ;no, sigue.
          CMP     CS:f_rev,1
          JNZ     notoi
          PUSH    DI
          hb      m_ya_rev
          POP     DI
          MOV     CS:f_k_rev,0
          JMP     clock_end
notoi:    CMP     CS:f_k_rev,2        ;si es hotkey-Sup no compruebes INDOS.
          JE      no_check
          PUSH    ES
          PUSH    BX
          LES     BX,CS:indos
          CMP     BYTE PTR ES:[BX],0  ;estamos haciendo trabajo cr¡tico ?
          POP     BX
          POP     ES
          JNZ     clock_end           ;si, no entres todav¡a.
no_check: MOV     CS:f_k_rev,0
          POPF
          JMP     rev_mode
clock_end:POPF
          IRET
sub_clock ENDP
;----------------------------------------------------------------------------
sub_sys   PROC    ;captura la interrupci¢n 28H
          INT     nue_sys
          MOV     CS:f_in_key,1
          CMP     CS:f_wait,1
          JNZ     no_wait
          MOV     CS:f_wait,0
          MOV     CS:f_habla,1
          PUSH    DI
          hb      m_listo
          POP     DI
no_wait:  CMP     CS:f_pdte_video,1 ;si hay algo pdte. en el video, hablalo.
          JNE     entrorev?
          save
          MOV     CS:f_pdte_video,0
          CALL    h_b_video
          restore
entrorev?:CMP     CS:f_rev,1
          JE      end_sys
          CMP     CS:f_k_rev,0
          JE      end_sys
          CMP     CS:f_k_rev,2        ;es hotkey-sup?
          JE      no_indos            ;si, no compruebes indos (suicida).
          PUSH    ES                  ;en la int28 indos o vale 1 (idle) o
          PUSH    BX                  ;vale 2 (trabajo cr¡tico).
          LES     BX,CS:indos
          CMP     BYTE PTR ES:[BX],2  ;estamos haciendo trabajo cr¡tico ?
          POP     BX
          POP     ES
          JZ      end_sys             ;si, no entres todav¡a.
no_indos: MOV     CS:f_k_rev,0
          JMP     rev_mode
end_sys:  IRET
sub_sys   ENDP
;----------------------------------------------------------------------------
union_c   PROC    ;realiza la uni¢n de cursores.
          PUSH    AX
          PUSH    BX               ;comprobamos si el buffer est  vac¡o.
          PUSH    ES
          MOV     BX, 40H
          MOV     ES, BX
          MOV     BX, WORD PTR ES:head
          CMP     BX, WORD PTR ES:tail
          POP     ES
          POP     BX
          JZ      buf_vacio
          JMP     union_fin        ;si el buffer no est  vac¡o nos salimos.
buf_vacio:MOV     AL,CS:fil_ant    ; comparamos con la posici¢n real
          CMP     AL,CS:fila       ; del cursor.
          JE      f_igual
          JB      f_menos
          SUB     AL,CS:fila
          MOV     CS:dif,AL        ; guardamos la diferencia de posiciones.
          MOV     AH,k_arrb
          JMP     uc_end
f_menos:  MOV     AH,CS:fila
          MOV     CS:dif,AH
          SUB     CS:dif,AL        ; guardamos la diferencia de posiciones.
          MOV     AH,k_abjo
          JMP     uc_end
f_igual:  MOV     AL,CS:col_ant    ; filas iguales, y las columnas ?
          CMP     AL,CS:colu
          JE      c_igual
          JB      c_menos
          SUB     AL,CS:colu
          MOV     CS:dif,AL        ; guardamos la diferencia de posiciones.
          MOV     AH,k_izqd
          JMP     uc_end
c_menos:  MOV     AH,CS:colu
          MOV     CS:dif,AH
          SUB     CS:dif,AL        ; guardamos la diferencia de posiciones.
          MOV     AH,k_drch
          JMP     uc_end
c_igual:  PUSH    DI            ;posici¢n encontrada
          hb      m_uc
          JMP     uc_fin
uc_mal:   PUSH    DI
          hb      m_uc_err
uc_fin:   POP     DI
          MOV     CS:f_uc,1
          JMP     union_fin
uc_end:   MOV     AL,0
          CALL    entrada
          MOV     AL,CS:dif      ;vemos si la diferencia ha aumentado
          CMP     CS:dif_ant,AL
          MOV     CS:dif_ant,AL
          JA      union_fin      ;la diferencia disminuye, vamos bien.
          INC     CS:f_intenta   ;la diferencia aumenta, int‚ntalo de nuevo.
          CMP     CS:f_intenta,intentos
          JA      uc_mal
union_fin:POP     AX
          RET
union_c   ENDP
;----------------------------------------------------------------------------
act_inteli PROC   ;actualiza posici¢n del cursor inteligente.
          PUSH    AX
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,03
          MOV     BH,CS:pag_act
          INT     nue_video
          AND     CH,01100000B      ;est  visible el cursor ?
          POP     DX
          POP     CX
          POP     BX
          POP     AX
          JNZ     no_lo_act         ;no
          MOV     CS:pos_ant,DX     ;si y adem s se ha movido.
          MOV     CS:soft_fila,DH
          MOV     CS:soft_colu,DL
          MOV     CS:f_moved,1
no_lo_act:RET
act_inteli ENDP
;---------------------------------------------------------------------------
tipo_video PROC   ;averigua el tipo de tarjeta de video y carga dir. pantalla.
           PUSH    AX
           INT     11H             ;averiguar adaptador de video
           AND     AL,00110000B    ; se indica en el 4-5 bits
           CMP     AL,00110000B
           MOV     CS:pantalla,pant_co  ;suponemos adaptador color...
           JNE     tipo_v_fin
           MOV     CS:pantalla,pant_bn  ;adaptador monocromo
tipo_v_fin:POP     AX
           RET
tipo_video ENDP
;---------------------------------------------------------------------------
rev_mode  PROC    ;rutina del modo revisi¢n.
          guarda
          CALL    camb_tecla     ;cambiamos interrupci¢n de teclado (9H).
IF SINTE EQ BS OR SINTE EQ CIBER OR SINTE EQ PCH
          CALL    conf_serie     ;actualiza par metros del puerto serie,
ENDIF
          CALL    tipo_video     ; y direcci¢n de pantalla por si acaso...
          MOV     AL,CS:param
          MOV     CS:param2,AL
          MOV     CS:f_k_rev,0

          PUSH    CS
          POP     DS
          hb      m_revision

          MOV     AH,0FH
          INT     nue_video
          MOV     AH,03
          INT     nue_video      ;CH,CL=fila comienzo y fin caracter cursor
          PUSH    CX
          PUSH    DX             ;DH=fila actual,DL=columna actual.Cursor real
          MOV     CS:f_rev,0
          CALL    look_cur       ;busca el cursor o el softcursor.
          MOV     CS:f_rev,1
          MOV     AH,02H         ;sit£a el cursor en la posici¢n encontrada.
          INT     nue_video
          MOV     CS:fila,DH
          MOV     CS:colu,DL
          MOV     CS:fila_ant,DH
          MOV     CS:colu_ant,DL

          MOV     CH,0
          MOV     CL,7
          MOV     AH,01H
          INT     nue_video
rev_loop: MOV     CS:l_nume,0
es_nume:  MOV     AH,00H
          INT     tec_hab        ;llamamos a sub_tecla
          CMP     AH,k_end
          JE      is_end
          CMP     AH,k_end2
          JNE     in_loop
is_end:   JMP     out_loop
in_loop:  CMP     AL,'0'         ;es un n£mero ?
          JB      t_uc?
          CMP     AL,'9'
          JA      t_uc?
          CMP     CS:l_nume,2
          JB      otro_dgt
          MOV     CL,CS:nume[1]
          MOV     CS:nume[0],CL
          JMP     sigue_dgt
otro_dgt: INC     CS:l_nume
sigue_dgt:MOV     BX,CS:l_nume
          DEC     BX
          MOV     CS:nume[BX],AL
          CALL    manda
          hb_c    speak
          JMP     es_nume
t_uc?:    CMP     AL,k_uc        ;unir cursores?
          JNE     t_ac?
          MOV     CS:f_uc,2
          MOV     CS:f_intenta,0 ;inicializo n§ de intentos.
          MOV     CS:dif_ant,255 ;diferencia de cursores al m ximo.
          MOV     CS:count,0
          JMP     out_loop
t_ac?:    CMP     AL,k_ac        ;llevar anunciador a cursor ?
          JNE     t_char?
          MOV     DH,CS:fila_ant
          MOV     CS:fila,DH
          MOV     DL,CS:colu_ant
          MOV     CS:colu,DL
          MOV     BH,CS:pag_act
          MOV     AH,02H
          INT     nue_video
          CALL    h_pos
          JMP     coloca
t_char?:  CMP     AH,k_c_a       ;car cter actual?
          JNE     no_t_char
          CMP     CS:l_nume,0
          JA      go_colum
          CALL    callate
          CALL    h_char
          MOV     AL,1
          SUB     AL,CS:f_fonetica
          MOV     CS:f_fonetica,AL
          JMP     rev_loop
go_colum: CALL    que_nume
          CMP     AL,0
          JE      wrg_colum
          CMP     AL,80
          JA      wrg_colum
          DEC     AL
          MOV     CS:colu,AL
          hb      m_columna
          MOV     CS:f_pantalla,1
          MOV     DI,OFFSET nume
          MOV     BX,CS:l_nume
          CALL    habla
          JMP     coloca
wrg_colum:hb      m_error1
          JMP     rev_loop
no_t_char:MOV     CS:f_fonetica,0
t_p_a?:   CMP     AH,k_p_a       ;palabra actual?
          JNE     no_t_word
          CALL    callate
          CALL    h_word
          MOV     AL,1
          SUB     AL,CS:f_deletreo
          MOV     CS:f_deletreo,AL
          JMP     rev_loop
no_t_word:MOV     CS:f_deletreo,0
t_wind:   CMP     AH,k_wind      ;ventana actual ?
          JNE     t_color?
          CALL    h_wind
          JMP     rev_loop
t_color?: CMP     AH,k_color     ;verbalizar color actual ?
          JNE     no_t_color
          CALL    h_color
          JMP     rev_loop
no_t_color:MOV    CS:f_main,0
t_p_area?:CMP     AL,k_p_area    ;Definir principio de area ?
          JNE     t_f_area?
          CALL    que_nume
          CMP     AL,9
          JA      wrg_num
          MOV     BL,AL
          MOV     BH,0
          MOV     AL,CS:fila
          MOV     CS:area_f1[BX],AL
          MOV     AL,CS:colu
          MOV     CS:area_c1[BX],AL
          hb      m_p_area
          JMP     di_nume
wrg_num:  hb      m_error1
          JMP     rev_loop
t_f_area?:CMP     AL,k_f_area    ;Definir final de area ?
          JNE     t_d_l1?
          CALL    que_nume
          CMP     AL,9
          JA      wrg_num
          MOV     BL,AL
          MOV     BH,0
          MOV     AL,CS:fila
          MOV     CS:area_f2[BX],AL
          MOV     AL,CS:colu
          MOV     CS:area_c2[BX],AL
          hb      m_f_area
di_nume:  MOV     CS:f_pantalla,1
          MOV     DI,OFFSET nume
          MOV     BX,CS:l_nume
          CALL    habla
          hb      m_d_area
          JMP     rev_loop
t_d_l1?:  CMP     AL,k_d_l1      ;Definir principio de columna ?
          JNE     t_d_l2?
          CALL    que_nume
          CMP     AL,9
          JBE     d_l1
          hb      m_error1
          JMP     rev_loop
d_l1:     MOV     AH,0
          MOV     DI,AX
          MOV     AL,CS:colu
          MOV     CS:t_l1[DI],AL
          CALL    chk
          CMP     AL,255
          JE      mal_l
          hb      m_pc
          JMP     di_nume
mal_l:    MOV     CS:t_l1[DI],255
          MOV     CS:t_l2[DI],255
          hb      m_l_err1
          JMP     rev_loop
t_d_l2?:  CMP     AL,k_d_l2      ;Definir final de columna (lista) ?
          JNE     t_del_l?
          CALL    que_nume
          CMP     AL,9
          JBE     d_l2
          hb      m_error1
          JMP     rev_loop
d_l2:     MOV     AH,0
          MOV     DI,AX
          MOV     AL,CS:colu
          MOV     CS:t_l2[DI],AL
          CALL    chk
          CMP     AL,255
          JE      mal_l
          hb      m_fc
          JMP     di_nume
t_del_l?: CMP     AL,k_del_l     ;borrar las columnas (listas) ?
          JNE     t_find?
          CALL    del_l
          JMP     rev_loop
t_find?:  CMP     AL,k_find      ;b£squeda ?
          JNE     t_d_soft?
          CALL    find
          JMP     coloca
t_d_soft?:CMP     AH,k_d_soft    ;definir softcursor ?
          JNE     t_p_soft?
          CALL    c_char
          MOV     CS:soft_c,AL
          INC     DI
          MOV     AL,BYTE PTR ES:[DI]
          MOV     CS:soft_a,AL
          hb      m_soft
          JMP     rev_loop
t_p_soft?:CMP     AH,k_p_soft    ;definir  rea de seguimiento softcursor ?
          JNE     t_d_live?
          CALL    d_soft_a
          JMP     rev_loop
t_d_live?:CMP     AL,k_d_live    ;definir l¡nea viva ?
          JNE     t_frac?
          CALL    d_live
          JMP     coloca
t_frac?:  CMP     AL,k_frac      ;frase actual?
          JNE     t_fraa?
          CALL    h_fra
          JMP     rev_loop
t_fraa?:  CMP     AL,k_fraa      ;frase anterior?
          JNE     t_fras?
          CALL    fraa
          JMP     moveto
t_fras?:  CMP     AL,k_fras      ;frase siguiente?
          JNE     t_l_c?
          CALL    fras
moveto:   MOV     AH,02H
          MOV     BH,CS:pag_act
          MOV     DH,CS:fila
          MOV     DL,CS:colu
          INT     nue_video
          CALL    h_fra
          JMP     rev_loop
t_l_c?:   CMP     AH,k_l_c       ;l¡nea actual?
          JNE     t_arrb?
          CMP     CS:l_nume,0
          JA      hay_nume
          CALL    h_linea
          JMP     rev_loop
hay_nume: CALL    que_nume
          CMP     AL,0
          JE      no_vale
          CMP     AL,CS:num_lines
          JA      no_vale
          DEC     AL
          MOV     CS:fila,AL
          MOV     CS:f_linea,1
          JMP     coloca
no_vale:  hb      m_error1
          JMP     coloca
t_arrb?:  CMP     AH,k_arrb      ;l¡nea anterior?
          JE      l_a
          CMP     AH,k_l_a
          JNE     t_abjo?
l_a:      CMP     CS:fila,0
          JBE     fila_0
          MOV     CS:f_linea,1
          DEC     CS:fila
          JMP     coloca
fila_0:   JMP     pitido
t_abjo?:  CMP     AH,k_abjo      ;l¡nea siguiente?
          JE      l_s
          CMP     AH,k_l_s
          JNE     t_izqd?
l_s:      MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     fila_24
          MOV     CS:f_linea,1
          INC     CS:fila
          JMP     coloca
fila_24:  JMP     pitido
t_izqd?:  CMP     AH,k_izqd      ;car cter anterior?
          JE      c_i
          CMP     AH,k_c_i
          JNE     t_drch?
c_i:      CMP     CS:colu,0
          JBE     colu_0
          MOV     CS:f_caracter,1
          DEC     CS:colu
          JMP     coloca
colu_0:   CMP     CS:fila,0
          JBE     pita
          hb      m_fin_l
          DEC     CS:fila
          MOV     CS:colu,79
          JMP     coloca
pita:     JMP     pitido
t_drch?:  CMP     AH,k_drch      ;car cter siguiente?
          JE      c_d
          CMP     AH,k_c_d
          JNE     t_case?
c_d:      CMP     CS:colu,79
          JAE     colu_79
          MOV     CS:f_caracter,1
          INC     CS:colu
          JMP     coloca
colu_79:  MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     pita
          hb      m_pri_l
          INC     CS:fila
          MOV     CS:colu,0
          JMP     coloca
t_case?:  CMP     AH,k_case      ;verbalizar may£scula/min£scula ?
          JNE     t_ascii?
          CALL    h_case
          JMP     rev_loop
t_ascii?: CMP     AH,k_ascii     ;verbalizar ascii actual ?
          JNE     t_help?
          CALL    h_ascii
          JMP     rev_loop
t_help?:  CMP     AH,k_help      ;modo ayuda ?
          JNE     t_state?
          CALL    help
          JMP     rev_loop
t_state?: CMP     AH,k_state     ;verbalizar l¡nea de estado ?
          JNE     t_pp?
          MOV     AL,CS:t_state
          CALL    sta_line
          JMP     rev_loop
t_pp?:    CMP     AH,k_pp        ;principio de pantalla?
          JNE     t_fp?
          CMP     CS:l_nume,0
          JA      ir_pa
          MOV     CS:fila,0
          MOV     CS:colu,0
          hb      m_pp
          JMP     coloca
ir_pa:    CALL    que_nume       ;ir a principio de area
          MOV     BL,AL
          MOV     BH,0
          CMP     CS:area_f1[BX],255
          JE      a_mal
          MOV     AL,CS:area_f1[BX]
          MOV     CS:fila,AL
          MOV     AL,CS:area_c1[BX]
          MOV     CS:colu,AL
          hb      m_pa
          JMP     coloca
a_mal:    hb      m_area_err
          JMP     rev_loop
t_fp?:    CMP     AH,k_fp        ;final de pantalla?
          JNE     t_pc?
          CMP     CS:l_nume,0
          JA      ir_fa
          MOV     AL,CS:last_line
          MOV     CS:fila,AL
          MOV     CS:colu,79
          hb      m_fp
          JMP     coloca
ir_fa:    CALL    que_nume       ;ir a final de area
          MOV     BL,AL
          MOV     BH,0
          CMP     CS:area_f2[BX],255
          JE      a_mal
          MOV     AL,CS:area_f2[BX]
          MOV     CS:fila,AL
          MOV     AL,CS:area_c2[BX]
          MOV     CS:colu,AL
          hb      m_fa
          JMP     coloca
t_pc?:    CMP     AH,k_pc        ;principio de columna?
          JNE     t_fc?
          MOV     CS:fila,0
          hb      m_pc
          JMP     coloca
t_fc?:    CMP     AH,k_fc        ;final de columna?
          JNE     t_pl?
          MOV     AL,CS:last_line
          MOV     CS:fila,AL
          hb      m_fc
          JMP     coloca
t_pl?:    CMP     AH,k_pl        ;principio de l¡nea?
          JNE     t_fl?
          MOV     CS:colu,0
          hb      m_pl
          JMP     coloca
t_fl?:    CMP     AH,k_fl        ;final de l¡nea?
          JNE     t_c_izqd?
          MOV     CS:colu,79
          hb      m_fl
          JMP     coloca
t_c_izqd?:CMP     AH,k_c_izqd    ;palabra izquierda?
          JE      p_i
          CMP     AH,k_p_i
          JNE     t_c_drch?
p_i:      CALL    wrd_lft
          CMP     CS:colu,79     ;si est  al final de l¡nea que no hable
          JE      no_h_word
          MOV     CS:f_palabra,1
no_h_word:JMP     coloca
t_c_drch?:CMP     AH,k_c_drch    ;palabra derecha?
          JE      p_d
          CMP     AH,k_p_d
          JNE     t_coc?
p_d:      CALL    wrd_rgt
          CMP     CS:colu,79     ;si est  al final de l¡nea que no hable
          JE      no_h_wrd
          MOV     CS:f_palabra,1
no_h_wrd: JMP     coloca
t_coc?:   CMP     AH,k_coc       ;lista (columna) actual ?
          JNE     t_cos?
          CMP     CS:l_nume,0
          JA      lis_n
          CALL    h_lis
          JMP     rev_loop
lis_n:    CALL    que_nume       ;hablar la lista n.
          CMP     AL,9
          JA      mal_num
          MOV     BL,AL
          MOV     BH,0
          MOV     AL,CS:t_l1[BX]
          CMP     AL,255
          JE      no_def
          CMP     CS:t_l2[BX],255
          JE      no_def
          MOV     CS:f_lista,1
          MOV     CS:colu,AL
          JMP     coloca
mal_num:  hb      m_error1
          JMP     rev_loop
no_def:   hb      m_l_err4
          JMP     rev_loop
t_cos?:   CMP     AH,k_cos       ;lista (columna) superior ?
          JNE     t_coi?
          CMP     CS:fila,0
          JBE     fil_0
          MOV     CS:f_lista,1
          DEC     CS:fila
          JMP     coloca
fil_0:    JMP     pitido
t_coi?:   CMP     AH,k_coi       ;lista (columna) inferior ?
          JNE     t_con?
          MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     fil_24
          MOV     CS:f_lista,1
          INC     CS:fila
          JMP     coloca
fil_24:   JMP     pitido
t_con?:   CMP     AH,k_con       ;lista (columna) siguiente ?
          JNE     t_cob?
          CALL    nxt_lis
          JMP     coloca
t_cob?:   CMP     AH,k_cob       ;lista (columna) anterior ?
          JNE     t_pos?
          CALL    bck_lis
          JMP     coloca
t_pos?:   CMP     AH,k_pos       ;hablar posici¢n?
          JNE     t_vc?
          CALL    h_pos
          JMP     rev_loop
t_vc?:    CMP     AH,k_vc        ;verbalizar pantalla por colores ?
          JNE     t_ivolu?
          CALL    vc
          JMP     rev_loop
;---------------------------------------
INCLUDE   voz.asm
;---------------------------------------
t_c_file?:CMP     AH,k_c_file    ;hablar fichero de configuraci¢n ?
          JNE     t_asl?
          hb      m_c_file
          MOV     DI, OFFSET conf_name
          PUSH    DI
          MOV     BX,0
where?:   CMP     BYTE PTR CS:[DI],0
          JE      asciiz
          INC     DI
          INC     BX
          JMP     where?
asciiz:   POP     DI
          MOV     CS:f_pantalla,1
          CALL    habla
          MOV     CS:f_pantalla,2
          JMP     rev_loop
t_asl?:   CMP     AH,k_asl       ;activar/silenciar l¡neas ?
          JNE     t_d_state?
          CALL    quiet_line
          JMP     rev_loop
t_d_state?:CMP    AH,k_d_state   ;definir l¡nea de estado ?
          JNE     t_d_stat2?
          hb      m_state
          MOV     BL,CS:fila
          MOV     CS:t_state,BL
          JMP     rev_loop
t_d_stat2?:CMP    AH,k_d_stat2   ;definir 2¦ l¡nea de estado ?
          JNE     t_d_vc?
          hb      m_stat2
          MOV     BL,CS:fila
          MOV     CS:t_stat2,BL
          JMP     rev_loop
t_d_vc?:  CMP     AL,k_d_vc      ;definir colores a verbalizar ?
          JNE     t_t_count?
          CALL    d_vc
          JMP     rev_loop
t_t_count?:CMP    AH,k_t_count   ;cambiar tiempo de espera ?
          JNE     t_r_cfg?
          INC     CS:t_count
          CMP     CS:t_count,9
          JBE     ok_count
          MOV     CS:t_count,0
ok_count: hb      m_t_count
          MOV     AL,CS:t_count
          OR      AL,30H
          hb_c    AL
          hb_c    speak
          JMP     rev_loop
t_r_cfg?: CMP     AH,k_r_cfg     ;recuperar configuraci¢n ?
          JNE     t_g_cfg?
          hb      m_r_cfg
          CALL    filename       ;pide nombre archivo.
          CMP     BX,255         ;nombre vacio?
          JE      n_empty        ;si, no vale.
          CALL    r_conf         ;recupera configuraci¢n.
n_empty:  JMP     rev_loop
t_g_cfg?: CMP     AH,k_g_cfg     ;grabar configuraci¢n ?
          JNE     t_g_cfg2?
          hb      m_g_cfg
          CALL    filename       ;pide nombre archivo.
          CMP     BX,255         ;nombre vacio?
          JE      n_empty        ;si, no vale.
          CALL    g_conf         ;graba configuraci¢n.
          JMP     rev_loop
t_g_cfg2?:CMP     AH,k_g_cfg2    ;grabar configuraci¢n sin pedir nombre ?
          JNE     t_d_np?        ; es decir, grabar el fichero actual.
          LEA     DI,conf_name   ;p_file debe apuntar a conf_name.
          MOV     CS:p_file,DI
          MOV     CS:f_cargado,0 ;La operaci¢n la hacemos desde el residente.
          CALL    g_conf         ;graba configuraci¢n.
          JMP     rev_loop
t_d_np?:  CMP     AH,k_d_np      ;definir nombre de pantalla ?
          JNE     t_d_form?
          hb      m_scr
          hb      scr_name
          hb      m_nombre
          LEA     DI,scr_name
          MOV     CX,20
          CALL    read_str
          CMP     BX,0
          JE      np_fin
          MOV     BYTE PTR CS:[DI],' '
          MOV     BYTE PTR CS:[DI+1],'$'
np_fin:   hb      scr_name
          JMP     rev_loop
t_d_form?:CMP     AH,k_d_form    ;definir tecla formulario ?
          JNE     t_msg?
          hb      m_d_form
          INC     CS:f_form
          CMP     CS:f_form,3
          JBE     form_ok
          MOV     CS:f_form,0
form_ok:  LEA     DI,m_form_n
          CMP     CS:f_form,0
          JE      send_f
          LEA     DI,m_form_i
          CMP     CS:f_form,1
          JE      send_f
          LEA     DI,m_form_t
          CMP     CS:f_form,2
          JE      send_f
          LEA     DI,m_form_it
send_f:   CALL    manda_str
          JMP     rev_loop
t_msg?:   CMP     AH,k_msg       ;definir mensaje ?
          JNE     t_vivos?
          CALL    d_msg
          JMP     rev_loop
t_vivos?: CMP     AH,k_vivos     ;definir car cter vivo?
          JNE     t_lines?
          CALL    d_vivos
          JMP     rev_loop
t_lines?: CMP     AH,k_lines     ;definir lineas de pantalla?
          JNE     t_pcl?
          CALL    d_lines
          JMP     rev_loop
t_pcl?:   CMP     AH,k_pcl       ;activar/desact. pitido cambio de l¡nea ?
          JNE     t_lpp?
          hb      m_pcl
          CMP     CS:f_pcl,1
          MOV     CS:f_pcl,0
          LEA     DI,m_off
          JE      pcl_off
          MOV     CS:f_pcl,1
          LEA     DI,m_on
pcl_off:  CALL    manda_str
          JMP     rev_loop
t_lpp?:   CMP     AH,k_lpp       ;hablar desde principio de pantalla ?
          JNE     t_lpf?
          CALL    callate
          CALL    h_lpp
          JMP     rev_loop
t_lpf?:   CMP     AH,k_lpf       ;hablar hasta final de pantalla ?
          JNE     t_llp?
          CALL    callate
          CALL    h_lpf
          JMP     rev_loop
t_llp?:   CMP     AH,k_llp       ;leer linea desde principio hasta cursor ?
          JNE     t_llf?
          CALL    callate
          CALL    h_llp
          JMP     rev_loop
t_llf?:   CMP     AH,k_llf       ;leer linea desde cursor hasta final ?
          JNE     t_d_mark?
          CALL    callate
          CALL    h_llf
          JMP     rev_loop
t_d_mark?:CMP     AH,k_d_mark    ;Definir marca?
          JNE     t_mark?
          CALL    que_nume
          CMP     AL,9
          JA      mal_mark
          MOV     BL,AL
          MOV     BH,0
          MOV     AL,CS:fila
          MOV     CS:t_filas[BX],AL
          MOV     AL,CS:colu
          MOV     CS:t_colus[BX],AL
          hb      m_mark
          JMP     rev_loop
mal_mark: hb      m_error1
          JMP     rev_loop
t_mark?:  CMP     AH,k_mark      ;ir a marca?
          JNE     t_hot?
          CALL    que_nume
          CMP     AL,9
          JA      mal_mark
          MOV     BL,AL
          MOV     BH,0
          MOV     AL,CS:t_filas[BX]
          CMP     AL,255
          JE      mark_undf
          MOV     CS:fila,AL
          MOV     AL,CS:t_colus[BX]
          MOV     CS:colu,AL
          MOV     CS:f_linea,1
          JMP     coloca
mark_undf:hb      m_mark_err
          JMP     rev_loop
t_hot?:   CMP     AH,k_hot        ;cambio de la hotkey ?
          JNE     next_loop
          CMP     CS:hotkey,hot_alt
          JE      h_ctrl
          CMP     CS:hotkey,hot_ctrl
          JE      h_c_a
          MOV     CS:hotkey,hot_alt
          LEA     DI,m_hot_alt
          JMP     h_hot
h_ctrl:   MOV     CS:hotkey,hot_ctrl
          LEA     DI,m_hot_ctrl
          JMP     h_hot
h_c_a:    MOV     CS:hotkey,hot_c_a
          LEA     DI,m_hot_c_a
h_hot:    CALL    manda_str
          JMP     rev_loop
next_loop:JMP     rev_loop

pitido:   hb_c    quiet
          CALL    m_beep          ;producimos pit¡do
coloca:   MOV     AH,02H
          MOV     BH,CS:pag_act
          MOV     DH,CS:fila
          MOV     DL,CS:colu
          INT     nue_video
          JMP     rev_loop
out_loop: CMP     CS:f_uc,2
          JNE     si_mensa
          CALL    union_c
          JMP     no_mensa
si_mensa: hb      m_fin_rev
no_mensa: POP     DX             ;restauramos tama¤o y posici¢n del cursor
          POP     CX
          MOV     BH,CS:pag_act
          MOV     AH,01H
          INT     nue_video
          MOV     AH,02H
          INT     nue_video
          MOV     CS:f_rev,0
          CALL    rest_tecla    ;restauramos vector interrp. de teclado(9H).
          recupera
          IRET
rev_mode  ENDP
;----------------------------------------------------------------------------
camb_tecla PROC ;esta rutina reasigan el vertor 9H por si alg£n programa
                ;de aplicaci¢n la ha cambiado.
           INC    CS:f_chg9
           CMP    CS:f_chg9,1
           JA     no_camb
           CLI
           PUSH   AX
           PUSH   ES
           XOR    AX,AX
           MOV    ES,AX
           MOV    AX,WORD PTR ES:d_hard
           MOV    CS:tecla_off,AX
           MOV    AX,WORD PTR ES:d_hard[2]
           MOV    CS:tecla_seg,AX
           MOV    WORD PTR ES:d_hard, OFFSET sub_hard
           MOV    WORD PTR ES:d_hard[2], CS
           POP    ES
           POP    AX
           STI
no_camb:   RET
camb_tecla ENDP
;----------------------------------------------------------------------------
rest_tecla PROC ;restaura el vector 9H.
           DEC    CS:f_chg9
           JNZ    no_rest
           CLI
           PUSH   AX
           PUSH   ES
           XOR    AX,AX
           MOV    ES,AX
           MOV    AX,CS:tecla_off
           MOV    WORD PTR ES:d_hard,AX
           MOV    AX,CS:tecla_seg
           MOV    WORD PTR ES:d_hard[2],AX
           POP    ES
           POP    AX
           STI
no_rest:   RET
rest_tecla ENDP
;----------------------------------------------------------------------------
d_vc      PROC    ;define los colores para la verbalizaci¢n de pantalla.
          hb      m_d_vc
          CALL    pide_n
          CMP     AH,255
          JNE     d_vc_ok
          RET
d_vc_ok:  MOV     BH,0
          MOV     BL,AH
          hb      m_fondo
fondo_lz: MOV     AL,CS:f_fondo[BX]
          CALL    un_color
          MOV     AH,00
          INT     nue_tecla
          CALL    callate
          CMP     AL,cr
          JE      chg_tinta
          CMP     AL,retroceso
          JNE     inc_fondo
          DEC     CS:f_fondo[BX]
          CMP     CS:f_fondo[BX],254
          JNE     fondo_lz
          MOV     CS:f_fondo[BX],7
          JMP     fondo_lz
inc_fondo:INC     CS:f_fondo[BX]
          CMP     CS:f_fondo[BX],8
          JB      fondo_lz
          MOV     CS:f_fondo[BX],255
          JMP     fondo_lz
chg_tinta:hb      m_tinta
tinta_lz: MOV     AL,CS:f_tinta[BX]
          CALL    un_color
          MOV     AH,00
          INT     nue_tecla
          CALL    callate
          CMP     AL,cr
          JE      chg_parpa
          CMP     AL,retroceso
          JNE     inc_tinta
          DEC     CS:f_tinta[BX]
          CMP     CS:f_tinta[BX],254
          JNE     tinta_lz
          MOV     CS:f_tinta[BX],15
          JMP     tinta_lz
inc_tinta:INC     CS:f_tinta[BX]
          CMP     CS:f_tinta[BX],16
          JB      tinta_lz
          MOV     CS:f_tinta[BX],255
          JMP     tinta_lz
chg_parpa:hb      m_parpa
parpa_lz: LEA     DI,m_no
          CMP     CS:f_parpa[BX],0
          JE      pidele
          LEA     DI,m_si
          CMP     CS:f_parpa[BX],1
          JE      pidele
          LEA     DI,m_todos
pidele:   CALL    manda_str
          MOV     AH,00
          INT     nue_tecla
          CMP     AL,cr
          JE      d_vc_fin
          CALL    callate
          INC     CS:f_parpa[BX]
          CMP     CS:f_parpa[BX],2
          JB      parpa_lz
          MOV     CS:f_parpa[BX],255
          JMP     parpa_lz
d_vc_fin: hb      m_d_vc_fin
          RET
d_vc      ENDP
;----------------------------------------------------------------------------
vc        PROC   ;Verbalizar pantalla de un color. Pide un n§ entre 0 y 9.
          hb     m_vc
          CALL   pide_n
          CMP    AH,255
          JE     vc_end
          MOV    BH,0
          MOV    BL,AH
          MOV    AH,CS:f_tinta[BX]
          MOV    AL,CS:f_fondo[BX]
          MOV    CH,CS:f_parpa[BX]
          CALL   vcolor
vc_end:   RET
vc        ENDP
;----------------------------------------------------------------------------
vcolor    PROC   ;verbaliza la pantalla por colores
                 ;AH=tinta,AL=fondo,CH=parpadeo
          MOV    CS:tinta,AH
          MOV    CS:fondo,AL
          MOV    CS:parpa,CH
          MOV    SI,1
          MOV    AX,CS:pantalla
          MOV    ES,AX
          LEA    DI,t_copy
          MOV    CX,CS:scr_chars        ;CX= n§ caracteres en pantalla.
          MOV    BX,0
vc_char:  MOV    AL,BYTE PTR ES:[SI]
          PUSH   AX
          CMP    CS:tinta,255
          JE     ok_fondo?
          AND    AL,00001111B
          CMP    CS:tinta,AL
          JE     ok_fondo?
          POP    AX
          JMP    vc_nxt
ok_fondo?:POP    AX
          PUSH   AX
          CMP    CS:fondo,255
          JE     ok_parpa?
          PUSH   CX
          AND    AL,01110000B
          MOV    CL,4
          SHR    AL,CL
          POP    CX
          CMP    CS:fondo,AL
          JE     ok_parpa?
          POP    AX
          JMP    vc_nxt
ok_parpa?:POP    AX
          CMP    CS:parpa,255
          JE     si_verba
          PUSH   CX
          AND    AL,10000000B
          MOV    CL,7
          SHR    AL,CL
          POP    CX
          CMP    CS:parpa,AL
          JNE    vc_nxt
si_verba: DEC    SI
          MOV    AL,BYTE PTR ES:[SI]
          INC    SI
          MOV    BYTE PTR CS:[DI],AL
          INC    DI
          INC    BX
vc_nxt:   INC    SI
          INC    SI
          LOOP   vc_char
          MOV    CS:f_pantalla,1
          LEA    DI,t_copy
          CALL   habla
          RET
vcolor    ENDP
;----------------------------------------------------------------------------
d_soft_a  PROC   ;define area de seguimiento de softcursor.
          hb     m_p_soft
          CALL   pide_n
          CMP    AH,255
          JE     d_soft_end
          MOV    BH,0
          MOV    BL,AH
          CMP    CS:area_f1[BX],255
          JE     area_wrg
          CMP    CS:area_f2[BX],255
          JE     area_wrg
          MOV    CS:soft_area,AH
          hb     m_ok
          JMP    d_soft_end
area_wrg: MOV    CS:soft_area,255
          hb     m_area_err
d_soft_end:RET
d_soft_a  ENDP
;----------------------------------------------------------------------------
save_scr  PROC   ;salva la conf. de la pantalla indicada por screen en t_scr.
          MOV    CX,scr_sz
          PUSH   CS
          POP    DS
          LEA    SI,scr_area   ; DS:SI origen. == scr_area
          PUSH   CS
          POP    ES
          LEA    DI,t_scr[0]
          MOV    AX,scr_sz
          MUL    CS:screen
          ADD    DI,AX         ; ES:DI destino. == t_scr[screen]
          CLD
          REP    MOVSB
          RET
save_scr  ENDP
;----------------------------------------------------------------------------
load_scr  PROC   ;carga la conf. pantalla indicada en AH en scr_area
          MOV    BH,0
          MOV    BL,AH
          MOV    CX,scr_sz
          PUSH   CS
          POP    DS
          MOV    SI,OFFSET t_scr
          MOV    AX,scr_sz
          MUL    BX
          ADD    SI,AX               ; DS:SI origen. == t_scr[AH]
          PUSH   CS
          POP    ES
          MOV    DI,OFFSET scr_area  ; ES:DI destino. == scr_area
          CLD
          REP    MOVSB
          MOV    CS:screen,BX
          RET
load_scr  ENDP
;----------------------------------------------------------------------------
h_wind    PROC    ; Esta rutina habla la ventana actual.
          PUSH    AX
          CALL    callate
          CALL    find_cur
          MOV     BX,CS:pantalla
          MOV     ES,BX
          MOV     CX,80
          MOV     SI,DI
          MOV     BX,0
wind_nxt: CMP     BYTE PTR ES:[DI],176  ;es semigr fico ?
          JB      no_semi
          CMP     BYTE PTR ES:[DI],223
          JA      no_semi
          CMP     DI,AX
          JA      now_wind
          MOV     SI,DI
          MOV     BX,0
no_semi:  INC     BX
          INC     DI
          INC     DI
          LOOP    wind_nxt
now_wind: MOV     DI,SI
          CALL    habla
          POP     AX
          RET
h_wind    ENDP
;----------------------------------------------------------------------------
sub_servi PROC
; Subrutina que presta el servicio de habla a otras aplicaciones.
; Recibe AX=0, BX n§ bytes, DS:DX direcci¢n del texto. Devuelve AX=1111H.
          CMP     AX,0
          JNE     out_servi
          guarda
          CALL    callate
          PUSH    DS         ;pasamos DS:DX a ES:DI
          POP     ES
          PUSH    DX
          POP     DI
          MOV     CS:f_pantalla,3   ;indicamos que es de un segmento externo.
          CALL    habla
          recupera
          MOV     AX,1111H
out_servi:IRET
sub_servi ENDP
;----------------------------------------------------------------------------
nxt_lis   PROC
; Columna (lista) siguiente.
          MOV     DL,CS:colu
          CALL    srch
          CMP     AL,255
          JE      n_fuera
n_lis:    MOV     BL,AL
          MOV     BH,0
          JMP     n_otro
n_loop:   CMP     CS:t_l1[BX],255
          JE      n_otro
          CMP     CS:t_l2[BX],255
          JE      n_otro
          MOV     AL,CS:t_l1[BX]
          MOV     CS:colu,AL
          MOV     CS:f_lista,1
          JMP     n_end
n_otro:   INC     BX
          CMP     BX,10
          JB      n_loop
          MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     n_pita
          INC     CS:fila
          MOV     BX,0
          JMP     n_loop
n_fuera:  CALL    look              ;no estamos en una columna
          CMP     CH,255            ;hay columnas hacia la derecha ?
          JE      n_abajo           ;no, ve para abajo
          MOV     f_lista,1         ;si vete a ella
          MOV     CS:colu,CH
          JMP     n_end
n_abajo:  CMP     CL,255            ;hay columnas hacia la izquierda ?
          JE      n_end             ;no, no hay columnas
          MOV     AL,9              ;si, ve a buscarla.
          JMP     n_lis
n_pita:   CALL    m_beep
n_end:    RET
nxt_lis   ENDP
;----------------------------------------------------------------------------
look      PROC
; Cuando no estamos en una lista (columna) busca la m s cercana. Devuelve en
; CH la columna mas cerca a la derecha y en CL la columna m s cerca a la
; izquierda. SI no deviuelve 255.
          MOV     BX,0
          MOV     DX,65535
          MOV     CX,65535
look_loop:MOV     AL,CS:colu
          MOV     AH,CS:t_l1[DI][BX]
          CMP     AL,AH
          JA      look_may
          SUB     AH,AL
          CMP     AH,DH
          JA      look_nxt
          MOV     CH,CS:t_l1[DI][BX]
          MOV     DH,AH
          JMP     look_nxt
look_may: SUB     AL,AH
          CMP     AL,DL
          JA      look_nxt
          MOV     CL,CS:t_l1[DI][BX]
          MOV     DL,AL
look_nxt: INC     BX
          CMP     BX,10
          JB      look_loop
          CMP     CX,65535
          JNE     look_end
          hb      m_l_err3
look_end: RET
look      ENDP
;----------------------------------------------------------------------------
bck_lis   PROC
; Columna (lista) anterior.
          MOV     DL,CS:colu
          CALL    srch
          CMP     AL,255
          JE      b_fuera
b_lis:    MOV     BL,AL
          MOV     BH,0
          JMP     b_otro
b_loop:   CMP     CS:t_l1[BX],255
          JE      b_otro
          CMP     CS:t_l2[BX],255
          JE      b_otro
          MOV     AL,CS:t_l1[BX]
          MOV     CS:colu,AL
          MOV     CS:f_lista,1
          JMP     b_end
b_otro:   CMP     BX,0
          JBE     b_sube
          DEC     BX
          JMP     b_loop
b_sube:   CMP     CS:fila,0
          JBE     b_pita
          DEC     CS:fila
          MOV     BX,9
          JMP     b_loop
b_fuera:  CALL    look
          CMP     CL,255
          JE      b_arriba
          MOV     f_lista,1
          MOV     CS:colu,CL
          JMP     b_end
b_arriba: CMP     CH,255
          JE      b_end
          MOV     AL,0
          JMP     b_lis
b_pita:   CALL    m_beep
b_end:    RET
bck_lis   ENDP
;----------------------------------------------------------------------------
del_l     PROC
; Borrar todas las columnas de una pantalla.
          hb      m_del_l
          MOV     CS:f_no_hard,1
          MOV     AH,00
          INT     nue_tecla
          MOV     CS:f_no_hard,0
          CMP     AL,k_del_l
          JE      borrando
          JMP     del_l_end
borrando: MOV     CX,10
          MOV     BX,0
borr_loop:MOV     CS:t_l1[BX],255
          MOV     CS:t_l2[BX],255
          INC     BX
          LOOP    borr_loop
          hb      m_del_l2
del_l_end:RET
del_l     ENDP
;----------------------------------------------------------------------------
chk       PROC
; Chequea la definici¢n de una columna. Si no es correcta devuelve AL=255.
; Se supone que DI apunta a la columna que estamos chequeando.
          MOV     AL,0
          MOV     DH,CS:t_l1[DI]
          MOV     DL,CS:t_l2[DI]
          CMP     DH,255
          JE      chk_end
          CMP     DL,255
          JE      chk_end
          CMP     DH,DL
          JAE     chk_mal
          MOV     CX,10
          MOV     BX,0
chk_loop: CMP     DI,BX
          JE      chk_next
          CMP     DH,CS:t_l1[BX]
          JE      chk_mal
          JA      chk_izq
          CMP     DL,CS:t_l1[BX]
          JAE     chk_mal
          JMP     chk_next
chk_izq:  CMP     DH,CS:t_l2[BX]
          JBE     chk_mal
chk_next: INC     BX
          LOOP    chk_loop
          JMP     chk_end
chk_mal:  MOV     AL,255
chk_end:  RET
chk       ENDP
;----------------------------------------------------------------------------
srch      PROC
; Averigua en que lista estamos. Como par metro recibe DL indicando la
; columna actual del cursor. Si estamos en una lista devuelve AL=n£mero lista y
; DI apuntando al item de la tabla (t_l1). Si no, devuelve AL=255.
          MOV     DI,0
          MOV     BX,0
          MOV     CX,0
srch_loop:CMP     DL,CS:t_l1[BX]
          JE      in_l
          JB      srch_next
          CMP     DL,CS:t_l2[BX]
          JBE     in_l
srch_next:INC     BX
          INC     CX
          CMP     CX,10
          JB      srch_loop
          MOV     AL,255        ;no estamos en una columna
          JMP     srch_end
in_l:     MOV     AX,CX
          MOV     DI,CX
srch_end: RET
srch      ENDP
;----------------------------------------------------------------------------
h_lis     PROC
; habla la lista (columna) en la que estamos.
          CALL    find_cur        ;posici¢n del cursor ?
          CALL    srch            ;en que lista estamos ?
          CMP     AL,255
          JE      h_lis_mal       ;no estamos en ninguna.
          CALL    callate
          MOV     AL,DH           ;si estamos, h blala.
          MOV     CH,CS:t_l1[DI]
          MOV     CL,CS:t_l2[DI]
          SUB     CL,CS:t_l1[DI]
          INC     CL
          CALL    part_line
          JMP     h_lis_end
h_lis_mal:hb      m_l_err2
h_lis_end:RET
h_lis     ENDP
;----------------------------------------------------------------------------
d_live    PROC
; Definir l¡nea viva.
          CALL    find_cur
          MOV     BH,0
          MOV     BL,CS:fila
          SHL     BL,1                ;multiplicamos por 2 (DWORD).
          MOV     CS:t_live[BX],AX    ;direcci¢n de la zona a escanear.
          hb      m_d_live
          CALL    read_num
          CMP     DL,rc
          JNE     d_liv_err
          CMP     AL,live_wide
          JA      d_liv_err
          CBW
          MOV     CS:t_l_l[BX],AX     ;cargo longitud a escanear.
          CMP     AX,0
          JE      d_liv_off
          LEA     SI,t_l_t[BX]        ;cargo direcci¢n tabla tipos en SI.
          CALL    p_tipos             ;pide tipos a verbalizar.
          hb      m_live_ok
          MOV     CS:f_copy,1
          JMP     d_liv_end
d_liv_off:hb      m_live_off
          JMP     d_liv_end
d_liv_err:hb      m_error1
d_liv_end:RET
d_live    ENDP
;----------------------------------------------------------------------------
p_tipos   PROC    ;Pide tipos a verbalizar (l¡nea, rea ¢ msg) para 
                  ; l¡neas y caracteres vivos. SI apunta a la tabla de tipos.
          MOV     WORD PTR CS:[SI],255 ;suponemos verbalizar l¡nea.
          hb      m_live_t
          CALL    read_num
          CMP     DL,rc
          JE      tipo_ln             ;verbalizar l¡nea.
          CMP     AL,9                ;si n§ > 9, error, suponemos l¡nea.
          JA      tipo_ln           
          CMP     DH,k_area           ;tecla de verbalizar l¡nea?
          JE      tipo_ar
          CMP     DH,k_v_msg          ;tecla de verbalizar mensaje?
          JNE     tipo_ln             ;no es niguno de ellos, suponemos l¡nea.
          MOV     AH,k_v_msg          ;verbalizar mensaje.
          MOV     WORD PTR CS:[SI],AX
          hb      m_live_m
          JMP     tipos_end
tipo_ar:  MOV     AH,k_area           ;verbalizar  rea.
          MOV     WORD PTR CS:[SI],AX
          hb      m_live_a
          JMP     tipos_end
tipo_ln:  hb      m_live_l
tipos_end:RET     
p_tipos   ENDP
;----------------------------------------------------------------------------
que_nume  PROC
; Esta rutina devuelve en AL el numero introducido en el buffer "nume"
          PUSH    CX
          PUSH    BX
          MOV     AL,0
          CMP     CS:l_nume,0
          JE      out_nume
          MOV     BX,CS:l_nume
          DEC     BX
          MOV     AL,CS:nume[BX]
          SUB     AL,'0'
          CMP     BX,0
          JE      out_nume
          DEC     BX
          MOV     CL,CS:nume[BX]
          SUB     CL,'0'
          MOV     CH,AL
          MOV     AL,10
          MUL     CL
          ADD     AL,CH
out_nume: POP     BX
          POP     CX
          RET
que_nume  ENDP
;----------------------------------------------------------------------------
h_line    PROC
; Esta rutina pregunta el n£mero de l¡nea, area o columna a verbalizar.
          MOV     CS:flag,act
mal_nume: hb      m_prompt
          CALL    read_num
          CMP     DL,rc
          JE      is_line
          CMP     DH,k_area
          JE      area_col
          CMP     DH,k_lista
          JE      area_col
          JMP     mal_nume
is_line:  CMP     AL,0
          JE      mal_n
          CMP     AL,CS:num_lines
          JA      mal_n
          DEC     AL
          MOV     CX,80
          CALL    part_line
          JMP     line_out
mal_n:    hb      m_error1
          JMP     line_out
area_col: CALL    que_nume
          CMP     AL,9
          JA      mal_n
          MOV     BL,AL
          MOV     BH,0
          CMP     DH,k_area
          JE      ha_area
          CMP     CS:t_l1[BX],255
          JE      mal_col
          CMP     CS:t_l2[BX],255
          JE      mal_col
          MOV     AL,0
          MOV     CH,CS:t_l1[BX]
          MOV     AH,CS:last_line
          MOV     CL,CS:t_l2[BX]
          CALL    area
          JMP     line_out
mal_col:  hb      m_l_err4
          JMP     line_out
ha_area:  CALL    h_area
line_out: MOV     CS:l_nume,0
          MOV     CS:flag,no_act
          RET
h_line    ENDP
;----------------------------------------------------------------------------
read_num  PROC
; Esta rutina devuelve en AL el n§ introducido y en DX la tecla de retorno.
          CALL    camb_tecla
          PUSH    BX
          MOV     CS:l_nume,0
num_loop: MOV     AH,00H
          MOV     CS:f_no_hard,1 ;que pase de todo en sub_hard..
          INT     nue_tecla
          MOV     CS:f_no_hard,0
          CMP     AL,'0'         ;es un n£mero ?
          JB      num_end
          CMP     AL,'9'
          JA      num_end
          CMP     CS:l_nume,2
          JB      otro_n
          MOV     CL,CS:nume[1]
          MOV     CS:nume[0],CL
          JMP     num_nxt
otro_n:   INC     CS:l_nume
num_nxt:  MOV     BX,CS:l_nume
          DEC     BX
          MOV     CS:nume[BX],AL
          CALL    manda
          hb_c    speak
          JMP     num_loop
num_end:  MOV     DX,AX
          CALL    que_nume
          POP     BX
          CALL    rest_tecla
          RET
read_num  ENDP
;----------------------------------------------------------------------------
h_area    PROC ;habla el  rea indicada en AL.
          MOV     BH,0
          MOV     BL,AL
          CMP     CS:area_f1[BX],255
          JE      mal_area
          CMP     CS:area_f2[BX],255
          JE      mal_area
          MOV     AL,CS:area_f1[BX]
          MOV     CH,CS:area_c1[BX]
          MOV     AH,CS:area_f2[BX]
          MOV     CL,CS:area_c2[BX]
          CALL    area
          JMP     h_area_end
mal_area: hb      m_area_err
h_area_end:RET
h_area    ENDP
;----------------------------------------------------------------------------
area      PROC
; habla el area definida por AL,CH y AH,CL.
          SUB     CL,CH
          INC     CL
area_loop:PUSH    AX
          PUSH    CX
          CALL    part_line
          POP     CX
          POP     AX
          INC     AL
          CMP     AL,AH
          JBE     area_loop
          RET
area      ENDP
;----------------------------------------------------------------------------
part_line PROC
; habla el area definido por la l¡nea de pantalla indicada en AL ( 0 - 24 ),
; la columna indicada en CH ( 0 - 79 ) y con un ancho de CL caracteres.
          MOV     CS:f_pantalla,2
          MOV     BL,80*2
          MUL     BL
          MOV     DI,AX
          MOV     BL,2
          MOV     AL,CH
          MUL     BL
          ADD     DI,AX
          MOV     BH,0
          MOV     BL,CL
          CALL    habla
          RET
part_line ENDP
;----------------------------------------------------------------------------
find      PROC    ;buscar texto en pantalla.
          hb      m_find
          MOV     DI,OFFSET buffer
          MOV     CX,buffer_sz-1        ;por el cero binario de fin de cadena.
          CALL    read_str
          CMP     BX,0
          JE      anterior?
          MOV     CS:old_lbuffer,BX
          MOV     BYTE PTR CS:[DI],0    ;a¤adimos fin de cadena.
          JMP     busca
anterior?:CMP     CS:old_lbuffer,0
          JE      no_find
busca:    MOV     CS:f_pantalla,1
          MOV     BX,CS:old_lbuffer
          MOV     DI,OFFSET buffer
          CALL    habla
          MOV     CS:f_pantalla,2
          MOV     AX,CS:pantalla
          MOV     ES,AX
          CALL    find_cur
          MOV     BH,CS:fila
          MOV     BL,CS:colu
          CLD
          JMP     esta_no          ;para que busque a partir de la posici¢n
                                   ;siguiente.
bucle1:   MOV     DI,AX
          MOV     SI,OFFSET buffer
          MOV     CX,CS:old_lbuffer
bucle2:   CMPS    BYTE PTR [DI], BYTE PTR [SI]
          JNE     esta_no
          DEC     CX
          JZ      encontro
          INC     DI
          JMP     bucle2
esta_no:  INC     AX
          INC     AX
          INC     BL
          CMP     BL,79
          JBE     more
          MOV     BL,0
          INC     BH
          MOV     DL,CS:last_line
          CMP     BH,DL
          JA      no_find
more:     JMP     bucle1
encontro: MOV     CS:fila,BH
          MOV     CS:colu,BL
          RET
no_find:  hb      m_no_find
find_end: RET
find      ENDP
;----------------------------------------------------------------------------
read_str  PROC
; Esta rutina pide un string por teclado de CX m ximo caracteres y lo
; almacena en el buffer apuntado por CS:DI. Devuelve en BX el n§. de
; caracteres introducidos. Tambi‚n pinta en pantalla la cadena que debe 
; terminar en 0 ¢ en $.
          PUSH    SI                      ;lo guardamos por si acaso..
          CALL    save_ln                 ;salva l¡nea 1.
          CALL    draw_ln                 ;pinta blancos.
          CALL    draw_str                ;pinta cadena CS:[DI]
          MOV     BX,0
read_l:   MOV     AH,00
          INT     nue_tecla
          CMP     AL,cr
          JE      read_end
          CMP     BX,0
          JNE     no_primer
          CALL    draw_ln
no_primer:CALL    draw_chr
          CMP     AL,retroceso
          JNE     nobckspc
          CMP     BX,0
          JE      noborro
          MOV     AL,' '
          CALL    draw_chr
          MOV     AL,retroceso
          CALL    draw_chr
          DEC     BX
          DEC     DI
          MOV     AL,BYTE PTR CS:[DI]
          CALL    manda
          hb_c    speak
          MOV     BYTE PTR CS:[DI],' '
          JMP     read_l
noborro:  CALL    m_beep
          JMP     read_l
nobckspc: MOV     BYTE PTR CS:[DI],AL
          INC     DI
          CALL    manda
          hb_c    speak
          INC     BX
          CMP     BX,CX
          JB      read_l
read_end: CALL    rest_ln                    ;restaura l¡nea 1.
          POP     SI
          RET
read_str  ENDP
;----------------------------------------------------------------------------
draw_chr  PROC    ; Pinta en pantalla el car cter indicado en AL. (TTY)
          PUSH    BX
          MOV     AH,0EH
          MOV     BL,00011110B
          INT     nue_video
          POP     BX
          RET
draw_chr  ENDP
;----------------------------------------------------------------------------
save_ln   PROC    ; Copia en read_buff la primera l¡nea de pantalla.
          save_base
          MOV     AX,CS:pantalla
          MOV     DS,AX
          MOV     SI,0            ;DS:[SI] = direcci¢n primera l¡nea pantalla.
          PUSH    CS
          POP     ES
          LEA     DI,CS:read_buff ;ES:[DI] = direcci¢n buffer de copia.
          MOV     CX,80           ; mueve 80 palabras.
          CLD                     ; para que decremente.
          REP     MOVSW           ; muevelas! DS:[SI] -> ES:[DI]
          rest_base
          RET
save_ln   ENDP
;----------------------------------------------------------------------------
rest_ln   PROC    ; Restaura la primera l¡nea de pantalla desde read_buff.
                  ; Restaura tambi‚n posici¢n y tama¤o de cursor.
          save_base
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     DI,0            ;ES:[DI] = direcci¢n primera l¡nea pantalla.
          PUSH    CS
          POP     DS
          LEA     SI,CS:read_buff ;DS:[SI] = direcci¢n buffer de copia.
          MOV     CX,80           ; mueve 80 palabras.
          CLD                     ; para que decremente.
          REP     MOVSW           ; muevelas! DS:[SI] -> ES:[DI]
          MOV     AH,02H          ; recoloca cursor.
          MOV     BH,CS:pag_act
          MOV     DH,CS:fila
          MOV     DL,CS:colu
          INT     nue_video
          MOV     CH,0            ; redefine tama¤o cursor de revisi¢n.
          MOV     CL,7
          MOV     AH,01H
          INT     nue_video
          rest_base
          RET
rest_ln   ENDP
;----------------------------------------------------------------------------
draw_ln   PROC    ; Pinta en la l¡nea 1 CX invertidos y el resto en negro.
          save_base
          PUSH    CX              ;guarda longitud.
          MOV     AH,02           ;cursor a 0,0.
    	  MOV     BH,CS:pag_act
          MOV     DX,0            ;DH=fila, DL=columna.
          INT     nue_video
          MOV     CH,6            ; redefine tama¤o cursor.
          MOV     CL,7
          MOV     AH,01H
          INT     nue_video
          MOV     CX,80
          MOV     AH,09
          MOV     AL,' '
          MOV     BL,00000111B    ;blanco sobre negro.
	  INT     nue_video       ;pinta 80 espacios.
          POP     CX
          MOV     BL,00011110B    ;amarillo sobre azul.
          INT     nue_video       ;pinta CX blancos.
          rest_base
          RET
draw_ln   ENDP
;----------------------------------------------------------------------------
draw_str  PROC    ; Pinta en la l¡nea 1 la cadena apuntada CS:[DI] hasta 0 ¢ $.
          save_base
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     SI,0            ;ES:[SI] = direcci¢n primera l¡nea pantalla.
draw_loop:MOV     AL,BYTE PTR CS:[DI]
          CMP     AL,0
          JE      draw_end
          CMP     AL,'$'
          JE      draw_end
          MOV     BYTE PTR ES:[SI],AL              ;movemos caracter...
          INC     SI
          MOV     BYTE PTR ES:[SI],00011110B       ;movemos atributo.
          INC     SI
          INC     DI
          LOOP    draw_loop
draw_end: rest_base
	  RET
draw_str  ENDP
;----------------------------------------------------------------------------
h_word    PROC
; Esta rutina habla la palabra actual.
          PUSH    AX
          CALL    find_cur
          MOV     BX,CS:pantalla
          MOV     ES,BX
          MOV     CX,80
          MOV     BX,0
          MOV     DH,0
next:     CMP     BYTE PTR ES:[DI],espacio
          JE      si_space
          CMP     BYTE PTR ES:[DI],'ú'
          JNE     no_space
si_space: CMP     DI,AX
          JAE     now
          MOV     BX,0
          MOV     DH,0
          JMP     continue
no_space: CMP     DH,0
          JNE     is_word
          MOV     DH,1
          MOV     SI,DI
is_word:  INC     BX
continue: INC     DI
          INC     DI
          LOOP    next
now:      MOV     DI,SI
          CALL    habla
          POP     AX
          RET
h_word    ENDP
;----------------------------------------------------------------------------
quiet_line PROC
; definir linea silenciada.
          CALL    look_cur
          MOV     BH,0
          MOV     BL,DH
          MOV     AL,1
          SUB     AL,CS:t_ls[BX]
          MOV     CS:t_ls[BX],AL
          CMP     AL,0
          JE      l_activa
          LEA     DI,CS:m_line_des
          JMP     mandalo
l_activa: LEA     DI,CS:m_line_act
mandalo:  CALL    manda_str
          RET
quiet_line ENDP
;----------------------------------------------------------------------------
wrd_lft   PROC
          CALL    find_cur
          MOV     DI,AX
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     DH,0
w_l_loop: DEC     DI
          DEC     DI
          CMP     BYTE PTR ES:[DI],espacio
          JE      w_l_spc
          CMP     BYTE PTR ES:[DI],'ú'
          JE      w_l_spc
          MOV     DH,1
          JMP     w_l_nxt
w_l_spc:  CMP     DH,1
          JE      w_l_end
w_l_nxt:  CMP     CS:colu,0
          JA      dec_col
          CMP     CS:fila,0
          JBE     w_l_end
          DEC     CS:fila
          MOV     CS:colu,79
          hb      m_fin_l
          JMP     w_l_end
dec_col:  DEC     CS:colu
          CMP     CS:colu,0
          JNE     no_col_0
          CMP     BYTE PTR ES:[DI],espacio
          JNE     w_l_end
no_col_0: JMP     w_l_loop
w_l_end:  RET
wrd_lft   ENDP
;----------------------------------------------------------------------------
wrd_rgt   PROC
          CALL    find_cur
          MOV     DI,AX
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     DH,0
w_r_loop: CMP     BYTE PTR ES:[DI],espacio
          JE      w_r_spc
          CMP     BYTE PTR ES:[DI],'ú'
          JE      w_r_spc
          CMP     DH,1
          JNE     w_r_nxt
          JMP     w_r_end
w_r_spc:  MOV     DH,1
w_r_nxt:  INC     DI
          INC     DI
          CMP     CS:colu,79
          JB      inc_col
          MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     w_r_end
          INC     CS:fila
          MOV     CS:colu,0
          MOV     DH,1
          JMP     w_r_loop
inc_col:  INC     CS:colu
          CMP     CS:colu,79
          JB      w_r_loop
          hb      m_fin_l
w_r_end:  RET
wrd_rgt   ENDP
;----------------------------------------------------------------------------
h_llp     PROC    ;leer desde principio de l¡nea hasta cursor
          CALL    find_cur
          MOV     BX,AX
          SUB     BX,DI
          INC     BX
          SHR     BX,1
          CALL    habla
          RET
h_llp     ENDP
;----------------------------------------------------------------------------
h_llf     PROC    ;leer desde cursor hasta final de l¡nea
          CALL    find_cur
          MOV     BX,80*2
          ADD     BX,DI
          SUB     BX,AX
          SHR     BX,1
          MOV     DI,AX
          CALL    habla
          RET
h_llf     ENDP
;----------------------------------------------------------------------------
h_color   PROC
; habla el color del car cter actual o el color predominante en pantalla.
          CMP     CS:f_main,0
          JE      no_main
          JMP     main_clr
no_main:  hb      m_color1
          CALL    c_char
          INC     DI
          MOV     AL,BYTE PTR ES:[DI]
          CALL    s_color
          MOV     CS:f_pantalla,2
          MOV     CS:f_main,1
          RET
h_color   ENDP
;----------------------------------------------------------------------------
main_clr  PROC
; habla el color predominante en pantalla.
          hb      m_main
          CALL    make_tbl           ;construimos las tablas.
          MOV     AX,0
          MOV     BX,0
          MOV     CX,0
          MOV     DX,0
maxi_loop:CMP     AX,CS:t_f_att[BX]  ;buscamos m ximos..
          JAE     maxi_nxt
          MOV     AX,CS:t_f_att[BX]
          MOV     DX,BX
maxi_nxt: INC     BX
          INC     BX
          CMP     BX,2*128
          JB      maxi_loop
          SHR     DX,1
          MOV     AL,DL
          CALL    s_color
          MOV     CS:f_main,0
          RET
main_clr  ENDP
;----------------------------------------------------------------------------
make_tbl  PROC    ;construye la tabla de frecuencia de atributos.
          MOV     BX,0                ;ponemos a cero la tabla.
zero_loop:MOV     CS:t_f_att[BX],0
          INC     BX
          INC     BX
          CMP     BX,2*128
          JB      zero_loop
          MOV     AX,CS:pantalla
          PUSH    AX
          POP     ES
          MOV     DI,1
main_loop:MOV     BH,0
          MOV     BL,BYTE PTR ES:[DI]
          AND     BL,01111111B        ;quitamos el parpadeante
          SHL     BX,1
          INC     CS:t_f_att[BX]
          INC     DI
          INC     DI
          CMP     DI,CS:scr_size
          JB      main_loop
          RET
make_tbl  ENDP
;----------------------------------------------------------------------------
make_att  PROC    ;crea la tabla t_att con los atributos de menor a
                  ;mayor frecuencia a partir de t_f_att. n_att=n§ colores.
          MOV     CS:n_att,0
          MOV     DI,0
min_loop1:MOV     AX,0FFFFH
          MOV     BX,0
min_loop2:CMP     CS:t_f_att[BX],0
          JE      min_nxt
          CMP     AX,CS:t_f_att[BX]
          JBE     min_nxt
          MOV     AX,CS:t_f_att[BX]
          MOV     CX,BX
min_nxt:  INC     BX
          INC     BX
          CMP     BX,128*2
          JB      min_loop2
          CMP     AX,0FFFFH
          JE      min_end
          INC     CS:n_att
          MOV     BX,CX
          MOV     CS:t_f_att[BX],0
          SHR     BX,1                ;dividimos entre dos.
          MOV     CS:t_att[DI],BL
          INC     DI
          JMP     min_loop1
min_end:  RET
make_att  ENDP
;----------------------------------------------------------------------------
s_color   PROC
; hablar los colores de fondo y de tinta indicados en AL.
          PUSH    AX
          AND     AL,00001111B
          CALL    un_color
          hb      m_color2
          POP     AX
          PUSH    AX
          AND     AL,01110000B
          MOV     CL,4
          SHR     AL,CL
          CALL    un_color
          POP     AX
          AND     AL,10000000B
          JZ      color_out
          hb      m_parpa
color_out:RET
s_color   ENDP
;----------------------------------------------------------------------------
un_color  PROC ;habla el  color pasado en AL
          CMP     AL,255
          JE      all_color
          PUSH    BX
          MOV     BL,14
          MUL     BL
          LEA     DI,t_color
          ADD     DI,AX
          MOV     BX,14
          MOV     CS:f_pantalla,1
          CALL    habla
          POP     BX
          RET
all_color:hb      m_todos
          RET
un_color  ENDP
;----------------------------------------------------------------------------
h_ascii   PROC
          CALL    c_char
          MOV     AH,0
          MOV     BL,10
          DIV     BL
          OR      AH,30H
          MOV     CS:m_asc[2],AH
          MOV     AH,0
          DIV     BL
          OR      AX,3030H
          MOV     WORD PTR CS:m_asc,AX
          hb      m_ascii
          RET
h_ascii   ENDP
;----------------------------------------------------------------------------
h_pos     PROC
; Esta rutina habla la posici¢n actual del cursor.
          LEA     DI,m_pos_a    ;decir posicion del anunciador
          CMP     CS:f_pos_c,1
          JNE     donde?
          LEA     DI,m_pos_c    ;decir posicion del cursor
          CMP     CS:f_rev,1    ;estamos en revision?
          JNE     donde?
          MOV     DH,CS:fila_ant;posicion del cursor en revision.
          MOV     DL,CS:colu_ant
          JMP     ya_se
donde?:   CALL    look_cur
ya_se:    MOV     BL,10
          MOV     AH,0
          MOV     AL,DH
          INC     AL
          DIV     BL
          OR      AX,3030H
          MOV     WORD PTR CS:m_fila,AX
          MOV     AH,0
          MOV     AL,DL
          INC     AL
          DIV     BL
          OR      AX,3030H
          MOV     WORD PTR CS:m_colu,AX
          CALL    manda_str
          hb      m_fila
          MOV     CS:f_pos_c,0
          RET
h_pos     ENDP
;----------------------------------------------------------------------------
find_cur  PROC
; Esta rutina devuelve en DI la direccion de la memoria de pantalla donde
; comienza la l¡nea actual y en AX la direci¢n donde est  el cursor.
          MOV     CS:f_pantalla,2
          CALL    look_cur
          CALL    calcula
          RET
find_cur  ENDP
;----------------------------------------------------------------------------
calcula   PROC ;esta rutina devuelve en AX la direci¢n de la fila,col DH,DL
               ; y en DI la direcci¢n de la fila DH.
          PUSH    DX
          MOV     AX,1000H
          MOV     CL,CS:pag_act
          MOV     CH,0
          MUL     CX
          MOV     DI,AX
          MOV     AL,80*2
          POP     DX
          MUL     DH
          ADD     DI,AX
          MOV     AL,2
          MUL     DL
          ADD     AX,DI
          RET
calcula   ENDP
;----------------------------------------------------------------------------
look_cur  PROC
; Esta rutina realiza el seguimiento del cursor de soft. Busca un car cter
; y/o atributo. Devuelve en DH/DL la fila/columna. Si est  desactivado el
; seguimiento o estamos en revisi¢n, devuelve la posici¢n del cursor normal.
          PUSHF
          PUSH    AX
          PUSH    BX
          PUSH    DI
          PUSH    ES
          MOV     AH,0FH
          INT     nue_video
          MOV     CS:pag_act,BH
          CMP     CS:f_rev,1
          JE      no_soft
          CMP     CS:f_soft,0
          JNE     si_soft
no_soft:  MOV     AH,03H
          INT     nue_video
          JMP     cur_end
si_soft:  CMP     CS:f_soft,4  ;seguimiento de softc.inteligente o resaltado?
          JB      no_intel
          MOV     DH,CS:soft_fila
          MOV     DL,CS:soft_colu
          JMP     cur_end
no_intel: MOV     AX,CS:pantalla
          PUSH    AX
          POP     ES
          CMP     CS:soft_area,255
          JE      toda_pan
          MOV     BH,0
          MOV     BL,CS:soft_area
          CMP     CS:area_f1[BX],255
          JE      wrg_area
          MOV     DH,CS:area_f1[BX]
          MOV     DL,CS:area_c1[BX]
          CALL    calcula
          MOV     DI,AX
          JMP     lk_loop
wrg_area: MOV     CS:soft_area,255
toda_pan: MOV     DX,0
          MOV     DI,0
lk_loop:  MOV     AL,BYTE PTR ES:[DI]
          INC     DI
          CMP     CS:f_soft,1
          JE      por_atr
          CMP     AL,CS:soft_c
          JNE     lk_nxt
          CMP     CS:f_soft,3
          JE      por_atr
          JMP     compruebo
por_atr:  MOV     AL,BYTE PTR ES:[DI]
          CMP     AL,CS:soft_a
          JNE     lk_nxt
compruebo:CMP     CS:soft_area,255
          JE      cur_end
          CMP     DH,CS:area_f2[BX]
          JA      lk_nxt
          CMP     DL,CS:area_c1[BX]
          JB      lk_nxt
          CMP     DL,CS:area_c2[BX]
          JA      lk_nxt
          JMP     cur_end
lk_nxt:   INC     DI
          INC     DL
          CMP     DL,79
          JA      nxt_row
          JMP     lk_loop
nxt_row:  MOV     DL,0
          INC     DH
          CMP     DH,CS:last_line
          JA      lk_err
          JMP     lk_loop
lk_err:   MOV     DX,0
          hb      m_soft_err
cur_end:  POP     ES
          POP     DI
          POP     BX
          POP     AX
          POPF
          RET
look_cur  ENDP
;----------------------------------------------------------------------------
c_char    PROC
; Esta rutina devuelve el car cter actual en AL
          CALL    find_cur
          MOV     DI,AX
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     AL,BYTE PTR ES:[DI]
          RET
c_char    ENDP
;----------------------------------------------------------------------------
help      PROC
          hb      m_help
help_loop:MOV     AH,00
          INT     nue_tecla
          CMP     AL,cr
          JNE     in_help
          JMP     help_end
in_help:  LEA     DI,t_k_ayuda
          MOV     BX,0
help_find:CMP     CS:t_k_ayuda[BX],AL
          JE      si_help
          INC     BX
          CMP     BX,long_k_ayuda
          JAE     no_help
          CMP     BX,ult_ascii
          JNE     help_find
          MOV     AL,AH
          JMP     help_find
no_help:  CALL    callate
          hb      m_help_err
          JMP     help_loop
si_help:  CALL    callate
          MOV     AL,long_ayuda
          MUL     BL
          LEA     DI,t_ayuda
          ADD     DI,AX
          MOV     BX,long_ayuda
          MOV     CS:f_pantalla,1
          CALL    habla
          MOV     CS:f_pantalla,2
          JMP     help_loop
help_end: hb      m_help_end
          RET
help      ENDP
;----------------------------------------------------------------------------
filename  PROC    ;Pide nombre de archivo para grabar/recuperar configuraci¢n.
                  ;Si el nombre est  vacio devuelve BX = 255.
          MOV     CS:f_cargado,0  ;La operaci¢n la hacemos desde el residente.
          hb      m_nombre
          LEA     DI,conf_name
          MOV     CS:p_file,DI
          MOV     CX,conf_name_sz
          CALL    read_str
          CMP     BX,0                 ;se ha introducido nombre ?
          JA      put_end              ;si, pon fin de cadena y h blalo.
          CMP     BYTE PTR CS:[DI],' ' ;primer car cter espacio ?
          JNE     filen_end            ;no, conf_name no vacio.
          MOV     BX,255               ;si, conf_name vacio, no vale.
          JMP     filen_end
put_end:  MOV     BYTE PTR CS:[DI],0
          LEA     DI,conf_name
          MOV     CS:f_pantalla,1
          CALL    habla
          MOV     CS:f_pantalla,2
filen_end:RET
filename  ENDP
;----------------------------------------------------------------------------
r_conf    PROC    ;Rutina para recuperar configuraci¢n.
          MOV     DX,CS:p_file
          MOV     AL,0                    ;Abrir en input.
          MOV     AH,3DH
          INT     21H                     ;Abrir fichero. 
          JNC     openi_ok
          JMP     r_error
openi_ok: MOV     BX,AX              ;cargar variables.
          MOV     CX,conf_sz
          MOV     DX,OFFSET conf_area 
          MOV     AH,3FH             ;recuperar configuraci¢n.
          INT     21H
          JC      r_error
          CMP     CS:sintetizador,SINTE ;Vemos si la configuraci¢n fue grabada
          JE      elmismo               ; con el mismo sintetizador.
          MOV     CS:volu,VOLU_DEF      ;No es el mismo, resetea par metros
          MOV     CS:velo,VELO_DEF      ; de voz.
          MOV     CS:tono,TONO_DEF
          MOV     CS:sintetizador,SINTE ;La configurac¡on ya es de este sintet.
elmismo:  CALL    h_volu             ;Manda par metros de voz.
          CALL    h_velo
          CALL    h_tono
          CALL    h_otros
          hb      m_recu             ;Mensaje Ok.
          MOV     SI,CS:p_file       ;Como es recuperar configuraci¢n
          MOV     DI,OFFSET conf_name;copiamos el nombre de fichero a confname.
mv_loop:  MOV     AL,BYTE PTR CS:[SI]
          MOV     BYTE PTR CS:[DI],AL
          CMP     AL,0
          JE      mv_end
          INC     SI
          INC     DI
          JMP     mv_loop
mv_end:   CMP     CS:f_cargado,1     ;Est  ya Habla cargado en memoria ?
          JNE     no_cargao          ;No, terminamos.
          XOR     AX,AX              ;Si, tenemos que averiguar la direcci¢n
          MOV     ES,AX              ;donde est n conf_area en la memoria.
          MOV     DI,WORD PTR ES:d_video    ;utilizamos vector de video.
          MOV     AX,WORD PTR ES:d_video[2] 
          MOV     ES,AX              ;La direccion ser  ES:[DI] (destino).
          SUB     DI,conf_sz+1       ;el +1 es por la variable com.
          PUSH    CS
          POP     DS                 ;DS:[SI] (origen) conf_area.
          MOV     SI,OFFSET conf_area
          MOV     CX,conf_sz
          REP     MOVSB              ;copialo!
no_cargao:MOV     AH,3EH             ;cierra fichero.
          INT     21H
          JMP     r_out
r_error:  hb      m_error_file       ;mensaje de error.
r_out:    RET
r_conf    ENDP
;----------------------------------------------------------------------------
g_conf    PROC    ;Rutina para grabar configuraci¢n.
          MOV     DX,CS:p_file
          MOV     CX,0                      ;Abrir en i-o.
          MOV     AH,3CH
          INT     21H                       ;Abrelo!
          JNC     openio_ok
          JMP     g_error
openio_ok:MOV     BX,AX
          MOV     CX,conf_sz
          CMP     CS:f_cargado,1         ;Est  ya Habla cargado en memoria?
          JE      in_memory
          MOV     DX,OFFSET conf_area    ;CS:DX ->conf_area de este programa.
          JMP     grabando
in_memory:XOR     AX,AX                  ;lo que viene ahora es para guardar en
          MOV     ES,AX                  ;DS:DX la direcci¢n de la zona de
          MOV     DX,WORD PTR ES:d_video ;configuraci¢n del programa cargado.
          MOV     AX,WORD PTR ES:d_video[2]
          MOV     DS,AX
          SUB     DX,conf_sz+1       ;el +1 es por la variable com.
grabando: MOV     AH,40H             ;grabar configuraci¢n.
          INT     21H
          JC      g_error
          hb      m_grab             ;mensaje Ok.
          MOV     AH,3EH             ;cerrar fichero.
          INT     21H
          JMP     g_out
g_error:  hb      m_error_file       ;mensaje de error.
g_out:    RET
g_conf    ENDP
;----------------------------------------------------------------------------
hot       PROC
; Esta rutina gestiona todas las hotkeys.
          MOV     CS:f_hard_ok,1   ;suponemos que es una de las hotkey.
          CMP     AH,k_quiet       ;es una quickkey ?
          JE      is_quick
          CMP     AH,k_wait
          JE      is_quick
          CMP     AH,k_habla
          JE      is_quick
          CMP     AH,k_invalid
          JE      is_quick
          CMP     AH,k_rev
          JE      is_quick
          CMP     AH,k_rev2
          JE      is_quick
          guarda                   ;no es quickkey hay que guardar entorno.
is_quick: CMP     AH,k_quiet
          JNZ     k_wait?
IF SINTE EQ CIBER
          PUSH    AX
          hb_c    abort
          POP     AX
ELSE
          CALL    callate
ENDIF
          JMP     hot_end
k_wait?:  CMP     AH,k_wait
          JNZ     k_habla?
          CALL    callate
          MOV     CS:f_habla,0
          MOV     CS:f_wait,1
          JMP     hot_end
k_habla?: CMP     AH,k_habla
          JNZ     k_invalid?
          PUSH    DI
          CMP     CS:f_habla,1
          JE      speaking
          MOV     CS:f_habla,1
          hb      m_speak_on
          JMP     speak_out
speaking: hb      m_speak_off
          MOV     CS:f_habla,0
speak_out:POP     DI
          JMP     hot_end
k_invalid?:CMP     AH,k_invalid    ;no hacer caso a pr¢xima pulsaci¢n.
          JNZ     k_rev?
          MOV     CS:f_invalid,1
          JMP     hot_end
k_rev?:   CMP     AH,k_rev         ;entrar en revisi¢n?
          JNZ     k_rev2?
          MOV     CS:f_k_rev,1
          JMP     hot_end
k_rev2?:  CMP     AH,k_rev2        ;entrar en revisi¢n sin testear INDOS?
          JNZ     k_char?
          MOV     CS:f_k_rev,2     ;opci¢n suicida!!
          JMP     hot_end
k_char?:  CMP     AH,k_char               ;verbalizar caracter ?
          JNE     no_k_char
          CALL    callate
          CALL    h_char
          MOV     AL,1
          SUB     AL,CS:f_fonetica
          MOV     CS:f_fonetica,AL
          JMP     out_hard
no_k_char:MOV     CS:f_fonetica,0
k_word?:  CMP     AH,k_word               ;verbalizar palabra ?
          JNE     no_k_word
          CALL    callate
          CALL    h_word
          MOV     AL,1
          SUB     AL,CS:f_deletreo
          MOV     CS:f_deletreo,AL
          JMP     out_hard
no_k_word:MOV     CS:f_deletreo,0
k_wind?:  CMP     AH,k_wind               ;verbalizar ventana actual ?
          JNE     k_att?
          CALL    h_wind
          JMP     out_hard
k_att?:   CMP     AH,k_att                ;atributos en pantalla ?
          JNE     k_cc?
          CALL    h_att
          JMP     outhard   ;sal sin poner a cero c_att
k_cc?:    CMP     AH,k_cc   ;hablar lo que tenga el mismo color que el cursor?
          JNE     k_color?
          CALL    h_cc
          JMP     out_hard
k_color?: CMP     AH,k_color              ;verbalizar color actual
          JNE     no_k_color
          CALL    h_color
          JMP     out_hard
no_k_color:MOV    CS:f_main,0
k_fra?:   CMP     AH,k_fra                ;verbalizar frase actual ?
          JNE     k_case?
          CALL    h_fra
          JMP     out_hard
k_case?:  CMP     AH,k_case               ;verbalizar may£scula/min£scula ?
          JNE     k_ascii?
          CALL    h_case
          JMP     out_hard
k_ascii?: CMP     AH,k_ascii              ;verbalizar ascii actual
          JNE     k_m_tecl?
          CALL    h_ascii
          JMP     out_hard
k_m_tecl?:CMP     AH,k_m_tecla            ;modo comunicaion teclado ?
          JNE     k_m_vide?
          INC     CS:modo_tecla
          CMP     CS:modo_tecla,2
          JA      m_k_c
          LEA     DI,m_k_off
          JE      manda_m
          LEA     DI,m_k_palabra
          JMP     manda_m
m_k_c:    MOV     CS:modo_tecla,0
          LEA     DI,m_k_caracter
manda_m:  CALL    manda_str
          JMP     out_hard
k_m_vide?:CMP     AH,k_m_video            ;modo comunicaion video ?
          JNE     k_m_may?
          CMP     CS:modo_video,1
          MOV     CS:modo_video,0
          LEA     DI,m_v_on
          JE      manda_m
          MOV     CS:modo_video,1
          LEA     DI,m_v_off
          JMP     manda_m
k_m_may?: CMP     AH,k_m_may              ;modo indicaci¢n may£sculas ?
          JNE     k_s_s?
          hb      m_m_may
          CMP     CS:f_m_may,1
          MOV     CS:f_m_may,0
          LEA     DI,m_des
          JE      may_des
          MOV     CS:f_m_may,1
          LEA     DI,m_act
may_des:  CALL    manda_str
          JMP     out_hard
k_s_s?:   CMP     AH,k_s_s       ;modo indicaci¢n espacios ?
          JNE     k_s_l?
          hb      m_s_s
          CMP     CS:f_s_s,1
          MOV     CS:f_s_s,0
          LEA     DI,m_des
          JE      s_s_des
          MOV     CS:f_s_s,1
          LEA     DI,m_act
s_s_des:  CALL    manda_str
          JMP     out_hard
k_s_l?:   CMP     AH,k_s_l       ;modo indicaci¢n l¡neas en blanco ?
          JNE     k_m_rev?
          hb      m_s_l
          CMP     CS:f_s_l,1
          MOV     CS:f_s_l,0
          LEA     DI,m_des
          JE      s_l_des
          MOV     CS:f_s_l,1
          LEA     DI,m_act
s_l_des:  CALL    manda_str
          JMP     out_hard
k_m_rev?: CMP     AH,k_m_rev     ;modo de revision?
          JNE     k_scr?
          INC     CS:f_m_rev
          CMP     CS:f_m_rev,5
          JBE     m_rev_ok
          MOV     CS:f_m_rev,0
          LEA     DI,m_r_l
m_rev_fin:CALL    manda_str
          JMP     out_hard
m_rev_ok: LEA     DI,m_r_p
          CMP     CS:f_m_rev,1
          JE      m_rev_fin
          LEA     DI,m_r_c
          CMP     CS:f_m_rev,2
          JE      m_rev_fin
          LEA     DI,m_r_li
          CMP     CS:f_m_rev,3
          JE      m_rev_fin
          LEA     DI,m_r_w
          CMP     CS:f_m_rev,4
          JE      m_rev_fin
          LEA     DI,m_r_s
          JMP     m_rev_fin
k_scr?:   CMP     AH,k_scr       ;definir pantalla actual
          JNE     k_soft?
          CALL    d_scr
          JMP     out_hard
k_soft?:  CMP     AH,k_soft      ;activar/desactivar softcursor.
          JNE     k_soft2?
          hb      m_soft_pre
          INC     CS:f_soft
          LEA     DI,m_soft0
          CMP     CS:f_soft,6
          JE      soft0
          LEA     DI,m_soft1
          CMP     CS:f_soft,1
          JE      ok_soft
          LEA     DI,m_soft2
          CMP     CS:f_soft,2
          JE      ok_soft
          LEA     DI,m_soft3
          CMP     CS:f_soft,3
          JE      ok_soft
          LEA     DI,m_soft4
          CMP     CS:f_soft,4
          JE      ok_soft
          LEA     DI,m_soft5
          JMP     ok_soft
soft0:    MOV     CS:f_soft,0
ok_soft:  CALL    manda_str
          JMP     out_hard
k_soft2?: CMP     AH,k_soft2     ;activar o desactivar softcursor (breve) ?
          JNE     k_live?
          hb      m_soft_pre
          CMP     CS:f_soft,0
          MOV     CS:f_soft,5
          LEA     DI,m_soft5
          JE      ok_soft
          MOV     CS:f_soft,0
          LEA     DI,m_soft0
          JMP     ok_soft
k_live?:  CMP     AH,k_live      ;activar/silneciar l¡neas vivas ?
          JNE     k_kbd?
          INC     CS:f_live
          CMP     CS:f_live,4
          JBE     live_ok
          MOV     CS:f_live,0
live_ok:  LEA     DI,m_live_0
          CMP     CS:f_live,0
          JE      send_s
          LEA     DI,m_live_1
          CMP     CS:f_live,1
          JE      send_s
          LEA     DI,m_live_2
          CMP     CS:f_live,2
          JE      send_s
          LEA     DI,m_live_1
          CMP     CS:f_live,3
          JE      s_3o4
          LEA     DI,m_live_2
s_3o4:    CALL    manda_str
          LEA     DI,m_live_3
send_s:   CALL    manda_str
          JMP     out_hard
k_kbd?:   CMP     AH,k_kbd       ;activar/desactivar teclado externo ?
          JNE     k_graf?
IF SINTE EQ BS OR SINTE EQ PCH   ;esto s¢lo si hay teclado externo.
          hb      m_kbd
          CMP     CS:f_kbd,1
          MOV     CS:f_kbd,0
          LEA     DI,m_off
          JE      kbd_off
          MOV     CS:f_kbd,1
          LEA     DI,m_on
kbd_off:  CALL    manda_str
ENDIF
          JMP     out_hard
k_graf?:  CMP     AH,k_graf      ;activar/desactivar lectura de gr ficos ?
          JNE     k_str?
          hb      m_graf
          CMP     CS:f_graf,1
          MOV     CS:f_graf,0
          LEA     DI,m_des
          JE      graf_off
          MOV     CS:f_graf,1
          LEA     DI,m_act
graf_off: CALL    manda_str
          JMP     out_hard
k_str?:   CMP     AH,k_str       ;verbalizar linea ?
          JNE     k_lpp?
          CALL    h_linea
          JMP     out_hard
k_lpp?:   CMP     AH,k_lpp       ;hablar desde principio de pantalla ?
          JNE     k_lpf?
          CALL    callate
          CALL    h_lpp
          JMP     out_hard
k_lpf?:   CMP     AH,k_lpf       ;hablar hasta final de pantalla ?
          JNE     k_llp?
          CALL    callate
          CALL    h_lpf
          JMP     out_hard
k_llp?:   CMP     AH,k_llp       ;leer linea desde principio hasta cursor ?
          JNE     k_llf?
          CALL    callate
          CALL    h_llp
          JMP     out_hard
k_llf?:   CMP     AH,k_llf       ;leer linea desde cursor hasta final ?
          JNE     k_pos?
          CALL    callate
          CALL    h_llf
          JMP     out_hard
k_pos?:   CMP     AH,k_pos       ;verbalizar posici¢n del cursor ?
          JNE     k_vc?
          MOV     CS:f_pos_c,1
          CALL    callate
          CALL    h_pos
          JMP     out_hard
k_vc?:    CMP     AH,k_vc        ;verbalizar pantalla por colores ?
          JNE     k_line?
          CALL    vc
          JMP     out_hard
k_line?:  CMP     AH,k_line      ;linea a verbalizar ?
          JNE     k_coc?
          CALL    h_line
          JMP     out_hard
k_coc?:   CMP     AH,k_coc       ;lista (columna) actual ?
          JNE     k_auto?
          CALL    h_lis
          JMP     out_hard
k_auto?:  CMP     AH,k_auto      ;b£squeda de softcursor autom tica ?
          JNE     k_lecto?
          CALL    copy_scr
          MOV     CS:f_auto,1
          MOV     CS:f_no_hard,1
          hb      m_auto
          JMP     out_hard
k_lecto?: CMP     AH,k_lecto     ;modo lectura autom tica ?
          JNE     k_state?
          CMP     CS:f_rev,1
          JE      out_lecto
IF SINTE EQ AUDIO OR SINTE EQ ENPCH
          hb      inter_off      ;que el teclado no interrumpa la s¡ntesis
ENDIF
          hb      m_lecto
          CALL    h_linea
          MOV     CS:f_lecto,1
          MOV     CS:cuenta,0
out_lecto:JMP     out_hard
k_state?: CMP     AH,k_state     ;verbalizar l¡nea de estado ?
          JNE     k_stat2?
          MOV     AL,CS:t_state
          CALL    sta_line
          JMP     out_hard
k_stat2?: CMP     AH,k_stat2     ;verbalizar 2¦ l¡nea de estado ?
          JNE     no_hard
          MOV     AL,CS:t_stat2
          CALL    sta_line
          JMP     out_hard

no_hard:  MOV     CS:f_hard_ok,0 ;no es ninguna de estas teclas.
out_hard: MOV     CS:c_att,0     ;hablar primer atributo
outhard:  recupera
hot_end:  RET
hot       ENDP
;----------------------------------------------------------------------------
d_scr     PROC    ; Definir pantalla actual. Pide un n£mero entre 0 y 9.
          hb      m_scr
          CALL    pide_n
          CMP     AH,255
          JE      d_scr_end
          PUSH    AX
          CALL    save_scr   ;salvamos la pantalla actual en t_scr.
          POP     AX         ;AH guarda la pantalla a la que vamos.
          CALL    load_scr
          hb      scr_name
d_scr_end:RET
d_scr     ENDP
;----------------------------------------------------------------------------
d_lines   PROC    ;Definir n§ l¡neas de pantalla 25 ¢ 26.
          CMP     CS:num_lines,25  ;si es 25 pasa a 26 y vice-versa.
          JE      a_26
          MOV     CS:num_lines,25
          JMP     a_25
a_26:     MOV     CS:num_lines,26
a_25:     XOR     AX,AX            ;pasamos a ascii n§ l¡neas.
          MOV     AL,CS:num_lines
          MOV     BL,10
          DIV     BL
          OR      AX,3030H
          LEA     DI,m_lines
          MOV     WORD PTR CS:[DI], AX
          CALL    manda_str        ;habla mensaje!
          MOV     AL,CS:num_lines  ;calculamos las otras variables
          MOV     CS:last_line,AL
          DEC     CS:last_line     ;last_line = num_lines - 1.
          MOV     BL,80
          MUL     BL
          MOV     CS:scr_chars,AX  ;scr_chars = num_lines * 80.
          SHL     AX,1
          MOV     CS:scr_size,AX   ;scr_size = num_lines * 80 * 2.
          RET
d_lines   ENDP
;----------------------------------------------------------------------------
d_vivos   PROC    ; Definir caracteres vivos.
          hb      m_vivos
          CALL    read_num
          CMP     AL,9
          JA      d_vivos_e              ;n£mero incorrecto.
          XOR     BH,BH
          MOV     BL,AL                  ;BX = n§ de car cter vivo.
          SHL     BL,1                   ;multiplicamos por 2 (DWORD).
          CMP     DH,53H                 ;c¢digo de la tecla SUPR?
          JE      del_vivo               ;borra car cter vivo.
          CALL    c_char	         ;averigua car cter actual y posici¢n.
          MOV     AX, WORD PTR ES:[DI]
          MOV     CS:vivos_car[BX], AX   ;car cter.
          MOV     CS:vivos_pos[BX], DI   ;direcci¢n.
          LEA     SI,vivos_tip[BX]    ;cargo direcci¢n tabla tipos en SI.
          CALL    p_tipos             ;pide tipos a verbalizar.
          hb      m_vivos_ok
          JMP     d_vivos_e
del_vivo: MOV     CS:vivos_car[BX], 0FFFFH ;borro caracter vivo
          hb      m_vivos_off
d_vivos_e:RET
d_vivos   ENDP
;----------------------------------------------------------------------------
d_msg     PROC    ; Definir mensaje. Pide n§ de mensaje.
          hb      m_msg
          CALL    pide_n
          CMP     AH,255
          JE      d_msg_end              ;n£mero incorrecto.
          MOV     AL,AH                  ;calculamos posici¢n del mensaje.
          MOV     CL,LONG_MSG            ;AH lleva el n§ de mensaje.
          MUL     CL      
          MOV     SI,AX                  
          LEA     DI,t_msg[SI]           ;SI apunta al principio del mensaje.
          MOV     CX,LONG_MSG-2          ;restamos 2 para espacio y $.
          CALL    read_str
          CMP     BX,0                   ;se ha pulsado algo?
          JA      pon_fin                ;si, ponle fin cadena.
          CMP     BYTE PTR CS:[DI],' '   ;primer caracter vacio?
          JNE     msg_fin                ;no, la cadena no est  vacia.
pon_fin:  MOV     BYTE PTR CS:[DI],' '   ;a¤adimos fin de cadena.
          MOV     BYTE PTR CS:[DI+1],'$'
msg_fin:  hb      t_msg[SI]
d_msg_end:RET
d_msg     ENDP
;----------------------------------------------------------------------------
sta_line  PROC    ; Verbalizar linea de estado indicada en AL.
          PUSH    AX
          CALL    callate
          POP     AX
          MOV     CX,80
          CALL    part_line
          RET
sta_line  ENDP
;----------------------------------------------------------------------------
pide_n    PROC
;pide un n£mero entre 0 y 9. Intro supone 0. Devuelve AH=n£mero( AH=255 error)
          MOV     CS:f_no_hard,1
          MOV     AH,00
          CALL    camb_tecla
          INT     nue_tecla
          CALL    rest_tecla
          MOV     CS:f_no_hard,0
          CMP     AL,cr
          JE      enter
          CMP     AL,"0"
          JB      nume_mal
          CMP     AL,"9"
          JA      nume_mal
          JMP     pide_ok
enter:    MOV     AL,"0"
pide_ok:  MOV     AH,AL
          hb_c    AL
          hb_c    speak
          SUB     AH,"0"
          JMP     pide_end
nume_mal: hb      m_error1
          MOV     AH,255
pide_end: RET
pide_n    ENDP
;----------------------------------------------------------------------------
tst_vivas PROC    ;Testea la variaci¢n de l¡neas vivas.
          save
          XOR     BX,BX
test_loop:CMP     CS:t_l_l[BX],0   ;esta definida ?
          JE      nxt_test
          CALL    variables        ;carga punteros
          REPE    CMPSW            ;son iguales ?
          JE      nxt_test         ;si, el siguiente.
          CALL    variables        ;no, copialo.
          REP     MOVSW
          CMP     CS:f_copy,1
          JE      nxt_test
          MOV     DX,CS:t_l_t[BX]
          CALL    h_tipos          ;habla seg£n tabla de tipos.
nxt_test: INC     BX
          INC     BX
          MOV     AL,CS:num_lines
          SHL     AL,1             ;multiplica por 2.
          CMP     BL,AL
          JB      test_loop
test_end: MOV     CS:f_copy,0
          restore
          RET
tst_vivas ENDP
;----------------------------------------------------------------------------
variables PROC
; carga en ES:DI la direcci¢n de la zona de copia de pantalla y en
; DS:SI la dirreci¢n de la zona de pantalla a explorar.
          CLD
          MOV     CX,CS:t_l_l[BX]  ; CX=n§ de palabras a comprobar.
          PUSH    CS               ; ES:DI apunta a la zona de copia
          POP     ES
          LEA     DI,CS:t_copy
          MOV     AL,live_wide     ; live_wide de ancho
          MUL     BL
          ADD     DI,AX
          MOV     AX,CS:pantalla   ; DS:SI apunta a la zona de pantalla
          MOV     DS,AX
          MOV     SI,CS:t_live[BX]
          RET
variables ENDP
;----------------------------------------------------------------------------
h_tipos   PROC    ;Habla l¡nea,  rea o mensaje, para l¡neas y caracteres vivos.
                  ; recibe BX = n§ l¡nea * 2, tipo en DX.
          CMP     CS:f_live,1
          JE      no_calla
          CMP     CS:f_live,2
          JE      no_calla
          hb_c    quiet
no_calla: CMP     CS:f_live,2
          JE      no_pita
          CMP     CS:f_live,4
          JE      no_pita
          CALL    m_beep
no_pita:  CMP     DX,255
          JE      ver_lin
          MOV     AX,DX
          CMP     AH,k_area          ;verbalizar  rea?
          JE      ver_are
          CMP     AH,k_v_msg         ;verbalizar mensaje?
          JNE     ver_lin            ;no, suponemos l¡nea.
          MOV     CL,LONG_MSG        ;verbalizar mensaje, calculamos posici¢n. 
          MUL     CL                 ;AL lleva el n§ de mensaje.
          MOV     SI,AX
          hb      t_msg[SI]          ;hablalo!
          JMP     h_tipos_e
ver_are:  PUSH    BX                 ;verbalizar  rea
          CALL    h_area
          POP     BX
          JMP     h_tipos_e
ver_lin:  MOV     AL,BL              ;verbalizar l¡nea
          SHR     AL,1               ;divide entre dos
          MOV     CX,80
          PUSH    BX
          CALL    part_line
          POP     BX
h_tipos_e:RET
h_tipos   ENDP
;----------------------------------------------------------------------------
tst_vivos PROC    ;Testea la aparici¢n/desaparici¢n de caracteres vivos.
          save
          XOR     BX,BX                   ;puesta a cero
tst_loop: CMP     CS:vivos_car[BX],0FFFFH ;esta definido ?
          JE      nxt_tst
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     SI,CS:vivos_pos[BX]    ;ES:[SI] puntero a pantalla.
          MOV     AX,CS:vivos_car[BX]    ;AX car ct. y atributo.
          CMP     AX, WORD PTR ES:[SI]   ;ha aparecido el car cter en pant.?
          JE      vivos_act              ;si.
          CMP     CS:f_vivos[BX],1       ;no, estaba ya pintado ?
          JNE     nxt_tst                ;no, no hagas nada.
          CALL    m_beep                 ;si, pitido para avisar que se ha
          MOV     CS:f_vivos[BX],0       ; borrado. Ponemos a cero.
          JMP     nxt_tst
vivos_act:CMP     CS:f_vivos[BX],1       ;Estaba ya pintado ?
          JE      nxt_tst                ;si, no hagas nada.
          MOV     CS:f_vivos[BX],1       ;no, habla lo que tengas que hablar..
          MOV     DX,CS:vivos_tip[BX]    ;movemos tipo.
          MOV     AX,CS:vivos_pos[BX]    ;calculamos fila a partir de posici¢n.
          PUSH    BX
          MOV     BL,80
          DIV     BL
          MOV     BL,AL                  ;BL lleva la fila * 2.
          CALL    h_tipos                ;habla seg£n tabla de tipos.
          POP     BX
nxt_tst:  INC     BX                     ;incrementamos 2 veces (DWORD).
          INC     BX
          CMP     BX,10*2                ;10 * 2 bytes.
          JB      tst_loop
          restore
          RET
tst_vivos ENDP
;----------------------------------------------------------------------------
suena     PROC    ;Produce sonido BH=periodo, BL=duraci¢n (en 18 avos de seg).
          PUSH    AX
          MOV     AL,182          ;Enviamos periodo al temporizador..
          OUT     43H,AL
          MOV     AL,0
          OUT     42H,AL
          MOV     AL,BH           ;envio periodo.
          OUT     42H,AL
          IN      AL,61H          ;Leer bit de control del altavoz.
          OR      AL,00000011B
          OUT     61H,AL          ;activar sonido.
          MOV     CS:f_clock,BL   ;duraci¢n en 18 avos de seg.
          POP     AX
          RET
suena     ENDP
;----------------------------------------------------------------------------
sonido    PROC
; produce un pitido agudo (AH=1) o grave (AH=0).
          PUSH    BX
          MOV     BH,10   ;periodo (suponemos pitido agudo).
          CMP     AH,1
          JE      agudo
          MOV     BH,15  ;pitido grave.
agudo:    MOV     BL,2   ;duraci¢n (2 / 18 seg)
          CALL    suena
          POP     BX
          RET
sonido    ENDP
;----------------------------------------------------------------------------
m_beep    PROC    ; pitido de aviso.
          PUSH    BX
          MOV     BH,7   ;periodo (agudo)
          MOV     BL,1   ;duraci¢n (2 / 18 seg)
          CALL    suena
          POP     BX
          RET
m_beep    ENDP
;----------------------------------------------------------------------------
m_beep2   PROC    ; pitido suave de aviso de cambio de l¡nea.
          PUSH    BX
          MOV     BH,5   ;periodo (agudo)
          MOV     BL,1   ;duraci¢n (1 / 18 seg)
          CALL    suena
          POP     BX
          RET
m_beep2   ENDP
;----------------------------------------------------------------------------
copy_scr  PROC    ;Copia la pantalla en t_copy.
          CALL    set_var
          REP     MOVSW
          RET
copy_scr  ENDP
;----------------------------------------------------------------------------
set_var   PROC    ;prepara variables para copiar pantalla en t_copy.
          MOV     AH,0FH
          INT     nue_video
          MOV     AX,1000H
          MOV     CL,BH
          MOV     CH,0
          MUL     CX
          MOV     SI,AX
          MOV     AX,CS:pantalla   ; DS:SI apunta a la zona de pantalla
          MOV     DS,AX
          CLD
          MOV     CX,CS:scr_chars  ; N£mero de caracteres en pantalla.
          PUSH    CS               ; ES:DI apunta a la zona de copia
          POP     ES
          LEA     DI,CS:t_copy
          RET
set_var   ENDP
;----------------------------------------------------------------------------
scan_soft PROC    ; Definir autom ticamente el softcursor.
          PUSH    DS
          PUSH    ES
          CALL    set_var
          REPE    CMPSW
          MOV     CS:f_soft,0
          JE      scan_err
          DEC     SI
          DEC     SI
          DEC     DI
          DEC     DI
          MOV     AX,WORD PTR DS:[SI]
          MOV     BX,WORD PTR ES:[DI]
          DEC     SI
          DEC     SI
          MOV     CX,WORD PTR DS:[SI]
          CMP     AH,BH
          JE      soft_car
          CMP     AH,CH
          JE      bh?
          MOV     CS:soft_a,AH
          MOV     CS:f_soft,1
          JMP     soft_car
bh?:      CMP     BH,CH
          JE      soft_car
          MOV     CS:soft_a,BH
          MOV     CS:f_soft,1
soft_car: CMP     AL,BL
          JE      atr_only
          CMP     AL,CL
          JE      bl?
          MOV     CS:soft_c,AL
          JMP     car_soft
bl?:      CMP     BL,CL
          JE      atr_only
          MOV     CS:soft_c,BL
car_soft: CMP     CS:f_soft,0
          MOV     CS:f_soft,2
          JE      atr_only
          INC     CS:f_soft
atr_only: POP     ES
          POP     DS
          hb      m_auto_ok
          RET
scan_err: POP     ES
          POP     DS
          hb      m_auto_err
          RET
scan_soft ENDP
;----------------------------------------------------------------------------
chk_inteli PROC   ;localiza softcursor inteligente.
           save
           CMP     CS:f_soft,5   ;es softcursor inteligente ?
           JNE     no_moved      ;no
           MOV     AH,03         ;si, mira si es visible el cursor..
           MOV     BH,CS:pag_act
           INT     nue_video
           AND     CH,01100000B
           JNZ     no_moved      ;no es visible.
           CMP     DX,CS:pos_ant ;si es visible. Se ha movido ?
           JE      no_moved      ;no
           MOV     CS:pos_ant,DX ;si actualizamos la nueva posici¢n.
           MOV     CS:soft_fila,DH
           MOV     CS:soft_colu,DL
           MOV     CS:f_moved,1
           JMP     end_inteli    ;no miramos softcursor.
no_moved:  CALL    set_var       ;miramos softcursor.
cmp_inteli:INC     SI            ;s¢lo comprobamos atributos.
           INC     DI
           CMPSB
           JNE     findit
no_findit: LOOP    cmp_inteli
           JMP     not_found
findit:    PUSH    SI
           PUSH    DI
           DEC     SI
           DEC     DI
           MOV     AL,BYTE PTR DS:[SI]
           AND     AL,01110000B  ;s¢lo el color de fondo
           MOV     BL,BYTE PTR ES:[DI]
           AND     BL,01110000B
           CMP     AL,BL
           JE      nomevale
           DEC     SI
           DEC     SI
           MOV     BL,BYTE PTR DS:[SI]
           AND     BL,01110000B
           CMP     AL,BL
nomevale:  POP     DI
           POP     SI
           JE      no_findit
           CMP     CS:f_moved,1  ;se movio el cursor normal ?
           JE      si_moved      ;si se movio, no hacer caso al softcursor.
           MOV     AX,CS:scr_chars ;calculamos fila y columna..
           SUB     AX,CX
           MOV     BL,80
           DIV     BL
           MOV     CS:soft_fila,AL
           MOV     CS:soft_colu,AH
si_moved:  CALL    copy_scr     ;actualizamos la copia.
not_found: MOV     CS:f_moved,0
end_inteli:restore
out_inteli:RET
chk_inteli ENDP
;---------------------------------------------------------------------------
h_fra     PROC
; Verbalizar frase actual
          hb_c    quiet                 ;callamos HABLA
          CALL    find_cur              ;busca cursor. AX=direcc¡on pantalla
          MOV     BX,CS:pantalla
          MOV     ES,BX
          MOV     DI,0                  ;DI contiene el comienzo de frase.
          MOV     SI,0                  ;SI va explorando la pantalla
          MOV     BX,0                  ;BX mide la longitud de la frase.
fra_loop: CALL    miraver               ;es un signo de puntuaci¢n ?
          JZ      si_signo              ;si, lo es.
          INC     BX                    ;no, no lo es.
          JMP     fra_next
si_signo: CMP     SI,AX                  ;estamos detr s del cursor ?
          JB      no_fra                 ;no, a£n no hemos llegado.
          JE      en_signo               ;si, y estamos sobre un signo.
          INC     BX
          JMP     fra_end
en_signo: MOV     BX,1                   ;el cursor sobre un signo de punt.
          MOV     DI,SI
          JMP     fra_end
no_fra:   MOV     BX,0                   ;marcamos principio de frase.
          MOV     DI,SI
          INC     DI
          INC     DI
fra_next: INC     SI                     ;seguimos avanzando.
          INC     SI
          CMP     SI,CS:scr_size         ;fin de pantalla?
          JB      fra_loop
fra_end:  CALL    habla                  ;h blala.
          RET
h_fra     ENDP
;----------------------------------------------------------------------------
fraa      PROC
;frase anterior
          CALL    find_cur
          MOV     SI,AX                  ;SI recorre la pantalla.
          MOV     AX,CS:pantalla
          MOV     ES,AX
          DEC     SI                     ;Retrocedemos por si estamos
          DEC     SI                     ;a principio de frase.
          JMP     fraa_dec
fraa_loop:DEC     SI
          DEC     SI
          CALL    miraver                ;es un signo de puntuaci¢n ?
          JZ      fraa_end               ;si, es un signo de puntuaci¢n.
fraa_dec: CMP     CS:colu,0
          JA      fraa_col
          CMP     CS:fila,0
          JBE     fraa_beep
          DEC     CS:fila
          MOV     CS:colu,79
          JMP     fraa_loop
fraa_col: DEC     CS:colu
          JMP     fraa_loop
fraa_beep:CALL    m_beep
fraa_end: RET
fraa      ENDP
;----------------------------------------------------------------------------
fras      PROC
;frase siguiente
          CALL    find_cur
          MOV     SI,AX
          MOV     AX,CS:pantalla
          MOV     ES,AX
          MOV     BH,0                 ;indica que a£n no hemos encontrado
fras_loop:CALL    miraver              ; es un signo de puntuaci¢n ?
          JNZ     fras_mal             ;no encontramos signo.
          MOV     BH,1                 ;encontramos frase.
fras_mal: INC     SI
          INC     SI
          CMP     CS:colu,79
          JB      fras_inc
          MOV     AL,CS:last_line
          CMP     CS:fila,AL
          JAE     fras_beep
          INC     CS:fila
          MOV     CS:colu,0
          JMP     fras_next
fras_inc: INC     CS:colu
fras_next:CMP     BH,1
          JE      fras_end
          JMP     fras_loop
fras_beep:CALL    m_beep
fras_end: RET
fras      ENDP
;----------------------------------------------------------------------------
miraver   PROC ;mira si lo que hay en ES:[SI] es un signo de puntuaci¢n.
          PUSH    AX
          MOV     AL,BYTE PTR ES:[SI]
          PUSH    DI
          PUSH    ES
          PUSH    CS
          POP     ES
          CLD
          LEA     DI,signos
          MOV     CX,long_signos
          REPNE   SCASB
          POP     ES
          POP     DI
          POP     AX
          RET
miraver   ENDP
;----------------------------------------------------------------------------
h_att     PROC    ;habla la pantalla por atributos detectados automat.
          hb_c    quiet
          CALL    make_tbl
          CALL    make_att
          MOV     BL,CS:c_att
          CMP     BL,CS:n_att
          JB      att_ok
          MOV     CS:c_att,0
          MOV     BL,0
att_ok:   CMP     BL,0           ;es el primer color ?
          JNE     no_prim
          CALL    m_beep
no_prim:  MOV     BH,0
          MOV     AL,CS:t_att[BX]
          PUSH    AX
          CALL    s_color
          POP     AX
          MOV     AH,AL
          AND     AH,00001111B    ;AH=tinta
          MOV     CL,4
          SHR     AL,CL           ;AL=fondo
          MOV     CH,255          ;CH=parpadeante: todos
          CALL    vcolor
          INC     CS:c_att
          RET
h_att     ENDP
;----------------------------------------------------------------------------
h_cc      PROC    ;habla lo que tiene el mismo fondo que el cursor.
          hb_c    quiet
          CALL    c_char
          INC     DI
          MOV     AL,BYTE PTR ES:[DI]
          MOV     CL,4
          SHR     AL,CL           ;AL=fondo
          MOV     AH,255          ;AH=tinta :todos
          MOV     CH,255          ;CH=parpadeante: todos
          CALL    vcolor
          RET
h_cc      ENDP
;----------------------------------------------------------------------------
clr_buff  PROC    ;esta rutina vacia el buffer del teclado. (tail=head).
          PUSH    BX
          PUSH    ES
          MOV     BX, 40H
          MOV     ES, BX
          MOV     BX, WORD PTR ES:head
          MOV     WORD PTR ES:tail, BX
          POP     ES
          POP     BX
          RET
clr_buff  ENDP
;----------------------------------------------------------------------------
entrada   PROC
; Esta rutina introduce el buffer de teclado la tecla indicada en AX. Si el
; buffer est  lleno pita.
          PUSH    BX
          PUSH    DI
          PUSH    ES
          MOV     BX, 40H
          MOV     ES,BX
          MOV     DI, WORD PTR ES:tail
          MOV     BX,DI
          INC     DI
          INC     DI
          CMP     DI, OFFSET last_w
          JBE     no_last
          MOV     DI, OFFSET first_w
no_last:  CMP     DI, WORD PTR ES:head
          JE      buff_full
          MOV     WORD PTR ES:[BX],AX
          MOV     WORD PTR ES:tail,DI
          JMP     entra_end
buff_full:CMP     CS:f_lecto,1
          JE      entra_end
          CALL    m_beep
entra_end:POP     ES
          POP     DI
          POP     BX
          IN      AL,tec1     ;esto es para que se crea que se ha pulsado
          AND     AL,7FH      ;una tecla.(le apago el MSB en tec1)
          OUT     tec1,AL
          RET
entrada   ENDP
;----------------------------------------------------------------------------
h_linea   PROC
; Esta rutina habla la l¡nea actual
          PUSH    AX
          CMP     CS:f_lecto,1
          JE      silecto
          CALL    callate
silecto:  CALL    find_cur
          MOV     BX,80
IF SINTE EQ AUDIO OR SINTE EQ PCH OR SINTE EQ ENPCH
          MOV     CS:f_concat,1
          CALL    habla
          MOV     CS:f_concat,0
ELSE
          CALL    habla
ENDIF
          POP     AX
          RET
h_linea   ENDP
;----------------------------------------------------------------------------
h_case    PROC
; Esta rutina habla el car cter actual e indica si es may£scula o min£scula
          CALL    callate
          CALL    h_char
          CALL    c_char
          CMP     AL,"¥"
          JE      es_may
          CMP     AL,"¤"
          JE      es_min
          CMP     AL,'A'
          JB      no_letra
          CMP     AL,'Z'
          JBE     es_may
          CMP     AL,'a'
          JB      no_letra
          CMP     AL,'z'
          JA      no_letra
es_min:   LEA     DI,m_min
          JMP     es_letra
es_may:   CMP     CS:f_m_may,1  ; si esta activo el modo indic. mays., no decir
          JE      no_letra      ; may£scula de nuevo.
          LEA     DI,m_may
es_letra: CALL    manda_str
no_letra: RET
h_case    ENDP
;----------------------------------------------------------------------------
