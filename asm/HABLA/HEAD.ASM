; Constantes, macros y variables comunes a todo los programas.
; Tambi‚n incluye la rutina de captura de v¡deo sub_video.

; CONSTANTES ----------------------------------------------------------------
BS        EQU       1
CIBER     EQU       2
AUDIO     EQU       3
PCH       EQU       4
ENPCH     EQU       5
MAX_LINES EQU       26      ;n£mero m ximo de l¡neas por pantalla.
clock     EQU       08H     ;Interrupci¢n hardware reloj
hard      EQU       09H     ;     "       hardware teclado
serie2    EQU       0BH     ;Interrupci¢n hardware puerto COM2
serie     EQU       0CH     ;Interrupci¢n hardware puerto COM1
video     EQU       10H     ;     "       BIOS de video
teclado   EQU       16H     ;     "       BIOS teclado
system    EQU       28H     ;     "       BIOS sistema (reservada)
nue_clock EQU       0F1H    ;nueva interrupci¢n hardware de reloj
nue_hard  EQU       0F2H    ;  "         "      hardware de teclado
nue_video EQU       0F3H    ;  "         "      de video
nue_tecla EQU       0F4H    ;  "         "      de teclado
nue_sys   EQU       0F5H    ;  "         "      de sistema
tec_hab   EQU       0F6H    ;intet. teclado de habla = teclado (16H).
nue_serie EQU       0F7H    ;Nueva interrupci¢n hardware  COM1 ¢ COM2
nue_servi EQU       0FAH    ;servico de interrupci¢n para otras aplicaciones.
act       EQU       1       ;activo
no_act    EQU       0       ;desactivado
para_min  EQU       'd'     ;par metro para descargar programa min£scula
para_may  EQU       'D'     ;   "       "      "         "     may£scula
espacio   EQU       ' '
rc        EQU       0DH     ;retorno de carro
retroceso EQU       08      ;backspace
k_m_tecla EQU       02H     ; c¢digo 1 - modo comunicaci¢n teclado
k_m_video EQU       03H     ;   "    2 -  "        "       video
k_m_may   EQU       04H     ;   "    3 -  "   indicaci¢n de may£sculas.
k_s_s     EQU       05H     ;   "    4 - hablar/silenciar espacios.
k_s_l     EQU       06H     ;   "    5 - hablar/silenciar l¡neas en blanco.
k_m_rev   EQU       07H     ;   "    6 - modo revisi¢n de l¡neas.
k_scr     EQU       08H     ;   "    7 - Pantalla actual.
k_live    EQU       09H     ;   "    8 - Activar/descativar l¡neas vivas.
k_soft    EQU       0AH     ;   "    9 - Seguimiento de softcursor.
k_kbd     EQU       0BH     ;   "    0 - Activar/desactivar teclado externo.
k_graf    EQU       0CH     ;   "    ' - Activar/desactivar verbaliz. gr ficos
k_auto    EQU       0DH     ;   "    ­ - B£squeda de softcursor.
k_str     EQU       25H     ;   "    K - habla l¡nea
k_word    EQU       20H     ;   "    D -   "   palabra
k_char    EQU       2EH     ;   "    C -   "   car cter
k_pos     EQU       19H     ;   "    P -   "   fila columna actual
k_lecto   EQU       14H     ;   "    T - Lectura de texto.
k_izqd    EQU       4BH     ;   "    flecha izquierda
k_drch    EQU       4DH     ;   "    flecha derecha
k_arrb    EQU       48H     ;   "    flecha arriba
k_abjo    EQU       50H     ;   "    flecha abajo
k_c_izqd  EQU       73H     ;   "    control flecha izquierda
k_c_drch  EQU       74H     ;   "    control flecha derecha
k_rev     EQU       13H     ;   "    R - revisi¢n de pantalla
k_rev2    EQU       53H     ;   "    SUP revisi¢n de pantalla(suicida)
k_end     EQU       01H     ;   "    escape. (salir de revisi¢n)
k_end2    EQU       1CH     ;   "    Intro . (salir de revisi¢n)
k_quiet   EQU       39H     ;   "    espaciador. Callar mensaje
k_habla   EQU       23H     ;   "    H - Hablar o callar.
k_pp      EQU       14H     ;   "    T - Principio de pantalla
k_fp      EQU       30H     ;   "    B - Final de pantalla
k_pc      EQU       49H     ;   "    PgUp - Principio de columna
k_fc      EQU       51H     ;   "    PgDn - Final de columna
k_pl      EQU       47H     ;   "    Home - Principio de l¡nea
k_fl      EQU       4FH     ;   "    End  - Final de l¡nea
k_wait    EQU       24H     ;   "    J - Callar y esperar
k_c_i     EQU       2DH     ;   "    X - car cter izquierda
k_c_a     EQU       2EH     ;   "    C - car cter actual
k_c_d     EQU       2FH     ;   "    V - car cter derecha
k_case    EQU       1EH     ;   "    A - may£scula/min£scula
k_p_i     EQU       1FH     ;   "    S - palabra izquierda
k_p_a     EQU       20H     ;   "    D - palabra actual
k_p_d     EQU       21H     ;   "    F - palabra derecha
k_fra     EQU       21H     ;   "    F - frase actual, con hotkey
k_fraa    EQU       12H     ;   "   ^R - frase anterior , con CONTROL revisi¢n
k_frac    EQU       06H     ;   "   ^F - frase actual   , con CONTROL    "
k_fras    EQU       16H     ;   "   ^V - frase siguiente, con CONTROL    "
k_l_a     EQU       17H     ;   "    I - l¡nea anterior
k_l_c     EQU       25H     ;   "    K - l¡nea actual
k_l_s     EQU       33H     ;   "    , - l¡nea siguiente
k_lpp     EQU       15H     ;   "    Y - leer pantalla desde el principio
k_lpf     EQU       31H     ;   "    N - leer pantalla hasta el final
k_llp     EQU       16H     ;   "    U - lee linea desde principio hasta cursor
k_llf     EQU       18H     ;   "    O - leer linea desde cursor hasta final
k_ivolu   EQU       3BH     ;   "  F1       - Incrementar volumen.
k_ivelo   EQU       3CH     ;   "  F2       - Incrementar velocidad.
k_itono   EQU       3DH     ;   "  F3       - Incrementar tono.
k_dvolu   EQU       54H     ;   "  MAYS F1  - Decrementar volumen.
k_dvelo   EQU       55H     ;   "  MAYS F2  - Decrementar velocidad.
k_dtono   EQU       56H     ;   "  MAYS F3  - Decrementar tono.
k_p_soft  EQU       3EH     ;   "  F4  - Posici¢n de comienzo de seguimiento.
k_d_soft  EQU       3FH     ;   "  F5  - Definir softcursor.
k_c_file  EQU       40H     ;   "  F6  - Decir nombre fichero configuraci¢n.
k_t_count EQU       41H     ;   "  F7  - Definir tiempo de espera.
k_d_state EQU       42H     ;   "  F8  - Definir l¡nea de estado.
k_hot     EQU       43H     ;   "  F9  - selecci¢n de hotkey.
k_asl     EQU       44H     ;   "  F10 - activar/silenciar lineas
k_pcl     EQU       64H     ;   " ^F7  - activar/desactivar pitido cambio l¡n.
k_d_np    EQU       65H     ;   " ^F8  - definir nombre de pantalla.
k_r_cfg   EQU       66H     ;   " ^F9  - recuperar configuraci¢n
k_g_cfg   EQU       67H     ;   " ^F10 - grabar    configuraci¢n
k_d_mark  EQU       10H     ;   "    Q - Definir marca.
k_mark    EQU       2CH     ;   "    Z - Ir a marca.
k_color   EQU       22H     ;   "    G - Verbalizar color.
k_ascii   EQU       34H     ;   "    . - Verbalizar ASCII caracter actual.
k_line    EQU       1CH     ;   "  ENTER - Preguntar linea a verbalizar.
k_state   EQU       26H     ;   "    L - Verbalizar l¡nea de estado.
k_cob     EQU       11H     ;   "    W - Columna anterior.
k_coc     EQU       12H     ;   "    E - Columna actual.
k_con     EQU       13H     ;   "    R - Columna siguiente.
k_cos     EQU       24H     ;   "    J - Columna superior.
k_coi     EQU       32H     ;   "    M - Columna inferior.
k_help    EQU       23H     ;   "    H - Ayuda
k_area    EQU       1EH     ;   "    A - Verbalizar area preguntada.
k_lista   EQU       2EH     ;   "    C - Verbalizar lista (columna) preguntada.
k_vc      EQU       35H     ;   "    - - Verbalizar pantalla con un color.
k_d_vc    EQU       "+"     ; Definir colores que se verbalizan.
k_d_live  EQU       '"'     ; Definir l¡nea viva.
k_uc      EQU       ";"     ; Unir cursores.
k_ac      EQU       ":"     ; Llevar el anunciador a la posicion del cursor.
k_p_area  EQU       "%"     ; Define principio de area.
k_f_area  EQU       "&"     ; Define final de area.
k_find    EQU       "/"     ; ASCII  / - B£squeda
k_d_l1    EQU       "("     ; Define principio de columna
k_d_l2    EQU       ")"     ; Define final de columna
k_del_l   EQU       "="     ; Borrar columnas.
k_invalid EQU       0EH     ; Retroceso. No hacer caso a la pr¢xima pulsaci¢n.
k_wind    EQU       27H     ; ¥. Ventana actual.
k_soft2   EQU       1FH     ; S. Cambiar seguimiento desactivado/inteligente.
k_att     EQU       10H     ; Q. Pantalla por atributos.
k_cc      EQU       33H     ; ,. Hablar lo que tiene el fondo del cursor.
k_d_form  EQU       6BH     ; ALT F4. Definir tecla de formulario.
k_msg     EQU       6CH     ; ALT F5. Definir mensaje (en revisi¢n).
k_vivos   EQU       6DH     ; ALT F6. Definir car cteres vivos.
k_lines   EQU       6EH     ; ALT F7. Definir n§ l¡neas de pantalla.
k_d_stat2 EQU       6FH     ; ALT F8. Definir 2¦ l¡nea estado (en revisi¢n).
k_g_cfg2  EQU       71H     ; ALT F10. Grabar configurac¡on en fichero actual.
k_v_msg   EQU       32H     ; M. Verbalizar mensaje? (al definir l¡nea viva).
k_stat2   EQU       32H     ; c¢digo M. Vervaliza 2¦ l¡nea estado (comunic).
pant_co   EQU       0B800H  ; Direcci¢n de memoria de pantalla color
pant_bn   EQU       0B000H  ; Direcci¢n de memoria de pantalla blanco/negro
pic_ctl   EQU       20H     ; Puerto del controlador de interrupciones
tec1      EQU       60H     ; Puerto del teclado
tec2      EQU       61H
hot_alt   EQU       00001000B ; ALT pulsado.
hot_ctrl  EQU       00000100B ; CTRL pulsado.
hot_c_a   EQU       00001100B ; CTRL-ALT pulsado.
nl        EQU       10      ; line feed
cr        EQU       13      ; cr
multiplo  EQU       10      ; n£mero de veces por t_count que espera.
standard  EQU       11100011B ; configuraci¢n 9600,n,8,1
c_clock   EQU       7       ; ciclos de reloj antes de comprobar l¡neas vivas.
intentos  EQU       7       ; n§ de intentos en uni¢n de cursores.
live_wide EQU       80      ; longitud m xima de las l¡neas vivas.
c_pausa   EQU       4       ; ciclos de espera en la lectura autom tica.
LONG_MSG  EQU       32      ;longitud de los mensajes definidos por ususario.
;----------------------------------------------------------------------------
save_base MACRO   ;Salva los registros b sicos.
          PUSH    AX
          PUSH    BX
          PUSH    CX
          PUSH    DX
          PUSH    DI
          PUSH    ES
