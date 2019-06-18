;***********************************************************************
;*  HABLA.ASM - Programa para utilizar sintetizador de voz conectado   *
;*              a la puerta serie.                                     *
;*                                                                     *
;*  Autor: Cayetano Mero§o Fuentes                                     *
;*  Revisi¢n: 15/11/96                                                 *
;*  Versi¢n 3.30    Para utilizar PC HABLADO como sintetizador         *
;*                  Con Te.asm ver. 1.11                               *
;***********************************************************************

;----------------------------------------------------------------------------

SINTE     EQU       4       ;indica que sintetizador es.
VOLU_DEF  EQU       18      ;volumen   por defecto.
VELO_DEF  EQU       99      ;velocidad por defecto.
TONO_DEF  EQU       12      ;tono      por defecto.
quiet     EQU       159     ;"ü" Para callar a PC HABLADO
speak     EQU       157     ;"ù" Para hacer hablar al PC HABLADO.
k_iexpr   EQU       5EH     ;   "  ^F1      - Incrementar expresividad.
k_dexpr   EQU       5FH     ;   "  ^F2      - Decrementar expresividad.
k_punt    EQU       60H     ;   "  ^F3      - Activar/desactivar puntuaci¢n.
;----------------------------------------------------------------------------
INCLUDE   head.asm

f_concat          DB     0 ;para que audilog concatene mensajes
m_volu            DB     "<* E GM"
  volu_val        DB     "     *>$"
m_velo            DB     "<* E VM"
  velo_val        DB     "     *>$"
m_tono            DB     "<* E AM"
  tono_val        DB     "     *>$"
m_expr            DB     "<* E AP"
  expr_val        DB     "     *>$"
d_zone            DB     80*25*2 dup(' ') ; area de datos.
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
                  DB     "†a acentuada$",0
                  DB     "Çe acentuada$",0
                  DB     "°i acentuada$",0
                  DB     "¢o acentuada$",0
                  DB     "£u acentuada$",0
                  DB     "*" , "asterisco$",1
                  DB     "+" , "signo de sumar$",1
                  DB     "-" , "gui¢n$",1
                  DB     "(" , "abre parÇntesis$",1
                  DB     ")" , "cierra parÇntesis$",1
                  DB     "[" , "abre corchete$",1
                  DB     "]" , "cierra corchete$",1
                  DB     "{" , "abre llave$",1
                  DB     "}" , "cierra llave$",1
                  DB     "=" , "igual$",1
                  DB     "|" , "barra vertical$",1
                  DB     "®abre interrogaci¢n$",1
                  DB     "?" , "cierra interrogaci¢n$",1
                  DB     "≠abre admiraci¢n$",1
                  DB     "!" , "cierra admiraci¢n$",1
                  DB     "%" , "tanto por ciento$",1
                  DB     '"' , "comillas$",1
                  DB     0
tabla             DW     256 DUP(0)
tabla2            DW     256 DUP(0)
fin_lecto         DB     0
m_ivolu           DB     quiet, "m†s alto $"
m_ivelo           DB     quiet, "m†s r†pido $"
m_itono           DB     quiet, "m†s agudo $"
m_iexpr           DB     quiet, "m†s expresivo $"
m_dvolu           DB     quiet, "m†s bajo $"
m_dvelo           DB     quiet, "m†s lento $"
m_dtono           DB     quiet, "m†s grave $"
m_dexpr           DB     quiet, "menos expresivo $"
m_punt            DB     quiet,"puntuaci¢n $"
