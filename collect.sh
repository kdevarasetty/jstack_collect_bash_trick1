#!/bin/bash
lockfile=/tmp/beelinetest.lock
logfile=/tmp/beelinetest.log
jstack_log=/tmp/jstack.log
if [ -f $lockfile ]; then
  echo $(date +%Y-%m-%d_%H:%M:%S) " ----- lock file exists, exiting" >> $logfile
  exit 1
fi
echo $(date +%Y-%m-%d_%H:%M:%S) > $lockfile
echo $(date +%Y-%m-%d_%H:%M:%S) " ----- test start" >> $logfile
/opt/mapr/hive/hive-2.1/bin/beeline --verbose=true -u jdbc:hive2://localhost:10000 -n mapr -p  mapr -e "select * from testdual" >> $logfile 2>> $logfile & sleep 60
pid=$!
ps aux |grep $pid
kill -0 "$pid"
if [ "$?" -eq 0 ]; then
count=${2:-5} # defaults to 5 times
delay=${3:-3}  # defaults to 2 second
while [ $count -gt 0 ]
do
    jstack -F $pid | awk '{now=strftime("%Y-%m-%d %H:%M:%S "); print now $0}' &>> $jstack_log
    sleep $delay
    let count--
    echo -n "."
done
else
  echo "process not running"
fi
echo $(date +%Y-%m-%d_%H:%M:%S) " ----- test complete" >> $logfile
rm -f $lockfile
