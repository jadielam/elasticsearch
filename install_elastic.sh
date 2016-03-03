#Be sure to run the script as the root user.

#1. Install Java
echo 'Installing java'
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jre-8u60-linux-x64.rpm"

yum -y localinstall jre-8u60-linux-x64.rpm
yum -y install unzip

#2. Performing operations that I will not be able to perform as non-root.
#2.1 Giving permission to elastic search to prevent memory from being swapped.
echo 'Preventing swap memory issue'
ulimit -l unlimited

#2.2 Increasing the number of open file descriptors that are allowed on the machine
#running elasticsearch
echo 'Increasing number of open file descriptors allowed'
sysctl -w fs.file-max=64000
echo 'fs.file-max = 64000' >> /etc/sysctl.conf

#2.3 Allowing more limits on mmap counts
echo 'Allowing higher limit on mmap counts'
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf

#2.4 Opening ports on firewall
echo 'Opening ports 9200, 9300 and 5601 in firewall'
iptables -A INPUT -m state --state NEW -p tcp --dport 9200 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 9300 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 5601 -j ACCEPT
/etc/init.d/iptables restart

#3. Create elastic user name
#3.1 Create group
echo 'Creating elastic user'
groupadd elastic

#3.2 Create username
useradd -g elastic elastic

#4. Setup elastic search
#4.1. Download elasticsearch
echo 'Downloading elasticsearch'
ES_HOME=/home/elastic/elasticsearch-2.0.0
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/2.0.0/elasticsearch-2.0.0.zip
mv elasticsearch-2.0.0.zip /home/elastic
cd /home/elastic
rm -rf elasticsearch-2.0.0
unzip elasticsearch-2.0.0.zip

#4.2 Setting up the Elasticsearch environment.
echo 'Setting up elasticsearch environment'
ip=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ES_HEAP_SIZE=8g
echo 'ES_HEAP_SIZE=8g' >> ~/.bashrc
rm -f ${ES_HOME}/config/elasticsearch.yml
touch ${ES_HOME}/config/elasticsearch.yml
echo 'bootstrap.mlockall: true' >> ${ES_HOME}/config/elasticsearch.yml
echo 'cluster.name: Cluster' >> ${ES_HOME}/config/elasticsearch.yml
echo "node.name: ${HOSTNAME}" >> ${ES_HOME}/config/elasticsearch.yml
echo "network.host: ${ip}" >> ${ES_HOME}/config/elasticsearch.yml
echo 'network.bind_host: 0' >> ${ES_HOME}/config/elasticsearch.yml
echo 'discovery.zen.ping.multicast.enabled: false' >> ${ES_HOME}/config/elasticsearch.yml
echo 'discovery.zen.ping.unicast.hosts: ["192.168.0.2", "192.168.0.3"]' >> ${ES_HOME}/config/elasticsearch.yml

#4.3 Installing the marvel plugin
#IMPORTANT: This plugin needs a license in order to be used
#in production servers.
${ES_HOME}/bin/plugin install license
${ES_HOME}/bin/plugin install marvel-agent

#5. Changing ownership of folder.
chown -R elastic:elastic ${ES_HOME}

#6. Running the server
su elastic -c "${ES_HOME}/bin/elasticsearch"
