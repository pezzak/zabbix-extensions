#/usr/bin/env bash

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

METRIC=$1

test ! -z $METRIC || { echo "ZBX_NOTSUPPORTED, metric param must be specified."; exit 1; }

case $METRIC in
    'discover')

        KEEPALIVED_CONF=$2
        test -f $KEEPALIVED_CONF || { echo "ZBX_NOTSUPPORTED, $KEEPALIVED_CONF doesn't exist" ; exit 1; }
        ADDRESSES=$(sed -n -e '/virtual_ipaddress {/,/}/p' $KEEPALIVED_CONF |grep -v ^# |awk '{print $1}' |grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}*')

        echo -n '{"data":['
        for addr in $ADDRESSES; do echo -n "{\"{#KADDR}\": \"$addr\"},"; done |sed -e 's:\},$:\}:'
        echo -n ']}'

        ;;
    'availability')

        IP_ADDR=$2
        test ! -z $IP_ADDR || { echo "ZBX_NOTSUPPORTED, $IP_ADDR doesn't exist" ; exit 1; }
        test -f $(which ip 2>/dev/null) || { echo "ZBX_NOTSUPPORTED, ip utility from iproute2 not found."; exit 1; }
        if ip addr show |grep -qo $IP_ADDR; then echo 1; else echo 0; fi

        ;;
    *)
        echo "Wrong metric"
        exit 0
        ;;
esac


