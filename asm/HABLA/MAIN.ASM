; Rutinas comunes a todos las versiones del programa principal.
; Esta parte no permanece residente.

; variables no residentes.
cargado           DB      "El programa ya estaba en memoria $"
despedida         DB      "HABLA descargado Adios $"
no_cargado        DB      "HABLA no cargado !",nl,cr,"$"
f_descarga        DB      0 ;indica si se quiere descargar el programa.

;----------------------------------------------------------------------------
IF SINTE EQ AUDIO OR SINTE EQ PCH OR SINTE EQ ENPCH
pre_punt  PROC ;construye la tabla de verbaliaci¢n de puntuaci¢n
          LEA     SI,puntuacion
pre_loop1:MOV     BL,BYTE PTR CS:[SI]
          CMP     BL,0
          JE      pre_end
          INC     SI
          MOV     BH,0
          SHL     BX,1
          MOV     CS:tabla[BX],SI
pre_loop2:INC     SI
          CMP     BYTE PTR CS:[SI], "$"
          JNE     pre_loop2
          INC     SI
          XOR     AH,AH
          MOV     AL,BYTE PTR CS:[SI]
          MOV     CS:tabla2[BX],AX
          INC     SI
          JMP     pre_loop1
pre_end:  RET
pre_punt  ENDP
ENDIF
;----------------------------------------------------------------------------
IF SINTE EQ BS OR SINTE EQ PCH
act_puerto PROC   ;actualiza varables de UART si utilizamos COM2.
          CMP     CS:com,0               ;es COM1 ?
          JE      act_p_end              ;si, se quedan como est n.
          MOV     CS:irq,00001000B       ;reinicializamos variables de
          MOV     CS:puerto_RBR,2F8H     ; puertos para com2.
          MOV     CS:puerto_THR,2F8H
          MOV     CS:puerto_IER,2F8H+1
          MOV     CS:puerto_LCR,2F8H+3
          MOV     CS:puerto_MCR,2F8H+4
          MOV     CS:puerto_LSR,2F8H+5
          MOV     CS:puerto_MSR,2F8H+6
act_p_end:RET
act_puerto ENDP
ENDIF
;----------------------------------------------------------------------------

instala:  MOV     CS:seg_pil_nue,CS    ;inicializaci¢n de variables...
          MOV     CS:pun_pil_nue,OFFSET stack_top
          MOV     AH,34H          ;averiguar direcci¢n de INDOS
          INT     21H
          MOV     WORD PTR CS:indos,BX
          MOV     WORD PTR CS:indos[2],ES
          CALL    tipo_video      ;cargar la variable de direcci¢n de memoria.
          MOV     flag,act        ;rutina activada...
IF SINTE EQ AUDIO OR SINTE EQ PCH OR SINTE EQ ENPCH
          CALL    pre_punt        ;prepara tabla de puntuaci¢n.
ENDIF
ini_scr:  CALL    save_scr        ;inicializamos las pantallas con valores
          INC     CS:screen       ; por defecto.
          CMP     CS:screen,9
          JBE     ini_scr
          MOV     CS:screen,0

          MOV     CL,BYTE PTR DS:[80H]  ;hay par metros ?
          CMP     CL,0
          JNZ     scan_in
          JMP     scan_end
scan_in:  MOV     CH,0
          MOV     DI,81H
          MOV     AH,0    ;indica si se ha encontrado alg£n par metro ya.
scan:     MOV     AL,BYTE PTR DS:[DI]
          CMP     AL,espacio
          JE      scan_nxt
          CMP     CS:f_conf,0
          JNE     file?
          CMP     AH,1
          JE      no_first
          CMP     AL,"d"
          JE      si_descar
          CMP     AL,"D"
          JNE     no_descar
si_descar:MOV     CS:f_descarga,1
          JMP     scan_end
no_descar:MOV     AH,1
          CMP     AL,"0"
          JB      no_first
          CMP     AL,"4"
          JA      no_first
          SUB     AL,"0"
          DEC     AL
          MOV     CS:com,AL
          JMP     scan_nxt
no_first: CMP     AL,"N"
          JE      no_serie
          CMP     AL,"n"
          JNE     no_nN
no_serie: MOV     CS:f_no_serie,1
          JMP     scan_nxt
no_nN:    CMP     AL,"r"
          JE      si_recu
          CMP     AL,"R"
          JNE     no_recu
si_recu:  MOV     CS:f_conf,1
          JMP     scan_nxt
no_recu:  CMP     AL,"g"
          JE      si_graba
          CMP     AL,"G"
          JNE     scan_end
si_graba: MOV     CS:f_conf,2
          JMP     scan_nxt
scan_nxt: INC     DI
          LOOP    scan
          JMP     scan_end
file?:    MOV     CS:p_file,DI
          ADD     DI,CX
          MOV     BYTE PTR DS:[DI],0   ;cadena ASCIIZ.

