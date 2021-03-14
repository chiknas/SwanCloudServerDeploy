# SwanCloudServerDeploy on a Raspberry Pi 4

Instructions on how to use this project with a Raspberry Pi.

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