ENDM
;----------------------------------------------------------------------------
rest_base MACRO   ;Restaura los registros b sicos.
          POP     ES
          POP     DI
          POP     DX
          POP     CX
          POP     BX
          POP     AX
ENDM
;----------------------------------------------------------------------------
save      MACRO   ;Salva todos los registros.
          save_base
          PUSH    DS
          PUSH    BP
          PUSH    SI
ENDM
;----------------------------------------------------------------------------
restore   MACRO   ;Restaura todos los registros.
          POP     SI
          POP     BP
          POP     DS
          rest_base
ENDM
;----------------------------------------------------------------------------
; Macro para guardar estado del procesador
guarda    MACRO
          LOCAL   in_rev
          PUSHF
          CMP     CS:f_pila,0
          JNE     in_rev
          POPF
          CLI                          ; no permitimos interrupciones mientras
          MOV     CS:seg_pil_ant,SS    ; cambiamos la pila.
          MOV     CS:pun_pil_ant,SP
          MOV     SS,CS:seg_pil_nue
          MOV     SP,CS:pun_pil_nue
          STI
          PUSHF
in_rev:   INC     CS:f_pila
          save
ENDM
;----------------------------------------------------------------------------
; Macro para recuperar estado del procesador
recupera  MACRO
          LOCAL   in_rev,out_recu
          restore
          DEC     cs:f_pila
          JNZ     in_rev
          POPF
          CLI
          MOV     SS,CS:seg_pil_ant
          MOV     SP,CS:pun_pil_ant
          STI                           ; permitimos de nuevo las interrp.
          JMP     out_recu
