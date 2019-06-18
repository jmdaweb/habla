; Variables y rutinas para la gesti¢n de teclado Braille.

f_p               DB     0    ;indica si se pulso cor-P.
f_mayfix          DB     0    ;indica si esta fija la may£scula en el B.S.
f_maytmp          DB     0    ;indica si se ha pulsado may£s. temporal en B.S.
f_espe            DB     0    ;indica prefijo de car†cter especial en B.S.
f_ctrl            DB     0    ;indica prefijo de car†cter control en B.S.
f_alte            DB     0    ;indica prefijo de car†cter con ALT en B.S.
f_ascii           DB     0    ;indica prefijo de c¢digo ASCII en B.S.
n_ascii           DB     ?  ;n£mero ascii introducido desde B.H.
m_hotkey          DB     quiet,"hotkey $"
m_hot_err         DB     quiet,"comando incorrecto $"
m_mayfix          DB     quiet,"modo may£scula $"
m_maytmp          DB     quiet,"may£scula $"
m_espe            DB     quiet,"especial $"
m_ctrl            DB     quiet,"control $"
m_alte            DB     quiet,"alt $"
m_p_ascii         DB     quiet,"ascii $"
                  ;tabla de correspondencia Braille Hablado/Scancode(AH)
t_scan            DB     00H, 1EH, 33H, 30H, 34H, 25H, 33H, 26H, 0CH, 2EH ;9
                  DB     17H, 21H, 08H, 32H, 1FH, 19H, 03H, 12H, 34H, 23H ;19
                  DB     29H, 18H, 1BH, 13H, 1AH, 20H, 24H, 22H, 01H, 31H ;29
                  DB     14H, 10H, 35H, 02H, 06H, 03H, 35H, 16H, 2BH, 2FH ;39
                  DB     28H, 04H, 0AH, 07H, 0BH, 2DH, 05H, 07H, 03H, 06H ;49
                  DB     1BH, 09H, 2BH, 2CH, 0BH, 09H, 06H, 05H, 11H, 08H ;59
                  DB     04H, 15H, 0AH, 02H, 39H, 48H, 73H, 0EH, 4BH, 25H ;69
                  DB     47H, 49H, 50H, 25H, 52H, 21H, 00H, 00H, 00H, 00H ;79
                  DB     74H, 01H, 20H, 23H, 28H, 00H, 1BH, 13H,0E0H, 53H ;89
                  DB     24H, 22H, 00H, 00H, 0FH, 10H, 4DH, 3BH, 0CH, 3CH ;99
                  DB     2EH, 16H, 00H, 00H, 1CH, 3DH, 43H, 40H, 44H, 2DH ;109
                  DB     00H, 00H, 4FH, 3FH, 1BH, 42H, 00H, 00H, 0DH, 00H ;119
                  DB     51H, 3EH, 27H, 41H, 1CH, 00H, 00H, 00H           ;127
                  ;tabla de correspondencia Braille Hablado/ASCII(AL).
t_ascii           DB     00H, "a", ",", "b", ".", "k", ";", "l", "'", "c" ;9
                  DB     "i", "f", "/", "m", "s", "p", "@", "e", ":", "h" ;19
                  DB     "}", "o", "+", "r", "^", "d", "j", "g", "|", "n" ;29
                  DB     "t", "q", "_", "1", "?", "2", "-", "u", "<", "v" ;39
                  DB     "{", "3", "9", "6", "0", "x", "$", "&", '"', "5" ;49
                  DB     "*", "8", ">", "z", "=", "(", "%", "4", "w", "7" ;59
                  DB     "#", "y", ")", "\", " ", 00H, 00H, 08H, 00H, "k" ;69
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;79
                  DB     00H, 1BH, 00H, 00H, "}", 00H, "+", "r", 0DH, 00H ;89
                  DB     00H, "g", 00H, 00H, 09H, "q", 00H, 00H, "?", 00H ;99
                  DB     00H, "u", 00H, 00H, 0DH, 00H, 00H, 00H, 00H, "x" ;109
                  DB     00H, 00H, 00H, 00H, "*", 00H, 00H, 00H, "=", 00H ;119
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H           ;127
                  ; tabla de tipos de pulsaciones, s¢lo para las teclas COR.
