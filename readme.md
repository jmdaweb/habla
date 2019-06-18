## Introducción

Este repositorio contiene el código fuente del lector de pantalla Habla, liberado con el permiso de su autor bajo la licencia GNU General Public License versión 2 y actualizado por última vez en el año 1996.

Habla es un lector de pantalla completamente en español para MS-DOS. A pesar de que existen multitud de lectores para este sistema, Habla es el único conocido que se encuentra en nuestro idioma. Está programado en lenguaje ensamblador, y sus ejecutables son compatibles con la arquitectura de la época.

A principios de los años 90, las tarjetas de sonido no existían todavía o no estaban al alcance de todo el mundo. Por este motivo, las distintas versiones de este lector de pantalla se diseñaron para adaptarse a diversos sintetizadores hardware, o más concretamente a anotadores que ofrecían la función de síntesis de voz recibiendo información desde un puerto serie. Estos son los dispositivos soportados:

* Braille Hablado (BH).
* Cibervoz (CIBER).
* Versión incorporada en PC Hablado (ENPCH).
* PC Hablado (desde un ordenador) (PCH).
* Audiologic (sintetizador de pago que sí usaba la tarjeta de sonido) (PARLA).

## Cómo compilar desde el código fuente

Para compilar los distintos ejecutables de Habla necesitarás disponer de un sistema MS-DOS o alguna de sus variantes más modernas (Free Dos, Dosbox, etc.). Las pruebas realizadas antes de redactar este documento se han llevado a cabo con MS-DOS 6.22 en español instalado en una máquina virtual VMWare. No se han hecho pruebas con otras variantes o versiones del sistema.

Ya que las utilidades de ensamblaje y vinculación empleadas pueden ser muy difíciles de encontrar hoy en día, al igual que los ejecutables del sintetizador Audiologic, también se incluyen en este repositorio. Sin embargo, están sujetas a los términos de sus respectivas licencias. Dicho esto, sigue los siguientes pasos para compilar Habla:

* Copia la carpeta asm de este repositorio a la unidad C de MS-DOS. Si usas una máquina virtual, puedes hacerlo montando el disco duro como unidad del sistema con permisos de escritura.
* Navega a la carpeta asm. Asumiendo que estás en la unidad C, teclea este comando: `cd asm`
* Modifica la variable PATH del sistema para que tenga en cuenta en todo momento la carpeta asm. Puedes hacerlo llamando al fichero pat.bat de la siguiente manera: `pat`
* Inicia el proceso de compilación: `PALL`
    * Este script llama recursivamente al archivo p.bat desde las carpetas de las distintas variantes.
    * A su vez, el archivo p.bat crea un fichero objeto con la utilidad MASM, que es el ensamblador.
    * Una vez se ensambla este objeto, se convierte en un ejecutable (.exe) con la utilidad link, que se encarga de enlazarlo.
    * Finalmente, la utilidad exe2bin convierte el ejecutable en un archivo .com, más pequeño y optimizado.
* Una vez termine el proceso, encontrarás los ejecutables de Habla en sus respectivas carpetas. Si quieres crear una carpeta de distribución sólo con los binarios, llama al archivo copia.bat: `copia`. El resultado se alojará en C:\habla.330.

## Habla ya está compilado. ¿Y ahora qué?

Es muy probable que no tengas a tu disposición ningún sintetizador hardware, así que lo mejor es simularlo. Puedes visitar el [proyecto vbns-ao2](https://github.com/sukiletxe/vbns-ao2), que te permitirá simular el sintetizador hardware incluido en un Braille Hablado y escuchar la voz a través de NVDA, Sapi 5 o Espeak.

Una vez tengas el simulador y los puertos Com configurados, puedes activar Habla ejecutando el siguiente comando: `habla 1`. Habla se activará y comenzará a emitir información por el puerto Com1. Si quieres que arranque con el sistema, añade el comando anterior al archivo autoexec.bat. Puedes encontrar más información sobre el funcionamiento de Habla en el manual de usuario, incluido también en este repositorio. Del mismo modo, y para mayor comodidad, también se encuentran los binarios.