scan_end: XOR     AX,AX
          MOV     ES,AX           ;ES=0
          CLI                     ;inabilitar interrupciones
          MOV     DI,WORD PTR d_video    ;averiguar si la rutina ya est 
          MOV     ES,WORD PTR d_video[2] ; cargada en memoria
          MOV     SI,OFFSET sub_video
          PUSH    CS
          POP     DS
          MOV     CX,25                  ;comparamos 25 carcateres
          CLD
          REPE    CMPSB
          JNE     cargala                ;no son iguales, no est  cargada.
          JMP     salida

cargala:  CMP     CS:f_descarga,1
          JNE     cargando
          MOV     DX,OFFSET no_cargado   ;mensaje de error
          MOV     AH,09H
          INT     21H
          RET
cargando: MOV     DX,OFFSET en_pantalla  ;presentaci¢n en pantalla
          MOV     AH,09H
          INT     21H

          XOR     AX,AX                  ;no est  cargada
          MOV     ES,AX                  ;ES=0

          MOV     AX,WORD PTR d_clock    ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_clock,AX  ; interrupci¢n de reloj
          MOV     AX,WORD PTR d_clock[2]
          MOV     WORD PTR ant_clock[2],AX
          MOV     WORD PTR d_clock,OFFSET sub_clock
          MOV     WORD PTR d_clock[2],CS

          MOV     AX,WORD PTR d_hard     ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_hard,AX   ; interrupci¢n hardware de teclado
          MOV     WORD PTR old_hard,AX
          MOV     AX,WORD PTR d_hard[2]
          MOV     WORD PTR ant_hard[2],AX
          MOV     WORD PTR old_hard[2],AX
          MOV     WORD PTR d_hard,OFFSET sub_hard
          MOV     WORD PTR d_hard[2],CS

IF SINTE EQ BS OR SINTE EQ PCH           ;activar int. serie si es preciso.
          CMP     CS:com,1               ;es COM2 ?
          JE      com2
          MOV     AX,WORD PTR d_serie    ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_serie,AX  ; puerta serie COM1.
          MOV     AX,WORD PTR d_serie[2]
          MOV     WORD PTR ant_serie[2],AX
          MOV     WORD PTR d_serie,OFFSET sub_serie
          MOV     WORD PTR d_serie[2],CS
          JMP     no_com2

com2:     MOV     AX,WORD PTR d_serie2   ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_serie,AX  ; puerta serie COM2.
          MOV     AX,WORD PTR d_serie2[2]
          MOV     WORD PTR ant_serie[2],AX
          MOV     WORD PTR d_serie2,OFFSET sub_serie
          MOV     WORD PTR d_serie2[2],CS
          CALL    act_puerto
no_com2:
ENDIF  
          MOV     AX,WORD PTR d_video    ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_video,AX  ; interrupci¢n de video
          MOV     WORD PTR old_video,AX
          MOV     AX,WORD PTR d_video[2]
          MOV     WORD PTR ant_video[2],AX
          MOV     WORD PTR old_video[2],AX
          MOV     WORD PTR d_video,OFFSET sub_video
          MOV     WORD PTR d_video[2],CS

          MOV     AX,WORD PTR d_sys      ;asignamos nueva direcci¢n de la
          MOV     WORD PTR ant_sys,AX    ; interrupci¢n de sistema
          MOV     AX,WORD PTR d_sys[2]
          MOV     WORD PTR ant_sys[2],AX
          MOV     WORD PTR d_sys,OFFSET sub_sys
          MOV     WORD PTR d_sys[2],CS

          MOV     AX,WORD PTR d_tecla    ;asignamos nueva direccion de la
          MOV     WORD PTR ant_tecla,AX  ; interrupci¢n de teclado
          MOV     AX,WORD PTR d_tecla[2]
          MOV     WORD PTR ant_tecla[2],AX
          MOV     WORD PTR d_tecla,OFFSET sub_tecla
          MOV     WORD PTR d_tecla[2],CS
          MOV     WORD PTR d_tec_hab,OFFSET sub_tecla
          MOV     WORD PTR d_tec_hab[2],CS

                                         ;instalamos la nueva interrupci¢n
                                         ; de servicio a otros programas.
          MOV     WORD PTR d_servi,OFFSET sub_servi
          MOV     WORD PTR d_servi[2],CS

          STI

IF SINTE EQ BS OR SINTE EQ CIBER OR SINTE EQ PCH   ;s¢lo si puerto serie.
          CALL    conf_serie         ;configuramos puerto serie
ENDIF
          MOV     flag,no_act
          CMP     CS:p_file,0        ;hay nombre de fichero ?
          JE      confi_par          ;no, configura par metros de voz.
          CMP     CS:f_conf,1        ;si, es recuperar configuraci¢n ?
          JNE     confi_par          ;no, configura par metros de voz.
          CALL    r_conf             ;si, recupera configuraci¢n.
          JMP     no_confi           ;no hace falta configurar param. de voz.
confi_par:CALL    h_volu             ;configuramos volumen, velocidad y tono.
          CALL    h_velo
          CALL    h_tono
          CALL    h_otros            ;configurar otros par metros.
no_confi: hb      saludo             ;manda saludo
          MOV     DX,OFFSET instalar ;instalar rutina residente, FIN.
          INT     27H
                                     ;FIN DE LA CARGA DEL PROGRAMA!


