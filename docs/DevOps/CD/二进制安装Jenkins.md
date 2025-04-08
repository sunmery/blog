https://www.jenkins.io/doc/book/installing/war-file/

```shell
# --config
JENKINS_HOME="/mnt/data/158-jenkins"

mkdir -p ${JENKINS_HOME}/war
mkdir -p ${JENKINS_HOME}/plugins
mkdir -p ${JENKINS_HOME}/lib
echo > ${JENKINS_HOME}/logs.log 

JENKINS_HOME="/mnt/data/158-jenkins" \
java -jar \
--webroot=${JENKINS_HOME}/war
--pluginroot=${JENKINS_HOME}/plugins
--logfile=${JENKINS_HOME}/logs.log
--httpPort=9090
jenkins.war
```

基本:

```shell
nohup sh -c \
'JENKINS_HOME="/mnt/data/158-jenkins" \
java -jar jenkins.war --httpPort=9090' \
&
```
