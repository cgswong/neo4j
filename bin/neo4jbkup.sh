#!/bin/bash
######################################################
# NAME: neo4jbkup.sh
#
# DESC: Runs backup of Neo4j.
#
# $HeadURL: http://svn01/global_infrastructure/neo4j-repo/neo4jbkup.sh $
# $LastChangedBy: cgwong $
# $LastChangedDate: 2014-04-09 10:34:27 -0500 (Wed, 09 Apr 2014) $
# $LastChangedRevision: 14 $
#
# LOG:
# yyyy/mm/dd [user] - [notes]
# 2014/03/28 cgwong - [v1.0.0] Creation.
# 2014/04/03 cgwong - [v1.0.1] Updated log file directory variable.
#                     Updated header with SVN substitution variables.
# 2014/04/08 cgwong - [v1.0.2] Added log file redirection and backup message.
######################################################

SCRIPT=`basename $0`
SCRIPT_PATH=$(dirname $SCRIPT)
SETUP_FILE=~neo4j/bin/neo4jenv.sh

. ${SETUP_FILE}

# -- Variables -- #
PID=$$
PID_FILE=${NEO4J_BKUP_DIR}/neo4jbkup.lck
LOGFILE=${NEO4J_BKUP_DIR}/`echo ${SCRIPT} | awk -F"." '{print $1}'`.log
ERR=1     # Error status
SUC=0     # Success status

# -- Functions -- #
msg ()
{ # Print message to screen and log file
  # Valid parameters:
  #   $1 - function name
  #   $2 - Message Type or status
  #   $3 - message
  #
  # Log format:
  #   Timestamp: [yyyy-mm-dd hh24:mi:ss]
  #   Component ID: [compID: ]
  #   Process ID (PID): [pid: ]
  #   Host ID: [hostID: ]
  #   User ID: [userID: ]
  #   Message Type: [NOTE | WARN | ERROR | INFO | DEBUG]
  #   Message Text: "Metadata Services: Metadata archive (MAR) not found."

  # Variables
  TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`
  [[ -n $LOGFILE ]] && echo -e "[${TIMESTAMP}],PRC: ${1},PID: ${PID},HOST: $TGT_HOST,USER: ${USER}, STATUS: ${2}, MSG: ${3}" | tee -a $LOGFILE
}

show_usage ()
{ # Show script usage
  echo "
 ${SCRIPT} - Linux shell script to run Neo4j backup. Utilizes the setup
  file ${SETUP_FILE} to configure the run environment. This script can be
  run from a central location or from each member of the cluster provided
  that there is a shared file system which can serve to store a lock file.
  This lock file (${PID_FILE}) provides information as to which node is
  the active backup node. A typical cronjob can be used as the resource to
  run the job.
  
 USAGE
 ${SCRIPT} [OPTION]
 
 OPTION
  -h
    Display this help screen.    
"
}

# -- MAIN -- #
# Check for lock file and create with relevant information if it does not
if [ ! -f ${PID_FILE} ]; then
  echo "${SCRIPT} PID: ${PID}" > ${PID_FILE}
  echo "Active backup node: ${NEO4J_HOST}" > ${PID_FILE}
  if [ "$NEO4J_TYPE" == "ha" ]; then    # Check if cluster or not and backup accordingly
    # Process cluster members and format for backup command string
    # We assume that the port for backup is consistent among all hosts
    for members in `echo $NEO4J_HA_MEMBERS | cut -d',' -f1- --output-delimiter=$'\n'`; do
      if [ -z $HA_MEMBERS ]; then
        HA_MEMBERS="$members:${NEO4J_BKUP_PORT}"
      else
        HA_MEMBERS="${HA_MEMBERS},$members:${NEO4J_BKUP_PORT}"
      fi
    done
    msg MAIN INFO "Running HA cluster instance backup."
    ${NEO4J_HOME}/bin/neo4j-backup -from ${NEO4J_TYPE}://${HA_MEMBERS} -to ${NEO4J_BKUP_DIR} &>>${LOGFILE}
    [ $? -gt 0 ] && msg MAIN ERROR "Backup failed, check log ${LOGFILE} for details." || msg MAIN INFO "Backup completed successfully, check log ${LOGFILE} for details."
  else
    msg MAIN INFO "Running single instance backup."
    ${NEO4J_HOME}/bin/neo4j-backup -from ${NEO4J_TYPE}://${NEO4J_HOST}:${NEO4J_BKUP_PORT} -to ${NEO4J_BKUP_DIR} &>>${LOGFILE}
    [ $? -gt 0 ] && msg MAIN ERROR "Backup failed, check log ${LOGFILE} for details." || msg MAIN INFO "Backup completed successfully, check log ${LOGFILE} for details."
  fi
  rm -f ${PID_FILE}
  exit $?
else
  msg MAIN WARN "Lock file found, backup in process on another node. Check ${PID_FILE} for details."
  exit ${ERR}
fi

# End