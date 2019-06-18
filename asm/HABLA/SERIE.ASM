;Variables y rutinas para la gesti¢n de los puertos COM1 y COM2 si tenemos
; que recibir informaci¢n de un teclado externo.

m_kbd             DB     quiet,"teclado externo $"
irq               DB     00010000B ;irq de COM1.
puerto_RBR        DW     3F8H      ;puertos COM1.
puerto_THR        DW     3F8H      ;si es COM2 es igual pero la base es 2F8H.
puerto_IER        DW     3F8H+1
puerto_LCR        DW     3F8H+3
puerto_MCR        DW     3F8H+4
puerto_LSR        DW     3F8H+5
puerto_MSR        DW     3F8H+6
;----------------------------------------------------------------------------
sub_serie PROC
; subrutina que captura la interrupci¢n hardware del puerto serie COM1.
          PUSHF
          PUSH    AX
          PUSH    DX
          MOV     DX,CS:puerto_RBR
          IN      AL,DX
          CMP     AL,128        ;es menor de 128 (7 bit) ?
          JB      sietebit      ;si, entonces vale.
          JMP     out_serie     ;no, es >= 128, no vale.
sietebit: CMP     CS:f_kbd,1    ;teclado externo activado?
          JNE     out_serie     ;no, salte.
          CALL    bra_kbd       ;si, gestionalo.
out_serie:MOV     AL,20H        ;interrupci¢n concluida.
          OUT     20H,AL
          POP     DX
          POP     AX
          POPF
          IRET
sub_serie ENDP
;----------------------------------------------------------------------------
conf_serie PROC
; Rutina para configurar el puerto serie.
          CMP     CS:f_no_serie,1    ;configuramos par metros puerto ?
          JE      conf_end           ;no.
          MOV     AH,00              ;configuramos par metros standard.
          MOV     DH,0
          MOV     DL,CS:com
          MOV     AL,standard
          INT     14H

conf_end: MOV     DX,CS:puerto_LCR   ;configuramos la UART.
          IN      AL,DX
          AND     AL,01111111B
          OUT     DX,AL
          MOV     DX,CS:puerto_IER
          IN      AL,DX
          MOV     AL,00000001B
          OUT     DX,AL
          MOV     DX,CS:puerto_MCR
          IN      AL,DX
          OR      AL,00001011B
          OUT     DX,AL

          MOV     AL,CS:irq
          NOT     AL
          MOV     DL,AL
          IN      AL,21H                 ;permite interrupci¢n de COM1 ¢ 2.
          AND     AL,DL                  ;IRQ4 ¢ IRQ3 (com2).
          OUT     21H,AL
          RET
conf_serie ENDP
;---------------------------------------------------------------------------
