#!/bin/bash
##################################################################################################
# VeoErroresOracle.sh : veo si hay errores de Oracle (ORA-*) en el log
##################################################################################################
LOG_ENGINE=/sasbin/config/Lev1/Web/Logs/SASServerX/SASDecisionServicesEngine6.4.log

FILE_AUX_NUEVO=/sasbin/Scripts/Aux_ErroresOracle_nuevo
FILE_AUX_ANTER=/sasbin/Scripts/Aux_ErroresOracle_anter
HOSTNAME=`hostname`
LOG_FILE=`basename ${LOG_ENGINE}`

if [ ! -s ${LOG_ENGINE} ];then
   exit
fi

if [ ! -s $FILE_AUX_ANTER ];then
   > $FILE_AUX_ANTER
fi

grep -E "java.sql.SQLException|java.sql.SQLException:\ ORA-|java.sql.SQLDataException:\ ORA-|RTDMException" ${LOG_ENGINE} | grep -v "Invalid year value" | grep -v "Failure running user groovy activity" > ${FILE_AUX_NUEVO}


DIFERENCIA=`diff ${FILE_AUX_ANTER} ${FILE_AUX_NUEVO} | grep ">" | wc -l `

mv ${FILE_AUX_NUEVO} ${FILE_AUX_ANTER}

if [ ${DIFERENCIA} -eq 0 ];then
   echo "Reseteo alarma,chequeo-log,0"
else
   echo "El equipo ${HOSTNAME} presenta errores en el log. ${LOG_FILE},chequeo-log,1"
fi

##--------------------------------------- Fin script ------------------------------------------##