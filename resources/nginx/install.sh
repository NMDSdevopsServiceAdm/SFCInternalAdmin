yum install docker
chkconfig docker on
service docker start
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir -p /local/docker/data/nginx
cd /local/docker