in_rev:   POPF
out_recu:
ENDM
;----------------------------------------------------------------------------
hb        MACRO cadena
          LEA     DI,cadena
          CALL    manda_str
ENDM
;----------------------------------------------------------------------------
hb_c      MACRO caracter
          MOV     AL,caracter
          CALL    manda
ENDM
;----------------------------------------------------------------------------
; Tabla de vectores de interrupci¢n
interrup  SEGMENT AT 0H
          ORG     clock*4
d_clock   LABEL   DWORD
          ORG     hard*4
d_hard    LABEL   DWORD
          ORG     serie2*4
d_serie2  LABEL   DWORD
          ORG     serie*4
d_serie   LABEL   DWORD
          ORG     video*4
d_video   LABEL   DWORD
          ORG     teclado*4
d_tecla   LABEL   DWORD
          ORG     system*4
d_sys     LABEL   DWORD
          ORG     nue_clock*4
ant_clock LABEL   DWORD
          ORG     nue_hard*4
ant_hard  LABEL   DWORD
          ORG     nue_video*4
ant_video LABEL   DWORD
          ORG     nue_tecla*4
ant_tecla LABEL   DWORD
          ORG     nue_sys*4
ant_sys   LABEL   DWORD
          ORG     tec_hab*4
d_tec_hab LABEL   DWORD
          ORG     nue_serie*4
ant_serie LABEL   DWORD
          ORG     nue_servi*4
d_servi   LABEL   DWORD
interrup  ENDS
;----------------------------------------------------------------------------
; Segmento para localizaci¢n de la varible de estado del teclado (kb_flag)
keys      SEGMENT AT 40H
          ORG     17H
kb_flag   LABEL   DWORD
          ORG     1AH
head      LABEL   DWORD
          ORG     1CH
tail      LABEL   DWORD
          ORG     1EH
first_w   LABEL   DWORD
          ORG     3CH
last_w    LABEL   DWORD
          ORG     96H
kb_flag2  LABEL   DWORD
keys      ENDS
;----------------------------------------------------------------------------
; Comienzo del programa residente. M ximo 64K.
reside    SEGMENT
          ASSUME CS:reside,DS:reside
          ORG 100H            ;programa .COM
inicio:   JMP     instala     ;ve a instalar programa


; variables del programa residente
flag              DB     ?    ;indica si est  activa la rutina residente
f_del             DB     0    ;indica si se puls¢ la tecla de borrado
f_sup             DB     0    ;indica si se puls¢ la tecla de suprimir
f_pantalla        DW     1    ;( 1 - de memoria, 2 - de pantalla, 3 - externo )
f_rev             DB     0    ;indica si est  en modo revisi¢n
f_k_rev           DB     0    ;indica si se pulso la tecla de modo revisi¢n
f_habla           DB     1    ;( 1 - hablando, 0 - callado )
f_wait            DB     0    ;indica si est  callado esperando
f_caracter        DB     0 ;indica que est  pendiente verbalizar el caracter
f_palabra         DB     0 ;  "     "    "      "         "      la palabra
f_linea           DB     0 ;  "     "    "      "         "      la l¡nea
f_lista           DB     0 ;  "     "    "      "         "      la lista(col)
f_fonetica        DB     0    ;indica si se har  pronunciaci¢n fon‚tica.
f_deletreo        DB     0    ;indica si se har  deletreo.
f_main            DB     0    ;indica si se hablar  color predominante.
f_bloq_mays       DB     00100000B   ;teclas de bloqueo (suponemos bloq.num).
f_pos_c           DB     0    ;indica si queremos ver la posici¢n del cursor.
f_all_spc         DB     ?    ;supone todo en blanco.
f_spc_del         DB     0    ;indica que viene un espacio para borrar.
f_uc              DB     0    ;unir cursores activado (a 1).
f_intenta         DB     0    ;n§ de intentos en union de cursores.
f_no_hard         DB     0    ; a 1 indica que no capturare nada en sub_hard.
f_pdte_video      DB     0    ;est  pdte. hablar buffer de video.
f_copy            DB     0    ;a 1 indica que se acaba de definir l¡nea viva.
f_hard_ok         DB     0    ;indica si se ejecut¢ alguna hardkey.
f_auto            DB     0    ;indica si se ha activado la b£squeda de softcur.
f_num             DB     0    ;indica si la palabra a verbalizar es un n£mero.
f_lecto           DB     0    ;lectura de texto autom tica.
f_conf            DB     0 ;indica si se quiere cargar/grabar configuraci¢n.
f_cargado         DB     0 ;indica si ya estaba en memoria.
f_invalid         DB     0 ;no hacer caso a la pr¢xima pulsaci¢n como hotkey.
f_pila            DB     0 ;indica si hemos hecho ya el cambio de pila.
f_in_key          DB     0 ;indica si se esta pidiendo informaci¢n por teclado
f_chg9            DB     0 ;indica si se ha cambiado el vector 9H.
f_clock           DB     0 ;indica que se ha pasado por la int. del reloj.
f_moved           DB     0 ;indica que se movi¢ el cursor de Soft inteligente.
f_vivos           DW     10 DUP(0); tabla de flags de car.vivos. 1=car.pintado.
f_plc             DB     0 ;a 1 indica si esta pdte hablar de principio l¡nea
                           ; hasta el cursor. Cuando se activa lo del form.
