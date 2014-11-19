#!/bin/sh
#
# deploy.sh: Idempotent script deploying a Docker-experiment
#

set -e

install_packages () {
    while [ $# -ne 0 ] ; do
        if [ -e /usr/share/doc/"$1" ] ; then
            printf 'Package already installed: %s\n' "$1" >&2
            shift
        else
            yum install -y "$@"
            break
        fi
    done
}

install_script () {
    SCRIPT=/usr/local/bin/"$1"
    printf "Installing %s...\n" "$SCRIPT" >&2
    cat > "$SCRIPT"
    chmod 755 "$SCRIPT"
}

install_script redeploy <<'EOF'
#!/bin/sh
sudo sh /vagrant/deploy.sh
EOF

yum update -y

install_packages \
    docker-io \
    git

chkconfig docker on

service docker start

cd /vagrant/dist
docker build -t vagrant/centos-node-hello .
docker run -d -p 8080:80 -v /var/run/docker.sock:/tmp/docker.sock jwilder/nginx-proxy
docker run -p 49161:8080 -e VIRTUAL_HOST=hello100.localhost -v /dev/log:/dev/log -d vagrant/centos-node-hello
docker run -p 49162:8080 -e VIRTUAL_HOST=hello101.localhost -v /dev/log:/dev/log -d vagrant/centos-node-hello
