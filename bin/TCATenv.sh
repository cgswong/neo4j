# ! /bin/sh
#############################################################
# NAME: TCATenv.sh
#
# DESC: Configures environment for Apache Tomcat access as required.
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
# 2014/04/06 cgwong  - Created initial version.
#############################################################

CATALINA_BASE=/app/www/tomcat             ; export CATALINA_BASE
CATALINA_HOME=$CATALINA_BASE              ; export CATALINA_HOME
CATALINA_PID="$CATALINA_BASE/tomcat.pid"  ; export CATALINA_PID
JRE_HOME=$JAVA_HOME/jre                   ; export JRE_HOME

# End