t_tipo            DB                         0,   0,   0,   0,   0,   2   ;69
                  DB     0,   0,   0,   1,   0,   1,   0,   0,   0,   0   ;79
                  DB     0,   0,   1,   1,   2,   0,   2,   2,   0,   0   ;89
                  DB     1,   2,   0,   0,   0,   2,   0,   0,   2,   0   ;99
                  DB     1,   2,   0,   0,   0,   0,   0,   0,   0,   2   ;109
                  DB     0,   0,   0,   0,   2,   0,   0,   0,   2,   0   ;119
                  DB     0,   0,   1,   0,   1,   0,   0,   0             ;127

t_espe            DB     "aeioun?" ;tabla de caracteres especiales para B.S.
long_espe         EQU    $-t_espe
                  DB     "†Ç°¢£§®"
                  DB     "ÑâãîÅn?"
                  DB     "Öäçïón?"
                  DB     "Éàåìñn?"
t_ctrl_h          DB     00H, 01H, 00H, 03H, 00H, 00H, 00H, 07H, 00H, 00H ;9
                  DB     00H, 00H, 0CH, 00H, 0EH, 00H, 10H, 11H, 12H, 13H ;19
                  DB     14H, 15H, 16H, 17H, 18H, 19H, 00H, 00H, 1CH, 00H ;29
                  DB     1EH, 1FH, 20H, 21H, 22H, 23H, 24H, 25H, 26H, 00H ;39
                  DB     00H, 00H, 00H, 2BH, 2CH, 2DH, 2EH, 2FH, 30H, 31H ;49
                  DB     32H, 00H, 00H, 00H, 00H, 72H, 00H, 39H, 00H, 5EH ;59
                  DB     5FH, 60H, 61H, 62H, 63H, 64H, 65H, 66H, 67H, 00H ;69
                  DB     00H, 77H, 00H, 84H, 00H, 73H, 00H, 74H, 00H, 75H ;79
                  DB     00H, 76H, 00H, 00H                               ;83
t_ctrl_l          DB     00H, 13H, 00H, 00H, 00H, 00H, 00H, 1EH, 00H, 00H ;9
                  DB     00H, 00H, 1FH, 00H, 7FH, 00H, 11H, 17H, 05H, 12H ;19
                  DB     14H, 19H, 15H, 09H, 0FH, 10H, 00H, 00H, 0AH, 00H ;29
                  DB     01H, 13H, 04H, 06H, 07H, 08H, 0AH, 0BH, 0CH, 00H ;39
                  DB     00H, 00H, 00H, 1CH, 1AH, 18H, 03H, 16H, 02H, 0EH ;49
                  DB     0DH, 00H, 00H, 00H, 00H, 00H, 00H, 20H, 00H, 00H ;59
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;69
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;79
                  DB     00H, 00H, 00H, 00H                               ;83
t_alte_h          DB     00H, 00H, 78H, 79H, 7AH, 7BH, 7CH, 7DH, 7EH, 7FH ;9
                  DB     80H, 81H, 82H, 83H, 00H, 00H, 10H, 11H, 12H, 13H ;19
                  DB     14H, 15H, 16H, 17H, 18H, 19H, 00H, 00H, 00H, 00H ;29
                  DB     1EH, 1FH, 20H, 21H, 22H, 23H, 24H, 25H, 26H, 00H ;39
                  DB     00H, 00H, 00H, 00H, 2CH, 2DH, 2EH, 2FH, 30H, 31H ;49
                  DB     32H, 00H, 00H, 00H, 00H, 00H, 00H, 39H, 00H, 68H ;59
                  DB     69H, 6AH, 6BH, 6CH, 6DH, 6EH, 6FH, 70H, 71H, 00H ;69
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;79
                  DB     00H, 00H, 00H, 00H                               ;83
