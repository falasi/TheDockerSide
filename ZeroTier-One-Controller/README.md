# README.md
### Note:
This will build a ZeroTier-One controller.

### Build 
```
sudo docker build -t zerotier-controller:1.14.0 .
```
### Run 
```
sudo docker run -d \
  --network host \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --device=/dev/net/tun \
  --name zerotier \
  -p 3000:3000 \
  -p 9993:9993 \
  zerotier-controller:1.14.0
```

### Connect to Web GUI
```
http://IP:3000/
````

### Default ztncui Credentials
User: admin
Password: password