p_file            DW     0 ;apunta a donde comienza el nombre de fichero.
dif               DB     ?
dif_ant           DB     ?
del_fila          DB     ?
del_colu          DB     ?
fila              DB     ?
colu              DB     ?
fila_ant          DB     ?    ;fila anterior
colu_ant          DB     ?    ;columna anterior
pos_ant           DW     0
col_ant           DB     ?    ;columna anterior
fil_ant           DB     ?    ;fila anterior
soft_fila         DB     ?    ;fila    softcursor inteligente.
soft_colu         DB     ?    ;columna softcursor inteligente.
borrado           DB     ?    ;el car cter borrado con del.
seg_pil_ant       DW     ?    ;direcciones de pilas
pun_pil_ant       DW     ?
seg_pil_nue       DW     ?    ;direcciones de pilas
pun_pil_nue       DW     ?
old_video         DD     ?    ;direcci¢n de antigua interrupci¢n video
old_hard          DD     ?    ;direcci¢n de antigua interrupci¢n hardware
old_ax            DW     ?
old_bx            DW     ?
old_cx            DW     ?
tecla_off         DW     ?    ;offset rutina gestion de INT 9H
tecla_seg         DW     ?    ;segemento "      "          "  .
indos             DD     ?    ;direcci¢n de la variable INDOS
count             DW     ?    ;contador de iteraciones.
count_clock       DB     0    ;contador antes de comprobar l¡neas vivas.
count_clock2      DB     0    ;contador antes de comprobar softcursor inteli.
cuenta            DB     0    ;contador de ciclos para lectura autom tica.
param             DB     ?    ;indica par metro pasado a la rutina de teclado
param2            DB     ?    ;indica par metro pasado a la rutina de teclado
buf_tecla         DB     255 dup (' ')  ;buffer de teclado
fin_buf_tecla     LABEL   WORD          ;fin del buffer de teclado
n_tecla           DW     0    ;numero caracteres a verbalizar
buf_video         DB     255 dup (' ')  ;buffer de video
fin_buf_video     LABEL   WORD          ;fin del buffer de video
n_video           DW     0    ;numero caracteres a verbalizar
read_buff         DB     80*2 dup (' ') ;buffer de read_str.

;MENSAJES.......
m_v_on            DB     quiet,"modo v¡deo activado $"
m_v_off           DB     quiet,"modo v¡deo desactivado $"
m_k_palabra       DB     quiet,"modo teclado palabra $"
m_k_caracter      DB     quiet,"modo teclado car cter $"
m_k_off           DB     quiet,"modo teclado desactivado $"
m_revision        DB     quiet,'revisi¢n de pantalla ','$'
m_ya_rev          DB     quiet,'ya estamos en revisi¢n ','$'
m_fin_rev         DB     quiet,'fin de revisi¢n ','$'
m_pos_c           DB     quiet,'cursor ','$';mensaje posici¢n cursor.
m_pos_a           DB     quiet,'anunciador ','$';mensaje posici¢n anunciador.
m_fila            DB     2 dup (' ')
                  DB     ' '
m_colu            DB     2 dup (' ')
                  DB     ' $'
