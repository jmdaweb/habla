; Gesti¢n de los par metros de voz. Se incluye en la rutina de revisi¢n.

t_ivolu?: CMP     AH,k_ivolu     ;incrementar volumen ?
          JNE     t_dvolu?
          CMP     CS:volu,9
          JB      ivolu_ok
          JMP     pitido
ivolu_ok: INC     CS:volu
          hb_c    quiet
          CALL    h_volu
          hb      m_ivolu
          JMP     rev_loop
t_dvolu?: CMP     AH,k_dvolu     ;decrementar volumen ?
          JNE     t_ivelo?
          CMP     CS:volu,0
          JA      dvolu_ok
          JMP     pitido
dvolu_ok: DEC     CS:volu
          hb_c    quiet
          CALL    h_volu
          hb      m_dvolu
          JMP     rev_loop
t_ivelo?: CMP     AH,k_ivelo     ;incrementar velocidad ?
          JNE     t_dvelo?
          CMP     CS:velo,9
          JB      ivelo_ok
          JMP     pitido
ivelo_ok: INC     CS:velo
          hb_c    quiet
          CALL    h_velo
          hb      m_ivelo
          JMP     rev_loop
t_dvelo?: CMP     AH,k_dvelo     ;decrementar velocidad ?
          JNE     t_itono?
          CMP     CS:velo,0
          JA      dvelo_ok
          JMP     pitido
dvelo_ok: DEC     CS:velo
          hb_c    quiet
          CALL    h_velo
          hb      m_dvelo
          JMP     rev_loop
t_itono?: CMP     AH,k_itono     ;incrementar tono ?
          JNE     t_dtono?
          CMP     CS:tono,9
          JB      itono_ok
          JMP     pitido
itono_ok: INC     CS:tono
          hb_c    quiet
          CALL    h_tono
          hb      m_itono
          JMP     rev_loop
t_dtono?: CMP     AH,k_dtono     ;decrementar tono ?
          JNE     t_cib1?
          CMP     CS:tono,0
          JA      dtono_ok
          JMP     pitido
dtono_ok: DEC     CS:tono
          hb_c    quiet
          CALL    h_tono
          hb      m_dtono
          JMP     rev_loop
t_cib1?:  CMP     AH,k_cib1      ;cambiar par 1 del ciber ?
          JNE     t_cib2?
          LEA     DI,m_cib1
          LEA     SI,cib1
          MOV     CS:voz_par,'g'
          JMP     cib_par
t_cib2?:  CMP     AH,k_cib2      ;cambiar par 2 del ciber ?
          JNE     t_cib3?
          LEA     DI,m_cib2
          LEA     SI,cib2
          MOV     CS:voz_par,'h'
          JMP     cib_par
t_cib3?:  CMP     AH,k_cib3      ;cambiar par 3 del ciber ?
          JNE     t_cib4?
          LEA     DI,m_cib3
          LEA     SI,cib3
          MOV     CS:voz_par,'i'
          JMP     cib_par
t_cib4?:  CMP     AH,k_cib4      ;cambiar par 4 del ciber ?
          JNE     t_cib5?
          LEA     DI,m_cib4
          LEA     SI,cib4
          MOV     CS:voz_par,'j'
          JMP     cib_par
t_cib5?:  CMP     AH,k_cib5      ;cambiar par 5 del ciber ?
          JNE     t_cib6?
          LEA     DI,m_cib5
          LEA     SI,cib5
          MOV     CS:voz_par,'k'
          JMP     cib_par
t_cib6?:  CMP     AH,k_cib6      ;cambiar par 6 del ciber ?
          JNE     t_c_file?
          LEA     DI,m_cib6
          LEA     SI,cib6
          MOV     CS:voz_par,'f'
cib_par:  hb_c    quiet
          CMP     BYTE PTR CS:[SI],0
          LEA     BX,m_on
          MOV     BYTE PTR CS:[SI],1
          JE      cib_on
          LEA     BX,m_off
          MOV     BYTE PTR CS:[SI],0
cib_on:   MOV     AL,CS:BYTE PTR CS:[SI]
          CALL    h_voz
          CALL    manda_str
          MOV     DI,BX
          CALL    manda_str
          JMP     rev_loop
