# plAIground
AI playground with NVIDIA RTX 3090 TI and ollama

run with
```
docker compose up -d
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