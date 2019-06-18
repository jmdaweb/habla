;***********************************************************************
;*  HABLA.ASM - Programa para utilizar sintetizador de voz conectado   *
;*              a la puerta serie.                                     *
;*                                                                     *
;*  Autor: Cayetano Mero¤o Fuentes                                     *
;*  Revisi¢n: 15/11/96                                                 *
;*  Versi¢n 3.30    CIBERVOZ                                           *
;*                                                                     *
;***********************************************************************

;----------------------------------------------------------------------------
SINTE     EQU       2       ;indica que sintetizador es.
VOLU_DEF  EQU       7       ;volumen   por defecto.
VELO_DEF  EQU       4       ;velocidad por defecto.
TONO_DEF  EQU       3       ;tono      por defecto.
k_cib1    EQU       5EH     ; ^F1 Par metro 1 de Cibervoz.
k_cib2    EQU       5FH     ; ^F2 Par metro 2 de Cibervoz.
k_cib3    EQU       60H     ; ^F3 Par metro 3 de Cibervoz.
k_cib4    EQU       61H     ; ^F4 Par metro 4 de Cibervoz.
k_cib5    EQU       62H     ; ^F5 Par metro 5 de Cibervoz.
k_cib6    EQU       63H     ; ^F6 Par metro 6 de Cibervoz.
speak     EQU       0DH     ; Para hacer hablar a Cibervoz.
quiet     EQU       27      ; ESCAPE para callar a Cibervoz
abort     EQU       28      ; Interrumpe el mensaje actual
orden     EQU       '@'     ; para par metros de voz del Cibervoz

;----------------------------------------------------------------------------
INCLUDE   head.asm

f_vchar           DB     0 ;indica si estamos ejecutando v_char.
m_voz             DB     orden;
  voz_par         DB     ?
  voz_val         DB     ?
                  DB     " $"
m_ivolu           DB     "m s alto $"
m_ivelo           DB     "m s r pido $"
m_itono           DB     "m s agudo $"
m_dvolu           DB     "m s bajo $"
m_dvelo           DB     "m s lento $"
m_dtono           DB     "m s grave $"
m_cib1            DB     "ignorar caracteres especiales $"
m_cib2            DB     "ignorar signos de puntuaci¢n $"
m_cib3            DB     "ignorar espacios $"
m_cib4            DB     "deletrear n£meros $"
m_cib5            DB     "diccionario interno $"
m_cib6            DB     "ignorar caracteres de control $"

