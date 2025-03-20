# auto-4works
Not an opensource. Just built for myself




## Thay doi duong dan cho cac docker-images
sudo gedit /etc/docker/daemon.json

{
  "data-root": "/mnt/shares/docker-images"
}


Stop all the containers
  `docker stop $(docker ps -a -q)`

Remove all the containers
  `docker rm $(docker ps -a -q)`