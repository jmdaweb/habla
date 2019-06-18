;***********************************************************************
;*  HABLA.ASM - Programa para utilizar sintetizador de voz conectado   *
;*              a la puerta serie.                                     *
;*                                                                     *
;*  Autor: Cayetano Mero¤o Fuentes                                     *
;*  Revisi¢n: 15/11/96                                                 *
;*  Versi¢n 3.30    Habla en PC HABLADO                                *
;*                                                                     *
;***********************************************************************

;----------------------------------------------------------------------------
SINTE     EQU       5       ;indica que sintetizador es.
VOLU_DEF  EQU       18      ;volumen   por defecto.
VELO_DEF  EQU       99      ;velocidad por defecto.
TONO_DEF  EQU       12      ;tono      por defecto.
k_iexpr   EQU       5EH     ;   "  ^F1      - Incrementar expresividad.
k_dexpr   EQU       5FH     ;   "  ^F2      - Decrementar expresividad.
k_punt    EQU       60H     ;   "  ^F3      - Activar/desactivar puntuaci¢n.
speak     EQU       " "     ; Para hacer hablar.....
quiet     EQU       18H     ; Para callar a PC HABLADO
;k1        EQU       21H     ;tecla punto 1, F EN EL PC.
;k2        EQU       20H     ;tecla punto 2, D
;k3        EQU       1FH     ;tecla punto 3, S
;k4        EQU       24H     ;tecla punto 4, J
;k5        EQU       25H     ;tecla punto 5, K
;k6        EQU       26H     ;tecla punto 6, L
;ke        EQU       39H     ;tecla espacio.
k1        EQU       27H     ;tecla punto 1, ? EN EL PCH.
k2        EQU       26H     ;tecla punto 2, ?
k3        EQU       25H     ;tecla punto 3, ?
k4        EQU       24H     ;tecla punto 4, ?
k5        EQU       49H     ;tecla punto 5, ?
k6        EQU       4DH     ;tecla punto 6, ?
ke        EQU       23H     ;tecla espacio.
;----------------------------------------------------------------------------
INCLUDE   head.asm

f_concat          DB     0 ;para que audilog concatene mensajes
fin_lecto         DB     0
m_ivolu           DB     quiet, "m s alto $"
m_ivelo           DB     quiet, "m s r pido $"
m_itono           DB     quiet, "m s agudo $"
m_iexpr           DB     quiet, "m s expresivo $"
m_dvolu           DB     quiet, "m s bajo $"
m_dvelo           DB     quiet, "m s lento $"
m_dtono           DB     quiet, "m s grave $"
m_dexpr           DB     quiet, "menos expresivo $"
m_punt            DB     quiet,"puntuaci¢n $"
m_volu            DB     "<* E GM"
  volu_val        DB     "     *>$"
m_velo            DB     "<* E VM"
  velo_val        DB     "     *>$"
m_tono            DB     "<* E AM"
  tono_val        DB     "     *>$"
m_expr            DB     "<* E AP"
  expr_val        DB     "     *>$"
c_area            DB     16 dup(?) ;area de comunicaciones con Audilogic.
  c_halt          DB     0
  c_pause         DB     0
  c_ret           DB     255
  c_cod           DB     ?
  c_seg           DW     ?
  c_off           DW     ?
  c_len           DW     ?
d_zone            DB     80*25*2 dup(' ') ; area de datos.
call_type         DB     0
inter_on          DB     "fin de lectura <* T ALL *>$" ;habilita interrupci¢n
                                                       ;         de sisntesis.
inter_off         DB     "<* T OFF *>$" ;deshabilita   "             "
puntuacion        DB     ":" , "dos puntos$",1 ;si esta a uno siempre se habla
                  DB     "." , "punto$",1
                  DB     "," , "coma$",1
                  DB     ";" , "punto y coma$",1
                  DB     "\" , "barra invertida$",1
                  DB     "/" , "barra$",1
                  DB     ">" , "mayor que$",1
                  DB     "<" , "menor que$",1
                  DB     "$" , "dolar$",1
                  DB     " a acentuada$",0
                  DB     "‚e acentuada$",0
                  DB     "¡i acentuada$",0
                  DB     "¢o acentuada$",0
                  DB     "£u acentuada$",0
                  DB     "*" , "asterisco$",1
                  DB     "+" , "signo de sumar$",1
                  DB     "-" , "gui¢n$",1
                  DB     "(" , "abre par‚ntesis$",1
                  DB     ")" , "cierra par‚ntesis$",1
                  DB     "[" , "abre corchete$",1
                  DB     "]" , "cierra corchete$",1
                  DB     "{" , "abre llave$",1
                  DB     "}" , "cierra llave$",1
                  DB     "=" , "igual$",1
                  DB     "|" , "barra vertical$",1
                  DB     "¨abre interrogaci¢n$",1
                  DB     "?" , "cierra interrogaci¢n$",1
                  DB     "­abre admiraci¢n$",1
                  DB     "!" , "cierra admiraci¢n$",1
                  DB     "%" , "tanto por ciento$",1
                  DB     '"' , "comillas$",1
                  DB     0
tabla             DW     256 DUP(0)
tabla2            DW     256 DUP(0)
codigo            DB     0
codig2            DB     0
