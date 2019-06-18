; Gesti¢n de los par metros de voz. Se incluye en la rutina de revisi¢n.

t_ivolu?: CMP     AH,k_ivolu     ;incrementar volumen ?
          JNE     t_dvolu?
          CMP     CS:volu,27
          JBE     ivolu_ok
          JMP     pitido
ivolu_ok: ADD     CS:volu,3
          CALL    h_volu
          hb      m_ivolu
          JMP     rev_loop
t_dvolu?: CMP     AH,k_dvolu     ;decrementar volumen ?
          JNE     t_ivelo?
          CMP     CS:volu,3
          JAE     dvolu_ok
          JMP     pitido
dvolu_ok: SUB     CS:volu,3
          CALL    h_volu
          hb      m_dvolu
          JMP     rev_loop
t_ivelo?: CMP     AH,k_ivelo     ;incrementar velocidad ?
          JNE     t_dvelo?
          CMP     CS:velo,189
          JBE     ivelo_ok
          JMP     pitido
ivelo_ok: ADD     CS:velo,9
          CALL    h_velo
          hb      m_ivelo
          JMP     rev_loop
t_dvelo?: CMP     AH,k_dvelo     ;decrementar velocidad ?
          JNE     t_itono?
          CMP     CS:velo,9
          JAE     dvelo_ok
          JMP     pitido
dvelo_ok: SUB     CS:velo,9
          CALL    h_velo
          hb      m_dvelo
          JMP     rev_loop
t_itono?: CMP     AH,k_itono     ;incrementar tono ?
          JNE     t_dtono?
          CMP     CS:tono,14
          JBE     itono_ok
          JMP     pitido
itono_ok: ADD     CS:tono,2
          CALL    h_tono
          hb      m_itono
          JMP     rev_loop
t_dtono?: CMP     AH,k_dtono     ;decrementar tono ?
          JNE     t_iexpr?
          CMP     CS:tono,2
          JAE     dtono_ok
          JMP     pitido
dtono_ok: SUB     CS:tono,2
          CALL    h_tono
          hb      m_dtono
          JMP     rev_loop
t_iexpr?: CMP     AH,k_iexpr     ;incrementar expresividad ?
          JNE     t_dexpr?
          CMP     CS:expr,5
          JBE     iexpr_ok
          JMP     pitido
iexpr_ok: INC     CS:expr
          CALL    h_otros
          hb      m_iexpr
          JMP     rev_loop
t_dexpr?: CMP     AH,k_dexpr     ;decrementar expresividad ?
          JNE     t_punt?
          CMP     CS:expr,1
          JAE     dexpr_ok
          JMP     pitido
dexpr_ok: DEC     CS:expr
          CALL    h_otros
          hb      m_dexpr
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
          JMP     rev_loop
