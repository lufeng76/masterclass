#!/usr/bin/bash

## for prepping a 1-node cluster for the governance masterclass

sudo yum -y -q install git
cd
curl -sSL https://raw.githubusercontent.com/seanorama/ambari-bootstrap/master/extras/deploy/install-ambari-bootstrap.sh | bash
source ~/ambari-bootstrap/extras/ambari_functions.sh

${__dir}/deploy/prep-hosts.sh

export ambari_services="YARN ZOOKEEPER TEZ OOZIE FLUME PIG SLIDER MAPREDUCE2 HIVE HDFS FALCON ATLAS SQOOP"
"${__dir}/deploy/deploy-hdp.sh"
sleep 30

source ${__dir}/ambari_functions.sh
source ~/ambari-bootstrap/extras/ambari_functions.sh; ambari-change-pass admin admin BadPass#1
echo "export ambari_pass=BadPass#1" > ~/ambari-bootstrap/extras/.ambari.conf; chmod 660 ~/ambari-bootstrap/extras/.ambari.conf
source ${__dir}/ambari_functions.sh
ambari-configs
ambari_wait_request_complete 1

## Generic setup
sudo chkconfig mysqld on; sudo service mysqld start
${__dir}/add-trusted-ca.sh
${__dir}/onboarding.sh
#${__dir}/ambari-views/create-views.sh
config_proxyuser=true ${__dir}/ambari-views/create-views.sh
#${__dir}/samples/sample-data.sh
${__dir}/configs/proxyusers.sh
${__dir}/ranger/prep-mysql.sh
proxyusers="oozie" ${__dir}/configs/proxyusers.sh
## centos6 only #${__dir}/oozie/replace-mysql-connector.sh

mirror_host="${mirror_host:-mc-teacher1.$(hostname -d)}"
mirror_host_ip=$(ping -w 1 ${mirror_host} | awk 'NR==1 {print $3}' | sed 's/[()]//g')
echo "${mirror_host_ip} mirror.hortonworks.com ${mirror_host} mirror admin admin.hortonworks.com" | sudo tee -a /etc/hosts

## Governance specific setup
sudo usermod -a -G hadoop admin
sudo mkdir -p /app; sudo chown ${USER}:users /app; sudo chmod g+wx /app
${__dir}/atlas/atlas-hive-enable.sh
proxyusers="falcon flume" ${__dir}/configs/proxyusers.sh
proxyusers="falcon flume" ${__dir}/oozie/proxyusers.sh
${__dir}/falcon/bugfix_oozie-site_elexpression.sh
${ambari_config_set} oozie-site   oozie.service.AuthorizationService.security.enabled "false"

${ambari_config_set} capacity-scheduler yarn.scheduler.capacity.root.default.maximum-am-resource-percent 0.5
${ambari_config_set} capacity-scheduler yarn.scheduler.capacity.maximum-am-resource-percent 0.5
${ambari_config_set} yarn-site yarn.scheduler.minimum-allocation-mb 250
#${ambari_config_set} yarn-site yarn.scheduler.maximum-allocation-mb 8704
${ambari_config_set} yarn-site "yarn.resourcemanager.webapp.proxyuser.hcat.groups"  "*"
${ambari_config_set} yarn-site "yarn.resourcemanager.webapp.proxyuser.hcat.hosts" "*"
${ambari_config_set} yarn-site "yarn.resourcemanager.webapp.proxyuser.oozie.groups" "*"
${ambari_config_set} yarn-site "yarn.resourcemanager.webapp.proxyuser.oozie.hosts" "*"
${ambari_config_set} yarn-site yarn.scheduler.minimum-allocation-vcores 1

##### atlas client tutorial
## install atlas client
curl -ssLO https://github.com/seanorama/atlas/releases/download/0.1/atlas-client.tar.bz2
sudo yum -y -q install bzip2
tar -xf atlas-client.tar.bz2
sudo mv atlas-client /opt
sudo ln -sf /opt/atlas-client/bin/atlas-client /usr/local/bin/
sudo touch /application.log /audit.log; sudo chown ${USER} /application.log /audit.log

## setup source DRIVERS & TIMESHEET database in MySQL
git clone https://github.com/seanorama/atlas
cd atlas/tutorial
mysql -u root < MySQLSourceSystem.sql
####




## setup falcon churn demo

mkdir /tmp/falcon-churn; cd /tmp/falcon-churn
curl -sSL -O http://hortonassets.s3.amazonaws.com/tutorial/falcon/falcon.zip
unzip falcon.zip
sudo su - hdfs -c "hadoop fs -mkdir -p /shared/falcon/demo/primary/processed/enron; hadoop fs -chmod -R 777 /shared"
sudo sudo -u admin hadoop fs -copyFromLocal demo /shared/falcon/
sudo sudo -u hdfs hadoop fs -chown -R admin:hadoop /shared/falcon
sudo sudo -u hdfs hadoop fs -chmod -R g+w /shared/falcon