m_listo           DB     'listo ','$'
m_pp              DB     quiet,"principio pantalla $"
m_fp              DB     quiet,"final pantalla $"
m_pc              DB     quiet,"principio columna $"
m_fc              DB     quiet,"final columna $"
m_pl              DB     quiet,"principio $"
m_fl              DB     quiet,"final $"
m_pa              DB     quiet,"principio area $"
m_fa              DB     quiet,"final area $"
m_r_l             DB     quiet,'modo l¡nea ','$'
m_r_p             DB     quiet,'modo palabra ','$'
m_r_c             DB     quiet,'modo car cter ','$'
m_r_li            DB     quiet,'modo columna ','$'
m_r_w             DB     quiet,'modo ventana ','$'
m_r_s             DB     quiet,'modo silencioso ','$'
m_del_l           DB     quiet,"borrar todas las columnas    conf¡rmelo $"
m_del_l2          DB     quiet,"columnas borradas $"
m_may             DB     'may£scula ','$'
m_min             DB     'min£scula ','$'
m_line_act        DB     quiet,'l¡nea activada ','$'
m_line_des        DB     quiet,'l¡nea desactivada ','$'
m_m_may           DB     quiet,'indicaci¢n de may£sculas ','$'
m_s_s             DB     quiet,'indicaci¢n de espacios en blanco ','$'
m_s_l             DB     quiet,'indicaci¢n de l¡neas en blanco ','$'
m_act             DB     'activada ','$'
m_des             DB     'desactivada ','$'
m_mark            DB     quiet,"marca realizada $"
m_mark_err        DB     quiet,"marca no definida $"
m_color1          DB     quiet,'el color es ','$'
m_color2          DB     ' sobre ','$'
m_parpa           DB     'parpadeante ','$'
m_ascii           DB     quiet,'el c¢digo ASCII es '
m_asc             DB     3 dup (?),' $'
m_hot_alt         DB     quiet,'tecla jotkey alternativa ','$'
m_hot_ctrl        DB     quiet,'tecla jotkey control ','$'
m_hot_c_a         DB     quiet,'tecla jotkey control alternativa ','$'
m_fin_l           DB     quiet,'fin l¡nea ','$'
m_pri_l           DB     quiet,'principio l¡nea ','$'
m_nada            DB     'en blanco ','$'
m_error1          DB     'n£mero incorrecto ','$'
m_prompt          DB     quiet,"lectura $"
m_state           DB     quiet,"l¡nea de estado definida $"
m_t_count         DB     quiet,"tiempo de espera $"
m_uc              DB     quiet,"cursores unidos $"
m_uc_err          DB     quiet,"no se unieron cursores $"
m_c_file          DB     quiet,"el fichero de configuraci¢n es $"
m_p_area          DB     quiet,"principio de area $"
m_f_area          DB     quiet,"final de area $"
m_d_area          DB     " definido $"
m_area_err        DB     quiet,"area no definida $"
m_find            DB     quiet,'b£squeda $'
m_no_find         DB     'no lo encuentro $'
m_help            DB     quiet,"modo de ayuda pulse intro para salir $"
m_help_err        DB     "no definida $"
m_help_end        DB     quiet,"fin de ayuda $"
m_scr             DB     quiet,"pantalla $"
m_l_err1          DB     quiet,"columna mal definida $"
m_l_err2          DB     quiet,"no estamos en una columna $"
m_l_err3          DB     quiet,"no hay columnas definidas $"
m_l_err4          DB     quiet,"columna no definida $"
m_live_0          DB     quiet,"l¡neas vivas desactivadas $"
m_live_1          DB     quiet,"l¡neas vivas indicadas con pitido $"
m_live_2          DB     quiet,"l¡neas vivas sin pitido $"
m_live_3          DB     "y cancelaci¢n del mensaje anterior $"
m_d_live          DB     quiet,"introduzca n£mero de caracteres $"
m_live_off        DB     quiet,"l¡nea viva desactivada $"
m_live_ok         DB     "l¡nea viva definida $"
m_live_t          DB     quiet,"verbalizar l¡nea  rea o mensaje $"
m_live_l          DB     quiet,"verbaliza l¡nea $"
m_live_a          DB     quiet,"verbaliza  rea $"
m_live_m          DB     quiet,"verbaliza mensaje $"
m_soft            DB     quiet,"cursor de seguimiento definido $"
m_soft_err        DB     quiet,"cursor no encontrado $"
m_soft_pre        DB     quiet,"seguimiento $"
m_soft0           DB     "desactivado $"
m_soft1           DB     "por atributo $"
m_soft2           DB     "por car cter $"
m_soft3           DB     "por atributo y car cter $"
m_soft4           DB     "resaltado $"
m_soft5           DB     "inteligente $"
m_p_soft          DB     quiet,"introduzca  rea de seguimiento $"
m_ok              DB     quiet,"correcto $"
m_main            DB     quiet,"el color predominante es $"
m_on              DB     "activado $"
m_off             DB     "desactivado $"
m_auto            DB     quiet,"b£squeda de cursor de seguimiento, "
                  DB     "pulse una tecla $"
m_auto_err        DB     quiet,"imposible encontrar cursor de seguimiento $"
m_auto_ok         DB     quiet,"cursor de seguimiento encontrado $"
m_graf            DB     quiet,"lectura de gr ficos $"
m_columna         DB     quiet,"columna $"
m_vc              DB     quiet,"color $"
m_d_vc            DB     quiet,"definir color n£mero $"
m_fondo           DB     quiet,"color de fondo $"
m_tinta           DB     quiet,"color de car cter $"
m_todos           DB     "todos $"
m_si              DB     "si $"
m_no              DB     "no $"
m_d_vc_fin        DB     quiet,"colores definidos $"
m_lecto           DB     quiet, "lectura de texto $"
m_lecto_fin       DB     "fin de lectura $"
m_r_cfg           DB     quiet, "recuperar configuraci¢n $"
m_g_cfg           DB     quiet, "grabar configuraci¢n $"
m_error_file      DB     "Error en operaci¢n con fichero de configuraci¢n $"
m_recu            DB     "Configuraci¢n recuperada $"
m_grab            DB     "Configuraci¢n grabada $"
m_speak_on        DB     quiet,"Habla activado $"
m_speak_off       DB     quiet,"Habla desactivado $"
m_nombre          DB     "Introduzca nombre $"
m_pcl             DB     quiet,"Pitido cambio de l¡nea $"
m_msg             DB     quiet,"Definir mensaje n£mero $"
m_stat2           DB     quiet,"Segunda l¡nea de estado definida $"
m_vivos           DB     quiet,"Definir car cter vivo n£mero $"
m_vivos_off       DB     "Car cter vivo desactivado $"
m_vivos_ok        DB     "Car cter vivo definido $"
m_lines           DB     quiet,"   l¡neas en pantalla $"
m_d_form          DB     quiet,"Tecla de formulario $"
m_form_n          DB     "ninguna $"
m_form_i          DB     "intro $"
m_form_t          DB     "tabulador $"
m_form_it         DB     "intro y tabulador $"
;MENSAJES DE AYUDA ....
t_ayuda           DB     "Unir cursores                                 " ;1
long_ayuda        EQU    $-t_ayuda
                  DB     "Definir principio de area                     " ;2
                  DB     "Definir final de area                         " ;3
                  DB     "B£squeda                                      " ;4
                  DB     "Definir principio de columna                  " ;5
                  DB     "Definir final de columna                      " ;6
                  DB     "Borrar las columnas de la pantalla actual     " ;7
                  DB     "Llevar anunciador a la posicion del cursor    " ;8
                  DB     "Definir l¡nea viva                            " ;9
                  DB     "Definir colores a verbalizar en pantalla      " ;10
