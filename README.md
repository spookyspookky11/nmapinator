# nmapinator
Nmapinator is a bash script which takes a list of ip addresses, runs masscan on them, extracts live hosts, runs nmap on the live hosts, and passes the nmap output to the ultimate-nmap-parser. A successful attempt will show a summary.txt file in the directory you ran the script.

Instructions for use:
```
git clone https://github.com/spookyspookky11/nmapinator.git 
cd nmapinator/
chmod +x nmapinator.sh
sudo ./nmapinator.sh 
```
