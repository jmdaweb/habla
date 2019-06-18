; Gesti¢n de los par metros de voz. Se incluye en la rutina de revisi¢n.

t_ivolu?: CMP     AH,k_ivolu     ;incrementar volumen ?
          JNE     t_dvolu?
          CMP     CS:volu,15
          JB      ivolu_ok
          JMP     pitido
ivolu_ok: INC     CS:volu
          CALL    h_volu
          hb      m_ivolu
          JMP     rev_loop
t_dvolu?: CMP     AH,k_dvolu     ;decrementar volumen ?
          JNE     t_ivelo?
          CMP     CS:volu,1
          JA      dvolu_ok
          JMP     pitido
dvolu_ok: DEC     CS:volu
          CALL    h_volu
          hb      m_dvolu
          JMP     rev_loop
t_ivelo?: CMP     AH,k_ivelo     ;incrementar velocidad ?
          JNE     t_dvelo?
          CMP     CS:velo,15
          JB      ivelo_ok
          JMP     pitido
ivelo_ok: INC     CS:velo
          CALL    h_velo
          hb      m_ivelo
          JMP     rev_loop
t_dvelo?: CMP     AH,k_dvelo     ;decrementar velocidad ?
          JNE     t_itono?
          CMP     CS:velo,1
          JA      dvelo_ok
          JMP     pitido
dvelo_ok: DEC     CS:velo
          CALL    h_velo
          hb      m_dvelo
          JMP     rev_loop
t_itono?: CMP     AH,k_itono     ;incrementar tono ?
          JNE     t_dtono?
          CMP     CS:tono,43
          JB      itono_ok
          JMP     pitido
itono_ok: ADD     CS:tono,2
          CALL    h_tono
          hb      m_itono
          JMP     rev_loop
t_dtono?: CMP     AH,k_dtono     ;decrementar tono ?
          JNE     t_punt?
          CMP     CS:tono,1
          JA      dtono_ok
          JMP     pitido
dtono_ok: SUB     CS:tono,2
          CALL    h_tono
          hb      m_dtono
          JMP     rev_loop
t_punt?:  CMP     AH,k_punt      ;activar/desactivar puntuaci¢n?
          JNE     t_c_file?
          hb      m_punt
          CMP     CS:f_punt,1
          MOV     CS:f_punt,0
          LEA     DI,m_des
          JE      punt_des
          MOV     CS:f_punt,1
          LEA     DI,m_act
punt_des: CALL    manda_str
          CALL    h_otros
          JMP     rev_loop
