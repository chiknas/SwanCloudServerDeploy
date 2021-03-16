# SwanCloudServerDeploy on a Raspberry Pi

Instructions on how to use this project with a Raspberry Pi. This has been tested on a Raspberry Pi 4 and Raspbian Lite OS.

## Setup Docker

Follow the [official how to](https://docs.docker.com/engine/install/debian/) install docker on a debian based linux distro.

### Run docker with no sudo

1. Add the Docker group if it doesn’t already exist: `sudo groupadd docker`

2. Add the connected user “$USER” to the docker group. Change the user name to match your preferred user if you do not want to use your current user:
   `sudo gpasswd -a $USER docker`

3. Logout and log back in again

## Mount external usb drive

1. Find the drive in the system to make sure it is read

2. Install exfat driver (or the required driver for the usb drive under FSTYPE above)
   `sudo apt install exfat-fuse`

3. Linux and Raspbian don’t use drive letters. Instead they use folders mapped under a /mnt parent folder. To create a new mount point under the /mnt folder you must make a new subfolder like this:
   `sudo mkdir /mnt/<the mount name>`

4. Now that you have a new mount point setup, you can map the external SSD to it. Since the lsblk command showed that the device is seen as /dev/sda1, the command should be:
   `sudo mount /dev/sda1(or the proper path) /mnt/<the mount name>`

### Setup auto mounting on reboot

If you reboot or shutdown the Pi, the external SSD won’t be remounted when you restart it. To automatically mount the external SSD on startup, do the following.

5. Get the PARTUUID of the external drive: `blkid | grep sda1`

6. Open fstab file: `sudo nano /etc/fstab`

7. Paste in this line, replacing the PARTUUID with your external drives value returned by the blkid command:
   `PARTUUID=4#######-01 /mnt/xdisk exfat defaults,auto,users,rw,nofail,x-systemd.device-timeout=30,umask=000 0 0`

## SSL Certificate with Certbot

1. Install Certbot to get certificates for the server from Lets Encrypt.
   `sudo apt-get install certbot`

2. Ask [Lets Encrypt](https://letsencrypt.org/) for a new certificate to the server. Make sure the server is down and ports 80/443 are forwarded.
   `sudo certbot certonly --standalone -d <domain goes here>`

3. The new certificate exists in `/etc/letsencrypt/live/<domain goes here>/fullchain.pem` with its key in `/etc/letsencrypt/live/<domain goes here>/privkey.pem`. Use command to convert it to .p12 format to be used by our app
   `sudo openssl pkcs12 -export -out swancloudcert.p12 -in /etc/letsencrypt/live/<domain goes here>/fullchain.pem -inkey /etc/letsencrypt/live/<domain goes here>/privkey.pem -passout pass: -name "swancloud"`

4. Give cert read permissions: `sudo chmod +r swancloudcert.p12`

## Crontab example to refresh server (and cert)

The example below will refresh the server and the certificate if we are in SSL mode monthly.

1. open roots crontab: `sudo crontab -e`
2. append:
   `0 0 1 * * cd /home/pi/SwanCloudServerDeploy && ./swan-cloud-server-deploy.sh -k "'apiKey1'" -p /mnt/samsung -t arm32v7 -s -d example.com`