; aqui comienzan las de scan code (con AH)
                  DB     "cambiar modo comunicaci¢n teclado con jotkey  " ;1
                  DB     "cambiar modo comunicaci¢n video con jotkey    " ;2
                  DB     "cambiar indicaci¢n de may£sculas con jotkey   " ;3
                  DB     "cambiar indicaci¢n de espacios con jotkey     " ;4
                  DB     "hablar o silenciar l¡neas en blanco con jotkey" ;5
                  DB     "cambiar modo de revisi¢n de l¡neas con jotkey " ;6
                  DB     "hablar posici¢n del cursor o anunciador       " ;7
                  DB     "salir de revisi¢n                             " ;8
                  DB     "callar mensaje actual con jotkey              " ;9
                  DB     "activar o desactivar el habla con jotkey      " ;10
                  DB     "ir a principio de pantalla o de area          " ;11
                  DB     "ir a final de pantalla o de area              " ;12
                  DB     "ir a principio de l¡nea                       " ;13
                  DB     "ir a final de l¡nea                           " ;14
                  DB     "Columna superior                              " ;15
                  DB     "car cter izquierda                            " ;16
                  DB     "car cter actual                               " ;17
                  DB     "car cter derecha o frase siguiente con control" ;18
                  DB     "indicar may£scula o min£scula                 " ;19
                  DB     "palabra izquierda                             " ;20
                  DB     "palabra actual                                " ;21
                  DB     "palabra derecha o frase actual con jotkey     " ;22
                  DB     "l¡nea anterior                                " ;23
                  DB     "l¡nea actual                                  " ;24
                  DB     "l¡nea siguiente o leer texto con fondo actual " ;25
                  DB     "leer desde principio de pantalla hasta cursor " ;26
                  DB     "leer desde cursor hasta final de pantalla     " ;27
                  DB     "leer desde principio de l¡nea hasta cursor    " ;28
                  DB     "leer desde cursor hasta final de l¡nea        " ;29
                  DB     "Decir nombre fichero configuraci¢n            " ;30
                  DB     "Definir tiempo de espera                      " ;31
                  DB     "Definir l¡nea de estado y secundaria conjotkey" ;32
                  DB     "seleccionar jotkey                            " ;33
                  DB     "activar o silenciar l¡neas                    " ;34
                  DB     "Definir marca o atributos depantallacon jotkey" ;35
                  DB     "Ir a marca                                    " ;36
                  DB     "Verbalizar colores                            " ;37
                  DB     "Verbalizar codigo ASCII del car cter actual   " ;38
                  DB     "Verbalizar l¡nea de estado                    " ;39
                  DB     "Definir pantalla actual de trabajo con jotkey " ;40
                  DB     "Columna anterior                              " ;41
                  DB     "Columna actual                                " ;42
                  DB     "Columna siguiente o frase anterior con control" ;43
                  DB     "Columna inferior                              " ;44
                  DB     "Activar o silenciar l¡neas vivas con jotkey   " ;45
                  DB     "Ir a principio de columna                     " ;46
                  DB     "Ir a final de columna                         " ;47
                  DB     "Definir cursor de seguimiento                 " ;48
                  DB     "Activar o desactivar seguimiento con jotkey   " ;49
                  DB     "Activar odesactivar teclado externo con jotkey" ;50
                  DB     "Definir  rea de seguimiento                   " ;51
                  DB     "B£squeda de cursor de seguimiento con jotkey  " ;52
                  DB     "Activarodesactivar lecturadegr ficoscon jotkey" ;53
                  DB     "Verbalizar pantalla de un color con jotkey    " ;54
                  DB     "Volumen m s alto o m s bajo con may£scula     " ;55
                  DB     "Velocidad m s r pida o m s lenta con may£scula" ;56
                  DB     "Tono m s agudo o m s grave con may£scula      " ;57
                  DB     "Verbalizar ventana actual                     " ;58
                  DB     "Recuperar configuraci¢n                       " ;59
                  DB     "Grabar configuraci¢n                          " ;60
                  DB     "Definir nombre de pantalla                    " ;61
                  DB     "Activar o desactivar pitido cambio de l¡nea   " ;62

ult_ascii         EQU    10; £ltima en la lista con codigo ascii
t_k_ayuda         DB     k_uc     , k_p_area , k_f_area , k_find   ,k_d_l1
                  DB     k_d_l2   , k_del_l  , k_ac     , k_d_live ,k_d_vc
; aqui comienzan las de scan code (con AH)
                  DB     k_m_tecla, k_m_video, k_m_may  , k_s_s    ,k_s_l
                  DB     k_m_rev  , k_pos    , k_end    , k_quiet  ,k_habla
                  DB     k_pp     , k_fp     , k_pl     , k_fl     ,k_cos
                  DB     k_c_i    , k_c_a    , k_c_d    , k_case   ,k_p_i
                  DB     k_p_a    , k_p_d    , k_l_a    , k_l_c    ,k_l_s
                  DB     k_lpp    , k_lpf    , k_llp    , k_llf    ,k_c_file
                  DB     k_t_count, k_d_state, k_hot    , k_asl    ,k_d_mark
                  DB     k_mark   , k_color  , k_ascii  , k_state  ,k_scr
                  DB     k_cob    , k_coc    , k_con    , k_coi    ,k_live
                  DB     k_pc     , k_fc     , k_d_soft , k_soft   ,k_kbd
                  DB     k_p_soft , k_auto   , k_graf   , k_vc     ,k_ivolu
                  DB     k_ivelo  , k_itono  , k_wind   , k_r_cfg  ,k_g_cfg
                  DB     k_d_np   , k_pcl
long_k_ayuda      EQU    $-t_k_ayuda
buffer            DB     0, 39 DUP(" ")  ;buffer de b£squeda en revisi¢n.
buffer_sz         EQU    $-buffer
old_lbuffer       DW     0               ;longitud de la cadena a buscar.
stack_bot         DB     512 dup(0)  ;pila de HABLA
stack_top         DW     ?
vocaliza          DB     "AEIOUaeiou ‚¡¢£0123456789yY"  ;vocales y n£meros
long_vocaliza     EQU    $-vocaliza
signos            DB     ".:;¨?¨!" ;signos separaci¢n de frases
long_signos       EQU    $-signos
pantalla          DW     pant_co  ; dir. pantalla (supone pantalla color).
pag_act           DB     ?
t_fonetica        DB     "America   Barcelona Cordoba   Dinamarca Europa    "
                  DB     "Francia   Granada   Hotel     Italia    Jap¢n     "
                  DB     "Kilo      Londres   Madrid    Navarra   Oviedo    "
                  DB     "Pamplona  Queso     Roma      Sevilla   Toledo    "
                  DB     "Union     Victoria  WashingtonXilofono  "
fo_griega         DB     "i griega $"
                  DB     "Zapato    "