t_alte_l          DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;9
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;19
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;29
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;39
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;49
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;59
                  DB     00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H ;69
                  DB     00H, 07H, 08H, 09H, 00H, 04H, 05H, 06H, 00H, 01H ;79
                  DB     02H, 03H, 00H, 00H                               ;83
;----------------------------------------------------------------------------
bra_kbd   PROC    ;Gesti¢n de teclado Braille
          save_base             ;salvamos registros...
          CMP     CS:f_lecto,1  ;est† la lectura autom†tica ?
          JNE     sigue_kbd
          MOV     CS:f_lecto,0  ;si estaba la lectura de texto activa, la
          CALL    clr_buff      ;desactivamos y vaciamos el buffer.
          hb      m_lecto_fin
          JMP     invalido
sigue_kbd:MOV     BL,AL
          CALL    trans
          CMP     AX,0
          JE      salimos
          CMP     CS:f_p,1
          JE      hot?            ;se ha pulsado prefijo de hotkey.
          TEST    BL,64           ;se puls¢ COR?
          JZ      no_hot          ;no se puls¢ COR.
          SUB     BL,64           ;mirar tipo de comando.
          MOV     BH,0
          MOV     CL,CS:t_tipo[BX]
          CMP     CL,0
          JE      no_hot          ;comando con COR pero que no es hotkey.
          CMP     CL,1            ;es una hotkey ?
          JE      hot?
          JMP     bh_comand       ;no, es un comando de B.H.
hot?:     MOV     CS:f_p,0        ;si es una hotkey.
          CALL    hot
          CMP     CS:f_hard_ok,1  ;fuÇ una hotkey correcta ?
          JE      hot_ok
          hb      m_hot_err
hot_ok:   JMP     si_habia
salimos:  JMP     invalido
                                  ;gesti¢n de caracteres normales.
no_hot:   CMP     CS:f_ctrl,1     ;car†cter de control?
          JNE     alte?
          CMP     AH,83           ;scan_code v†lida ?
          JA      ctrl_no
          MOV     BH,0
          MOV     BL,AH
          MOV     AH,CS:t_ctrl_h[BX]
          MOV     AL,CS:t_ctrl_l[BX]
ctrl_no:  JMP     bh_fin
alte?:    CMP     CS:f_alte,1     ;car†cter de con ALT ?
          JNE     ascii?
          CMP     AH,83           ;scan_code v†lida ?
          JA      ctrl_no
          MOV     BH,0
          MOV     BL,AH
          MOV     AH,CS:t_alte_h[BX]
          MOV     AL,CS:t_alte_l[BX]
alte_no:  JMP     bh_fin
ascii?:   CMP     CS:f_ascii,0    ;codigo ASCII ?
          JE      espe?
          CMP     AH,01           ;es escape?
          JE      asc_ok
          PUSH    AX
          CALL    manda
          hb_c    espacio
          POP     AX
          CMP     AL,48
          JB      asc_err
          SUB     AL,48
          CMP     AL,9
          JA      asc_err
          CMP     CS:f_ascii,1
          JNE     no_prime
          MOV     CS:n_ascii,0
no_prime: MOV     BL,AL
          MOV     AL,CS:n_ascii
          MOV     BH,10
          MUL     BH
          ADD     AL,BL
          MOV     CS:n_ascii,AL
          CMP     CS:f_ascii,3    ;es ya el tercer d°gito ?
          JE      asc_ok
          INC     CS:f_ascii
          JMP     invalido
asc_ok:   MOV     AL,CS:n_ascii
          hb      m_ok
          JMP     bh_fin
asc_err:  hb      m_error1
          JMP     si_habia
