# proc_net_parser for /proc/net/tcp[udp]
Transform **`/proc/net/tcp[udp]`** to human readable format in .csv file

Based on the script **`Ruan Tannhäuser`** [**here**](https://medium.com/@tannhauser.sphinx/bash-linux-networking-transform-proc-net-tcp-to-human-readable-format-d85863eca208)

## Some changes script of Ruan Tannhäuser
* Display of errors is hidden for those versions of `awk` where there is no parameter `--version`
* Added display of `UID` value
* Added the ability to specify an arbitrary .txt file in the `/proc/net/tcp[udp]` format
* Other minor changes

## Why is it needed
Immediately I can name at least two purposes of use this Bash-script:
* Using a script in `docker` containers where there are no commands like:
	* netstat
	* ss
* Using a script for `LFI` (Local File Inclusion) vulnerability purposes. When we have the ability to read files on the host, we can try to read the `/proc/net/tcp[udp]` file, save it to a separate file and pass it to the input of the script in order to see open ports with the `UID` of the users under which the processes are running. Useful for pentesting, CTF, etc.

## Install and run
There are two possibilities to install the script:
1. Standardly use like any other Bash-script
2. Add the `proc_net_parser()` function to your `.bashrc` file

Let's take a look at each installation and use method in turn.
 
Run the `proc_net_parser.sh` as like a regular Bash-script:
``` 
$ ./proc_net_parser.sh /proc/net/tcp
ID,Source,Destination,Status,UID
0,127.0.0.1:7337,0.0.0.0:0,TCP_LISTEN,1001
1,127.0.0.1:50505,0.0.0.0:0,TCP_LISTEN,0
2,127.0.0.1:34391,0.0.0.0:0,TCP_LISTEN,1000
3,127.0.0.1:33060,0.0.0.0:0,TCP_LISTEN,130
4,127.0.0.1:631,0.0.0.0:0,TCP_LISTEN,0
5,127.0.0.1:3306,0.0.0.0:0,TCP_LISTEN,130
```
You can also save the output to a .csv file:
```
$ ./net_parser.sh /proc/net/tcp > out.csv
$ head out.csv 
ID,Source,Destination,Status,UID
0,127.0.0.1:7337,0.0.0.0:0,TCP_LISTEN,1001
1,127.0.0.1:50505,0.0.0.0:0,TCP_LISTEN,0
2,127.0.0.1:34391,0.0.0.0:0,TCP_LISTEN,1000
3,127.0.0.1:33060,0.0.0.0:0,TCP_LISTEN,130
4,127.0.0.1:631,0.0.0.0:0,TCP_LISTEN,0
5,127.0.0.1:3306,0.0.0.0:0,TCP_LISTEN,130
6,127.0.0.1:3001,0.0.0.0:0,TCP_LISTEN,1
7,0.0.0.0:8000,0.0.0.0:0,TCP_LISTEN,1000
8,0.0.0.0:3790,0.0.0.0:0,TCP_LISTEN,0
```
Suppose we have a .txt file which contains data in `/proc/net/tcp` format:
```
$ head proc_net_tcp.txt
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                                     
   0: 0100007F:8124 00000000:0000 0A 00000000:00000000 00:00000000 00000000   109        0 32352 1 0000000000000000 100 0 0 10 0                     
   1: 0100007F:9997 00000000:0000 0A 00000000:00000000 00:00000000 00000000  1001        0 2038837 1 0000000000000000 100 0 0 10 0                   
   2: 0100007F:A365 00000000:0000 0A 00000000:00000000 00:00000000 00000000  1001        0 2039636 1 0000000000000000 100 0 0 10 0                   
   3: 0100007F:1388 00000000:0000 0A 00000000:00000002 00:00000000 00000000    33        0 32941 3 0000000000000000 100 0 0 10 0                     
   4: 3500007F:0035 00000000:0000 0A 00000000:00000000 00:00000000 00000000   102        0 29909 1 0000000000000000 100 0 0 10 5                     
   5: 0100007F:15B3 00000000:0000 0A 00000000:00000000 00:00000000 00000000  1001        0 32408 1 0000000000000000 100 0 0 10 0                     
   6: 0100007F:0CEA 00000000:0000 0A 00000000:00000000 00:00000000 00000000   109        0 32362 1 0000000000000000 100 0 0 10 0                     
   7: 00000000:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 32834 2 0000000000000000 100 0 0 10 0                     
   8: 00000000:0016 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 32822 1 0000000000000000 100 0 0 10 0 
```
In this case, we can also pass it to the script:
```
$ ./net_parser.sh /home/nikn0laty/proc_net_tcp.txt | head
ID,Source,Destination,Status,UID
0,127.0.0.1:33060,0.0.0.0:0,TCP_LISTEN,109
1,127.0.0.1:39319,0.0.0.0:0,TCP_LISTEN,1001
2,127.0.0.1:41829,0.0.0.0:0,TCP_LISTEN,1001
3,127.0.0.1:5000,0.0.0.0:0,TCP_LISTEN,33
4,127.0.0.53:53,0.0.0.0:0,TCP_LISTEN,102
5,127.0.0.1:5555,0.0.0.0:0,TCP_LISTEN,1001
6,127.0.0.1:3306,0.0.0.0:0,TCP_LISTEN,109
7,0.0.0.0:80,0.0.0.0:0,TCP_LISTEN,0
8,0.0.0.0:22,0.0.0.0:0,TCP_LISTEN,0
```
Consider an alternative installation option via the `.bashrc` file:
1. In your `.bashrc` file, you need to add the function `proc_net_parser()` itself to the end, like this:
```bash
proc_net_parser() {
    if [ $# -ne 0 ]
    then
        awk $([[ $(awk --version 2> /dev/null) = GNU* ]] && echo --non-decimal-data) '
            function hex2addr(hex) {
                split(hex, data, ":");
                l = length(data[1]);
                dec_ip = sprintf("%d", "0x" substr(data[1], l - 1, 2));
                for(i = 1; i < 4; i++){
                    dec_ip = sprintf("%s.%d", dec_ip, "0x" substr(data[1], l - (i * 2 + 1), 2))
                };
                return sprintf("%s:%d", dec_ip, "0x" data[2]);
            }
            {
                if ($1 == "sl") {
                    printf "ID,Source,Destination,Status,UID\n";
            } else {
                split($1, conn, ":");
                src = hex2addr($2);
                dst = hex2addr($3);
                status_str = "TCP_ESTABLISHED,TCP_SYN_SENT,TCP_SYN_RECV,TCP_FIN_WAIT1,TCP_FIN_WAIT2,TCP_TIME_WAIT,TCP_CLOSE,TCP_CLOSE_WAIT,TCP_LAST_ACK,TCP_LISTEN,TCP_CLOSING,TCP_NEW_SYN_RECV,TCP_MAX_STATES";
                split(status_str, status, ",");
                status_index = sprintf("%d", "0x" $4)
                uid = $8
                printf("%d,%s,%s,%s,%s\n", conn[1], src, dst, status[status_index], uid);
            }
        }' $1
    else
        echo "--[proc_net_parser for /proc/net/tcp]--"
        echo "Please specify a file, for example: ./proc_net_parser.sh /proc/net/tcp";
  fi
}
```
2. Restart your terminal
3. Use the function like this (in fact, everything is the same, just do not specify the name of the script file):
```
$ proc_net_parser /proc/net/tcp | head 
ID,Source,Destination,Status,UID
0,127.0.0.1:7337,0.0.0.0:0,TCP_LISTEN,1001
1,127.0.0.1:50505,0.0.0.0:0,TCP_LISTEN,0
2,127.0.0.1:34391,0.0.0.0:0,TCP_LISTEN,1000
3,127.0.0.1:33060,0.0.0.0:0,TCP_LISTEN,130
4,127.0.0.1:631,0.0.0.0:0,TCP_LISTEN,0
5,127.0.0.1:3306,0.0.0.0:0,TCP_LISTEN,130
6,127.0.0.1:3001,0.0.0.0:0,TCP_LISTEN,1
7,0.0.0.0:8000,0.0.0.0:0,TCP_LISTEN,1000
8,0.0.0.0:3790,0.0.0.0:0,TCP_LISTEN,0
```
