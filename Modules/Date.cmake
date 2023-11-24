# SPDX-FileCopyrightText: 2023 SAP SE
#
# SPDX-License-Identifier: Apache-2.0
#
# This file is part of FEDEM - https://openfedem.org

# A macro for generating source files containing the current date and time.

macro ( date FILE_NAME DIR_NAME )
  if ( WIN32 OR WIN64 )
    execute_process ( COMMAND "Powershell" "get-date -uformat %j" OUTPUT_VARIABLE DAY_RESULT )
    execute_process ( COMMAND "Powershell" "get-date -uformat %y" OUTPUT_VARIABLE YEAR_RESULT )
    execute_process ( COMMAND "Powershell" "get-date -uformat '%d %b %Y %H:%M:%S'" OUTPUT_VARIABLE DATE_RESULT )
  elseif ( UNIX )
    execute_process ( COMMAND "date" "+%j" OUTPUT_VARIABLE DAY_RESULT )
    execute_process ( COMMAND "date" "+%y" OUTPUT_VARIABLE YEAR_RESULT )
    execute_process ( COMMAND "date" "+%e %b %Y %T" OUTPUT_VARIABLE DATE_RESULT )
  else ( WIN32 OR WIN64 )
    set ( DAY_RESULT  "000000" )
    set ( YEAR_RESULT "000000" )
    set ( DATE_RESULT "000000" )
  endif ( WIN32 OR WIN64 )
  string ( REGEX REPLACE "[\n]+" "" DAY_RESULT  ${DAY_RESULT} )
  string ( REGEX REPLACE "[\n]+" "" YEAR_RESULT ${YEAR_RESULT} )
  string ( REGEX REPLACE "[\n]+" "" DATE_RESULT ${DATE_RESULT} )
  string ( REGEX REPLACE "^[0]" " " DATE_RESULT ${DATE_RESULT} )
  file ( WRITE ${DIR_NAME}/${FILE_NAME}_C.h "int build_day = 1${DAY_RESULT}, build_year = 1${YEAR_RESULT};" )
  file ( WRITE ${DIR_NAME}/${FILE_NAME}.h "\"${DATE_RESULT}\"" )
endmacro ( date )