espe?:    CMP     CS:f_espe,0     ;car†cter especial?
          JE      maytmp?
          PUSH    CS
          POP     ES
          CLD
          LEA     DI,t_espe
          MOV     CX,long_espe
          REPNE   SCASB
          JNE     maytmp?
          MOV     AL,long_espe
          MUL     CS:f_espe
          ADD     DI,AX
          DEC     DI
          MOV     AL,BYTE PTR ES:[DI]
maytmp?:  CMP     CS:f_maytmp,1   ;pasar a may£s.?
          JE      mayproc
          CMP     CS:f_mayfix,1
          JE      mayproc
          JMP     bh_fin
mayproc:  CMP     AL,"§"
          JE      enne_m
          CMP     AL,"a"
          JB      no_minus
          CMP     AL,"z"
          JA      no_minus
          SUB     AL,32
          JMP     bh_fin
enne_m:   MOV     AL,"•"
          JMP     bh_fin
no_minus: CMP     AH,3BH          ;es tecla de funci¢n ? (codigo de F1)
          JB      bh_fin
          CMP     AH,44H          ;                      (codigo de F10)
          JA      bh_fin
          ADD     AH,25
bh_fin:   CALL    entrada         ;es un car†cter normal.
          JMP     si_habia

bh_comand:CMP     AL,"g"          ;es un comando del Braille Hablado.
          JNE     b_may?
          MOV     CS:f_p,1
          hb      m_hotkey
          JMP     si_habia
b_may?:   CMP     AL,"u"          ;comando may£scula ?
          JNE     b_mayoff?
          CMP     CS:f_maytmp,1
          JE      mayfix
          MOV     CS:f_maytmp,1
          hb      m_maytmp
          JMP     invalido
mayfix:   MOV     CS:f_mayfix,1
          MOV     CS:f_maytmp,0
          hb      m_mayfix
          hb      m_on
          JMP     si_habia
b_mayoff?:CMP     AL,"q"          ;comando desactivar may£scula ?
          JNE     b_espe?
          MOV     CS:f_mayfix,0
          MOV     CS:f_maytmp,0
          hb      m_mayfix
          hb      m_off
          JMP     si_habia
b_espe?:  MOV     CS:f_espe,1
          CMP     AL,"*"          ;comando de car†cter especial ? acentuadas ?
          JE      si_espec
          INC     CS:f_espe
          CMP     AL,"?"
          JE      si_espec
          INC     CS:f_espe
          CMP     AL,"+"
          JE      si_espec
          INC     CS:f_espe
          CMP     AL,"="
          JNE     no_espec
si_espec: hb      m_espe
          JMP     invalido
no_espec: MOV     CS:f_espe,0
b_ctrl?:  CMP     AL,"x"          ;comando de car†cter de control ?
          JNE     b_alte?
          MOV     CS:f_ctrl,1
          hb      m_ctrl
          JMP     invalido
b_alte?:  CMP     AL,"}"          ;comando de car†cter con ALT ?
          JNE     b_ascii?
          MOV     CS:f_alte,1
          hb      m_alte
          JMP     invalido
b_ascii?: CMP     AL,"k"          ;comando de introduci¢n de nß ASCII ?
          JNE     b_rev?
          MOV     CS:f_ascii,1
          hb      m_p_ascii
          JMP     invalido
b_rev?:   CMP     AL,"r"          ;entrar en revisi¢n ?
          JNE     si_habia
          MOV     CS:f_k_rev,1
si_habia: MOV     CS:f_maytmp,0
          MOV     CS:f_espe,0
          MOV     CS:f_ctrl,0
          MOV     CS:f_alte,0
          MOV     CS:f_ascii,0
invalido: rest_base
          RET
bra_kbd   ENDP
;----------------------------------------------------------------------------
trans     PROC
; Esta rutina convierte AL (recibido por RS232) a AX como c¢digo de tecla.
          PUSH    BX
          MOV     BH,0
          MOV     BL,AL
          MOV     AH,CS:t_scan[BX]
          MOV     AL,CS:t_ascii[BX]
          POP     BX
          RET
trans     ENDP
;----------------------------------------------------------------------------