fo_spc            DB     "espacio $"
fo_enne           DB     "e¤e $"
fo_aa             DB     "a acentuada $"
fo_ea             DB     "e acentuada $"
fo_ia             DB     "i acentuada $"
fo_oa             DB     "o acentuada $"
fo_ua             DB     "u acentuada $"
fo_ast            DB     "asterisco $"
fo_mq             DB     "mayorqu‚ $"
l_nume            DW     0 ;longitud del n£mero introducido en revisi¢n.
nume              DB     2 dup(0) ;buffer del n£mero introducido en revisi¢n.
t_color           DB     "Negro         Azul          Verde         "
                  DB     "Cyan          Rojo          Rosa          "
                  DB     "Marr¢n        Blanco        Gris          "
                  DB     "Azul claro    Verde claro   Cyan claro    "
                  DB     "Rojo claro    Rosa claro    Amarillo      "
                  DB     "Blanco intenso"
t_copy            DW     live_wide*MAX_LINES dup(?);buffer de copia l¡neas vivas.
t_f_att           DW     128 dup(0)   ;tabla frecuencias de atributos.
t_att             DB     128 dup(0)   ;tabla ordenada de atributos.
n_att             DB     0  ;n§ de atributos distintos en la pantalla.
c_att             DB     0  ;atributo actual
tinta             DB     ?
fondo             DB     ?
parpa             DB     ?
f_no_serie        DB     0 ;a uno indica que no se debe configurar la RS232.


; Variables que afectan a la CONFIGURACION...................................
; No deben cambiarse de posici¢n. Siempre deben ir delante de sub_video,
; ya que ‚sta se utilizar  luegos para saber d¢nde est n dichas varibles
; a trav‚s del vector de interrupci¢n. --------------------------------------
conf_area         LABEL BYTE
conf_name         DB     "\CONFI.HAB",0, 30 dup(" ")
  conf_name_sz    EQU    $-conf_name ;tama¤o del nombre de fichero.
sintetizador      DB     SINTE ;indica el sintetizador que es (1-5).
f_m_may           DB     0    ;indica si se indican las may£sculas.
f_s_s             DB     1    ;indica si queremos hablar espacios.
f_s_l             DB     1    ;indica si queremos hablar l¡neas en blanco.
f_kbd             DB     1    ;teclado externo activado (si lo hay).
hotkey            DB     hot_alt      ;ALT pulsado (kb_flag) por defecto.
f_graf            DB     0    ;activa verbalizaci¢n de gr ficos y controles.
f_fondo           DB     10 dup(255)  ;fondo a verbalizar (todos).
f_tinta           DB     10 dup(255)  ;tinta a verbalizar (todas).
f_parpa           DB     10 dup(255)  ;parpa a verbalizar (todos).
t_count           DB     1    ;iteraciones antes de verbalizar lo pendiente.
t_msg             DB     10*LONG_MSG dup(' '); tabla de 10 mensajes.
screen            DW     0  ;pantalla actual (por defecto la 0).
scr_size          DW     25*80*2 ; Tama¤o de pantalla. Defecto 25 l¡neas.
scr_chars         DW     25*80   ; Caracteres en pantalla.
num_lines         DB     25      ; N£mero de l¡neas de pantalla.
last_line         DB     24      ; Ultima l¡nea = num_lines - 1.

scr_area          LABEL BYTE  ;comienza el area de formatos de pantalla.------
 modo_tecla   DB     2    ; 0 - letra, 1 - palabra, 2 - desactivado.
 modo_video   DB     0    ; 0 - activado, 1 - desactivado.
 f_m_rev      DB     0    ;modo  de revisi¢n 0-l¡nea, 1-palabra,
                          ; 2-car cter, 3-lista, 4-columna.
 t_ls         DB     MAX_LINES dup(0)   ;tabla de l¡neas silenciadas.
 t_filas      DB     10 dup(255) ;tablas de filas y columnas para marcas.
 t_colus      DB     10 dup(255)
 area_f1      DB     10 dup(255) ;tablas de filas y columnas para areas.
 area_c1      DB     10 dup(255)
 area_f2      DB     10 dup(255) 
 area_c2      DB     10 dup(255)
 t_l1         DB     10 dup(255) ;tablas de listas (columnas).
 t_l2         DB     10 dup(255)
 t_state      DB     0           ;l¡nea de estado.
 t_stat2      DB     24          ;2¦ l¡nea de estado (defecto la 25).
 f_live       DB     0           ;indica si est n activas las l¡neas vivas.
 t_live       DW     MAX_LINES dup(0)   ;tabla de lineas vivas.
 t_l_l        DW     MAX_LINES dup(0)   ;tabla de longitudes a scanear.
 t_l_t        DW     MAX_LINES dup(255) ;tabla tipos a hablar( reas,l¡neas o msg)
 vivos_car    DW     10 dup(0FFFFH) ;tabla car cteres vivos.(car. y attr)
 vivos_pos    DW     10 dup(0)   ;posiciones de los car cteres.
 vivos_tip    DW     10 dup(255) ;tabla tipos a hablar( reas,l¡neas o msg)
 f_soft       DB     0    ;desactivado seguimiento de cursor ..
 ;0-desactivado, 1-atributo, 2-car ct., 3-atr. y car., 4-inteligente, 5-ambos
 soft_c       DB     ?    ;car cter a buscar en seguimiento. 
 soft_a       DB     ?    ;atributo a buscar en seguimiento.
 soft_area    DB     255  ;area de seguimiento.(255 = toda la pantalla)
 scr_name     DB     20 dup(' '),' $' ;nombre del formato de pantalla.
 f_pcl        DB     1    ;pitido cambio de l¡nea activado.
 scr_sz           EQU    $-scr_area ;-----------------------------------------
t_scr             DB     10*scr_sz dup(?) ;todos los formatos de pantalla.

;Par metros de voz (de todos los sintetizadores).
volu              DB     VOLU_DEF     ;volumen.
velo              DB     VELO_DEF     ;velocidad.
tono              DB     TONO_DEF     ;tono.
f_punt            DB     0            ;puntuaci¢n desactivada.
expr              DB     4            ;expresividad.
cib1              DB     0            ;par metros de cibervoz.
cib2              DB     0
cib3              DB     1
cib4              DB     0
cib5              DB     1
cib6              DB     1

