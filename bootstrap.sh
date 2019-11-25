# Update repositories
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:chris-lea/redis-server -y
sudo apt-get install redis-server -y
sudo systemctl enable redis-server.service
sudo ufw allow 6379
sudo ufw allow 26379


sudo cp '/vagrant/sentinel.conf' '/etc/redis/'