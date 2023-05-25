#!/bin/bash -

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

proc_net_parser $1
