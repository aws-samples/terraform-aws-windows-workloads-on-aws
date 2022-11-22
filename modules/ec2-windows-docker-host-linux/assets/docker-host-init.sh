#!/bin/bash -xe
sudo yum update -y
sudo amazon-linux-extras install docker
sed -i 's/dockerd\ \-H\ fd\:\/\//dockerd/g' /lib/systemd/system/docker.service
echo "{\"hosts\": [\"tcp://0.0.0.0:${docker_host_port}\", \"unix:///var/run/docker.sock\"]}" > /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo service docker restart
sudo usermod -a -G docker ec2-user