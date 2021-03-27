# How to secure linux server

## Automatic Updates

- Download unattended-upgrades package
  `sudo apt install unattended-upgrades`

- Configure to auto install updates by running this command and hit yes
  `sudo dpkg-reconfigure --priority=low unattended-upgrades`

## Passwords are for suckers

1. Create .ssh folder and change permission to allow access
   `mkdir ~/.ssh && chmod 700 ~/.ssh`

2. Generate key pair. When asked for a path save it in your .ssh folder. (Windows)
   `ssh-keygen -b 4096`

3. Upload the public key to your server's ~/.ssh/authorized_keys file. (Windows Powershell)
   `scp $env:USERPROFILE/.ssh/<keyname that you used>.pub <username>@<server ip>:~/.ssh/authorized_keys`

4. Login using your private key. You dont need to specify the path to the key if you didnt set a custom name for it.
   `ssh <username>@<server ip> -i <path to private key>`

## Lockdown Logins

1. Open ssh config file `sudo nano /etc/ssh/sshd_config`

2. Update the following settings

- Port=any other port other than 22
- AddressFamily=inet (allow only ipv4 addresses)
- PermitRootLogin=no
- PasswordAuthentication=no
- PermitEmptyPasswords=no

3. Restart SSH daemon `sudo systemctl restart sshd`

## Firewall

1. Install UFW(Unclomplicated FireWall) to easily setup our poop
   `sudo apt install ufw`
   `sudo ufw status` check status command. it will be inactive

2. Allow all ports we are interested in. Dont forget our custom ssh port and webhook port
   `sudo ufw allow <port>`
   `sudo ufw allow 443/tcp`

3. Enable firewall `sudo ufw enable`

## Block pings

1. Open up ufw before.rules file `sudo nano /etc/ufw/before.rules`

2. Look for # ok icmp codes for INPUT and append this line below:
   `-A ufw-before-input -p icmp --icmp-type echo-request -j DROP`