### temporary, for Falcon in HDP 2.3.0-2557
#hdp_version="$(hdp-select status falcon-server | awk '{print $3}')"
#if [[ ${hdp_version} == '2.3.0.0-2557' ]]; then
    #cd /usr/hdp/current/falcon-server/webapp/
    #backup_dir="backup_$(date +%F-%T)"
    #falcon_run="sudo sudo -u falcon HADOOP_HOME=/usr/hdp/current/hadoop-client"
    #${falcon_run} ../bin/falcon-stop
    #${falcon_run} mkdir ${backup_dir}
    #${falcon_run} mv falcon falcon.war "${backup_dir}"
    #${falcon_run} curl -sSL -o falcon.war "https://www.dropbox.com/s/962jw6ja03j1tpy/falcon-dal-m10-preview.war?dl=1"
    #${falcon_run} ../bin/falcon-start -port 15000
    #sleep 20
    #cd
#fi
## 



## restart services
myhost=$(hostname -f)
read -r -d '' body <<EOF
{"RequestInfo":{"command":"RESTART","context":"Restart all components on ${myhost}","operation_level":{"level":"HOST","cluster_name":"${ambari_cluster}"}},"Requests/resource_filters":[{"service_name":"YARN","component_name":"APP_TIMELINE_SERVER","hosts":"${myhost}"},{"service_name":"ATLAS","component_name":"ATLAS_SERVER","hosts":"${myhost}"},{"service_name":"HDFS","component_name":"DATANODE","hosts":"${myhost}"},{"service_name":"FALCON","component_name":"FALCON_CLIENT","hosts":"${myhost}"},{"service_name":"FALCON","component_name":"FALCON_SERVER","hosts":"${myhost}"},{"service_name":"FLUME","component_name":"FLUME_HANDLER","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"HCAT","hosts":"${myhost}"},{"service_name":"HDFS","component_name":"HDFS_CLIENT","hosts":"${myhost}"},{"service_name":"MAPREDUCE2","component_name":"HISTORYSERVER","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"HIVE_CLIENT","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"HIVE_METASTORE","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"HIVE_SERVER","hosts":"${myhost}"},{"service_name":"HDFS","component_name":"JOURNALNODE","hosts":"${myhost}"},{"service_name":"MAPREDUCE2","component_name":"MAPREDUCE2_CLIENT","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"MYSQL_SERVER","hosts":"${myhost}"},{"service_name":"HDFS","component_name":"NAMENODE","hosts":"${myhost}"},{"service_name":"YARN","component_name":"NODEMANAGER","hosts":"${myhost}"},{"service_name":"OOZIE","component_name":"OOZIE_CLIENT","hosts":"${myhost}"},{"service_name":"OOZIE","component_name":"OOZIE_SERVER","hosts":"${myhost}"},{"service_name":"PIG","component_name":"PIG","hosts":"${myhost}"},{"service_name":"YARN","component_name":"RESOURCEMANAGER","hosts":"${myhost}"},{"service_name":"HDFS","component_name":"SECONDARY_NAMENODE","hosts":"${myhost}"},{"service_name":"SLIDER","component_name":"SLIDER","hosts":"${myhost}"},{"service_name":"SQOOP","component_name":"SQOOP","hosts":"${myhost}"},{"service_name":"TEZ","component_name":"TEZ_CLIENT","hosts":"${myhost}"},{"service_name":"HIVE","component_name":"WEBHCAT_SERVER","hosts":"${myhost}"},{"service_name":"YARN","component_name":"YARN_CLIENT","hosts":"${myhost}"},{"service_name":"ZOOKEEPER","component_name":"ZOOKEEPER_CLIENT","hosts":"${myhost}"},{"service_name":"ZOOKEEPER","component_name":"ZOOKEEPER_SERVER","hosts":"${myhost}"}]}
EOF
response=$(echo "${body}" | ${ambari_curl}/clusters/${ambari_cluster}/requests -X POST -d @-)
request_id=$(echo ${response} | python -c 'import sys,json; print json.load(sys.stdin)["Requests"]["id"]')
ambari_wait_request_complete ${request_id}



hdp_version="$(hdp-select status falcon-server | awk '{print $3}')"
if [[ ${hdp_version} == '2.3.0.0-2557' ]]; then
    falcon_dir=/usr/hdp/current/falcon-server/
    backup_dir="backup_$(date +%F-%T)"
    falcon_run="sudo sudo -u falcon HADOOP_HOME=/usr/hdp/current/hadoop-client"
    ${falcon_run} ${falcon_dir}/bin/falcon-stop
    cd ${falcon_dir}/webapp
    ${falcon_run} mkdir ${backup_dir}
    sudo cp -a falcon ${backup_dir}
    ${falcon_run} curl -sSL -o falcon-ui.tar.gz "https://www.dropbox.com/s/zb1odoe4n1e1m8d/falcon-ui.tar.gz?dl=1"
    cd falcon
    ${falcon_run} tar -xf ../falcon-ui.tar.gz
    ${falcon_run} ${falcon_dir}/bin/falcon-start -port 15000
fi