salida:   STI                        ;HABLA YA ESTABA EN MEMORIA.
IF SINTE EQ BS OR SINTE EQ CIBER OR SINTE EQ PCH   ;s¢lo si puerto serie.
          XOR     AX,AX              ;lo que viene ahora es para encontrar
          MOV     ES,AX              ;la variable com en el programa cargado.
          MOV     DI,WORD PTR d_video;direcci¢n de sub_video..
          MOV     AX,WORD PTR d_video[2]
          MOV     ES,AX
          MOV     AL,BYTE PTR ES:-1[DI] ;actualiza com. (est  justo antes
          MOV     CS:com,AL             ; de sub_video).
ENDIF
IF SINTE EQ BS OR SINTE EQ PCH        ;si trabajamos con int. hard serie.  
          CALL    act_puerto          ;actualizamos variables de puertos.
ENDIF
          CMP     CS:f_descarga,1
          JE      descarga
          JMP     continua
descarga: CLI                            ;DESCARGA DEL PROGRAMA.
          XOR     AX,AX
          MOV     ES,AX                  ;ES=0
                                         ;reajustar vectores de interrupci¢n
          MOV     AX,WORD PTR d_video[2] ;segmento donde est  el programa.
          PUSH    AX                     ; lo guardo en la pila.
          MOV     AX,WORD PTR ant_clock
          MOV     WORD PTR d_clock,AX
          MOV     AX,WORD PTR ant_clock[2]
          MOV     WORD PTR d_clock[2],AX

          MOV     AX,WORD PTR ant_hard
          MOV     WORD PTR d_hard,AX
          MOV     AX,WORD PTR ant_hard[2]
          MOV     WORD PTR d_hard[2],AX

IF SINTE EQ BS OR SINTE EQ PCH
          CMP     CS:com,1               ;es COM2 ?
          JE      comu2
          MOV     AX,WORD PTR ant_serie
          MOV     WORD PTR d_serie,AX
          MOV     AX,WORD PTR ant_serie[2]
          MOV     WORD PTR d_serie[2],AX
          JMP     no_comu2
comu2:    MOV     AX,WORD PTR ant_serie
          MOV     WORD PTR d_serie2,AX
          MOV     AX,WORD PTR ant_serie[2]
          MOV     WORD PTR d_serie2[2],AX
no_comu2: MOV     DX,CS:puerto_MCR       ;le indicamos al UART que no genere
          IN      AL,DX                  ;interrupci¢n y que se desactiven
          AND     AL,11110100B           ;DTR y CTS (que se quede como estaba)
          OUT     DX,AL
          IN      AL,21H                 ;que no genere interrupci¢n de COM.
          OR      AL,CS:irq              ;IRQ4 o IRQ3 (com2)
          OUT     21H,AL                 ;se lo mandamos al PIC.
ENDIF

          MOV     AX,WORD PTR ant_video
          MOV     WORD PTR d_video,AX
          MOV     AX,WORD PTR ant_video[2]
          MOV     WORD PTR d_video[2],AX

          MOV     AX,WORD PTR ant_sys
          MOV     WORD PTR d_sys,AX
          MOV     AX,WORD PTR ant_sys[2]
          MOV     WORD PTR d_sys[2],AX

          MOV     AX,WORD PTR ant_tecla
          MOV     WORD PTR d_tecla,AX
          MOV     AX,WORD PTR ant_tecla[2]
          MOV     WORD PTR d_tecla[2],AX

          MOV     WORD PTR d_servi,0
          MOV     WORD PTR d_servi[2],0

          STI

          POP     ES                     ;liberar memoria ocupada, 
          MOV     AH,49H                 ;recupero segemento de la pila.
          INT     21H                    ;just do it!

IF SINTE EQ AUDIO OR SINTE EQ ENPCH      ;Si audiobox...
          MOV     CS:call_type,1         ; cambiamos par metro para audiolog
ENDIF
          hb      despedida              ;mensaje de despedida.
IF SINTE EQ AUDIO                        ;Si Parla...
          MOV     AL,4                   ; descargamos ttsebox de la memoria.  
          CALL    audiolog
ENDIF
          RET                            ; FIN DE DESCARGA!


continua: CMP     CS:p_file,0            ; Hay nombre de fichero ?
          JE      no_conf                ; no, llamada a Habla sin fuste.
          MOV     CS:f_cargado,1         ;Advertimos programa ya en memoria.
          CMP     CS:f_conf,1            ;Es recuperar configuraci¢n ?
          JNE     es_grab                ;No, es grabar.
          CALL    r_conf                 ;Recupera configuraci¢n.
          RET                            ;Bye.
es_grab:  CALL    g_conf                 ;Graba configuraci¢n.
          RET                            ;Bye.
no_conf:  hb      cargado                ; No se descarga el programa
          RET                            ;sigue en memoria.

instalar  ENDP
;----------------------------------------------------------------------------
reside    ENDS
          END inicio                   ;Fin del programa completo
;----------------------------------------------------------------------------
