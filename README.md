# plAIground
AI playground with NVIDIA RTX 3090 TI and ollama

run with
```
docker compose up -d
```
to check logs run
```
docker compose logs -f
```

# cleanup
If you are running docker in WSL2 it's better to use bind-mounts outside the wsl-VM.
If the VM-Image grows due multiple builds you can try to cleanup docker
```
docker system prune -a --volumes
```
and in a powershell
shutdown the WSL-VM
```
wsl --shutdown
```
and shrink the image (path must be changed)
```
Optimize-VHD -Path "$env:USERPROFILE\\AppData\\Local\\Packages\\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\\LocalState\\ext4.vhdx" -Mode Full
```

or you can move the vm-disk to another drive
```
wsl --shutdown
wsl --manage Ubuntu --move d:\wsl
```

# setup Windows Subsystem for Linux (WSL)
https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker
```

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

run wsl-portproxy.cmd to expose ports to your LAN (otherwise you can only use localhost)