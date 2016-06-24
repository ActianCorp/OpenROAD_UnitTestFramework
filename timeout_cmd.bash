#!/bin/bash

# Executes a command with a timeout
#  If no timeout occurs the exit status is the exit status of the command 
#  If the timeout occurs the exit status is 124.
if [ "$#" -lt "2" ]
then
    echo "Usage:   `basename $0` <timeout (in sec)> <command>"
    exit 1
fi

timeout_cleanup()
{
	trap - ALRM
	kill -ALRM $twpid 2>/dev/null
	kill $! 2>/dev/null &&
	exit 124
}

timeout_watcher()
{
	trap "timeout_cleanup" ALRM
	sleep $1 &
	wait
	kill -ALRM $$
}

#start the timeout_watcher subshell
timeout_watcher $1 &
twpid=$!

# Shift the first parameter - was timeout in seconds
shift
#cleanup after timeout
trap "timeout_cleanup" ALRM INT

# Start the actual command, wait for it to finish and save its status
"$@" &
wait $!
RC=$?

#send ALRM signal to timeout_watcher and wait for it to finish cleanup
kill -ALRM $twpid	
wait $twpid

exit $RC

