#!/usr/bin/env bash
# GNU shell script para renombrar a minúscula ficheros y
# directorios
# ---------------------------------------------------------------
# Copyright (c) 2009 flossblog <http://flossblog.wordpress.com/>
# Este script es liberado bajos los téminos de la GNU GPL
# version 2.0 o superior
# --------------------------------------------------------------
# Uso:
# El script recibe como parámetro el nombre un fichero o
# directorio, para un directorio la operación se hará de
# forma recursiva
#  -------------------------------------------------------------
# Última actualización: 10 de junio del 2009

find "$1" -depth -print0 | while read -d $'\0' file; do
        NEWBASENAME=$(basename "$file" | tr [:upper:] [:lower:])
        NEWFILENAME=$(dirname "$file")/$NEWBASENAME
        mv -f "$file" "$NEWFILENAME" 2> /dev/null
done
