;***********************************************************************
;*  HABLA.ASM - Programa para utilizar sintetizador de voz conectado   *
;*              a la puerta serie.                                     *
;*                                                                     *
;*  Autor: Cayetano Mero¤o Fuentes                                     *
;*  Revisi¢n: 15/11/96                                                 *
;*  Versi¢n 3.30    BRAILLE HABLADO                                    *
;*                                                                     *
;***********************************************************************

;----------------------------------------------------------------------------
SINTE     EQU       1       ;indica que sintetizador es.
VOLU_DEF  EQU       4       ;volumen   por defecto.
VELO_DEF  EQU       11      ;velocidad por defecto.
TONO_DEF  EQU       16      ;tono      por defecto.
k_punt    EQU       60H     ;   "  ^F3      - Activar/desactivar puntuaci¢n.
speak     EQU       ' '     ; Para hacer hablar al BH.
quiet     EQU       18H     ; CONTROL-X para callar a Braille Hablado
orden     EQU       05H     ; CONTROL-E para par metros de voz del B.H.
;----------------------------------------------------------------------------
INCLUDE   head.asm

f_tono            DB     0    ;indica si se ha activado el tono de may£scula.
m_voz             DB     orden; CONTROL-E para B.H.
  voz_val         DW     ?
  voz_par         DB     ?
                  DB     " $"
m_act_punt        DB     orden, "A $"
m_des_punt        DB     orden, "Z $"
m_ivolu           DB     quiet, "m s alto $"
m_ivelo           DB     quiet, "m s r pido $"
m_itono           DB     quiet, "m s agudo $"
m_dvolu           DB     quiet, "m s bajo $"
m_dvelo           DB     quiet, "m s lento $"
m_dtono           DB     quiet, "m s grave $"
m_punt            DB     quiet,"puntuaci¢n $"

