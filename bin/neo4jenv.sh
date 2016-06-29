# ! /bin/sh
#############################################################
# NAME: neo4jenv.sh
#
# DESC: Configures environment for Neo4j access as required.
#       Note that due to constraints in the hell in regard
#       to environmen variables, the command MUST be prefaced
#       ".", otherwise no permanent change in the user's
#       enviroment can take place
#
# $HeadURL$
# $LastChangedBy$
# $LastChangedDate$
# $LastChangedRevision$
#
# LOG
# yyyy/mm/dd [user]  - [notes]
# 2013/09/10 cgwong  - Created initial version.
# 2014/03/06 cgwong  - v1.1.0 Updated Tomcat variable setup
# 2014/03/28 cgwong  - v1.2.0 Corrected header comment.
#                      Added backup variables.
#############################################################

# Functions
pathman ()
{
# Function used to add non-existent directory (given as argument)
# to PATH variable
  if ! echo ${PATH} | /bin/egrep -q "(^|:)$1($|:)" ; then
    PATH=$1:${PATH} ; export PATH
  fi
}

# Setup Neo4j environment
NEO4J_HOME=/app/neo4j/neo4j ; export NEO4J_HOME

# Setup JRuby environment
JRUBY_HOME=/app/neo4j/jruby ; export JRUBY_HOME

# Neo4j hostname.
NEO4J_HOST=`hostname -f` ; export NEO4J_HOST

# Neo4j environment type. single = Non-Cluster | ha = Cluster/HA
NEO4J_TYPE=ha ; export NEO4J_TYPE

# Cluster members
NEO4J_HA_MEMBERS="neopst01.mydomain.com,neopst02.mydomain.com,neopst03.mydomain.com"; export NEO4J_HA_MEMBERS

# Neo4j environment, i.e. DEV, TST, PST, PRD
NEO4J_ENV=pst ; export NEO4J_ENV

# Neo4j backup port type. This ties back to the online_backup_server setting in the configuration file
# It is exposed here for visibility in the backup script
NEO4J_BKUP_PORT=6362 ; export NEO4J_BKUP_PORT

# Neo4j active backup location
NEO4J_BKUP_DIR=/graphshare/bkups/${NEO4J_ENV} ; export NEO4J_BKUP_DIR

#
# Put new JAVA_HOME in path and remove old one if present
# Ensure that OLD_JAVA_HOME is non-null and use to store current JAVA_HOME if any
OLD_JAVA_HOME=${JAVA_HOME-NOTSET}
JAVA_HOME=/app/neo4j/jdk  ; export JAVA_HOME
case "$PATH" in
  *$OLD_JAVA_HOME*)
    PATH=`echo $PATH | sed "s;${OLD_JAVA_HOME};${JAVA_HOME};g"` ; export PATH ;;
  *)
    pathman $JAVA_HOME/bin ;;
esac

# Setup Apache Tomcat environment
. ~neo4j/bin/TCATenv.sh

pathman $CATALINA_HOME/bin
pathman $NEO4J_HOME/bin
pathman $JRUBY_HOME/bin

# End