f_form            DB     0           ;formulario 0-desactivado, 1-intro
                                     ; 2-tab, 3-intro y tab.
filler            DB     26 dup(0)   ;de relleno para futuros par metros.
                                     ; Total bytes 4350.
conf_sz           EQU    $-conf_area ;tama¤o de la zona de configuraci¢n.
;----------------------------------------------------------------------------
; Rutina que intercepta la llamada a las rutinas de video de la BIOS.
; la variable que viene a continuaci¢n no debe cambiarse de posici¢n
com               DB     0  ;indica puerto de comunicaciones (def. COM1)
sub_video PROC
          JMP     cabeza
DB     'Rutina de sintesis' ;mensaje que indentifica la rutina en memoria

cabeza:   CMP     CS:f_rev,1;si estamos en modo revisi¢n, no nos interesa
          JE      end_video ;capturar esta interrupci¢n.
          CMP     AH,09H ;averiguamos que servicios nos interesan
          JE      bien
          CMP     AH,0AH
          JE      bien
          CMP     AH,0EH
          JE      bien
          CMP     AH,02H
          JE      bien
          CMP     AH,06H
          JE      bien
          CMP     AH,07H
          JE      bien
          CMP     AH,08H       ;vemos si es leer el caracter del cursor
          JNE     end_video    ;para evitar lo de la repetici¢n de la l¡nea 25
          CMP     CS:fil_ant,24
          JNE     end_video      ;si estamos en la posici¢n 24,0, entonces
          CMP     CS:col_ant,00  ;no hacer caso al pr¢ximo caracter escrito.
          JNE     end_video
          MOV     CS:f_spc_del,1
          JMP     end_video    ;los dem s servicios no nos interesan
bien:     CMP     CS:flag,act  ;est  activa ?
          JNE     bien2
end_video:JMP     CS:old_video ;llamamos a la antigua interrupci¢n
bien2:    MOV     CS:flag,act  ;rutina activa
          guarda
          MOV     CS:f_pantalla,1 ;los datos enviado son del buffer de video
                                 ;Ahora detectamos si se ha cambiado de linea
          CMP     AH,02H         ;es posicionar cursor ?
          JNE     no_move
;***** Esto revisar si hay que quitarlo para Reflection.
          MOV     CS:count,255   ;si lo es ponemos el count al m ximo para
          JMP     situa          ;que se hable lo pendiente cuanto antes.
no_move:  CMP     AH,06H         ;desplazar hacia arriba ?
          JE      r_c
          CMP     AH,07H         ;desplazar hacia abajo ?
          JE      r_c
          CMP     AH,0EH         ;vemos si se pinta un nl en la 24,0 para..
          JNE     escritura      ;..no hablarlo y evitar la repetici¢n.
          CMP     AL,nl
          JNE     escritura
          CMP     CS:fil_ant,24
          JNE     escritura      ;si estamos en la posicion 24,0 entonces..
          CMP     CS:col_ant,00  ;..no hacer caso al pr¢ximo caracter escrito.
          JNE     escritura
          MOV     CS:f_spc_del,1
          JMP     fin
situa:    CMP     CS:f_soft,5    ;seguir softcursor y cursor (inteli) ?
          JNE     queva
          CALL    act_inteli
queva:    CMP     DH,CS:fil_ant  ;si,mira si cambio fila
          MOV     CS:fil_ant,DH
          JE      chg_col?
          CMP     CS:f_pcl,1     ;activado pitido cambio de l¡nea ?
          JNE     r_carro
          CMP     CS:f_caracter,1;si cambio la fila despues de pulsar las
          JE      si_pito        ;flechas, entonces pitamos.
          CMP     CS:f_palabra,1
          JNE     r_carro
si_pito:  CALL    m_beep2
          JMP     r_carro
chg_col?: MOV     AH,CS:col_ant  ;mira si cambio columna
          SUB     AH,DL
          CMP     DL,CS:col_ant
          MOV     CS:col_ant,DL
          JAE     salto
          CMP     AH,1
          JE      salto
r_carro:  MOV     CS:col_ant,DL  ;nos aseguramos de gurardar DH y DL
r_c:      CALL    h_b_video      ;ha habido cambio de linea, ->habla buffer
          MOV     CS:f_pdte_video,1
salto:    JMP     fin

escritura:MOV     BH,0           ;averiguamos si es una l¡nea silenciada....
          MOV     BL,CS:fil_ant
          CMP     CS:t_ls[BX],1
          JE      fine
          CMP     AL,retroceso  ;si es retroceso, pasamos de ‚l.
          JE      fine
          CMP     CS:f_spc_del,1
          MOV     CS:f_spc_del,0
          JE      fine
          CMP     CS:modo_video,1 ;modo video desactivado (eco off) ?
          JE      fine
          CMP     AL,nl         ;si es cambio de l¡nea, pasamos de ‚l.
          JE      fine
          CMP     AL,cr         ;si es retorno de carro, habla buffer.
          JE      r_c
                                ;no hay cambio de l¡nea, caracter normal
          MOV     DI,OFFSET buf_video
          ADD     DI,CS:n_video
          MOV     CS:[DI],AL    ;caracter normal, lo guardamos
          INC     CS:n_video    ;incrementa n§ caracteres pdtes. de hablar
          INC     DI
          CMP     DI,OFFSET fin_buf_video ;buffer lleno ?
          JE      r_c                     ;si, h blalo
          CMP     AL,espacio              ;es un espacio ?
          JNE     fine                    ;no, salte
          CMP     CS:f_in_key,0
          JZ      fine
          CALL    h_b_video               ;si, hablar palabra
fine:     MOV     CS:f_in_key,0
fin:      recupera                        ;recuperar estado
          MOV     CS:flag,no_act          ;no activa
          JMP     CS:old_video            ;vete a la antigua rutina de video
sub_video ENDP
;----------------------------------------------------------------------------
