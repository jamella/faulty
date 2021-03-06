#!/bin/bash

# Environment: Firefox
export ASAN_OPTIONS="\
redzone=16:\
check_malloc_usable_size=0:\
replace_intrin=0:\
alloc_dealloc_mismatch=0:\
strict_memcmp=0:\
detect_stack_use_after_return=0:\
max_uar_stack_size_log=17:\
check_initialization_order=1:\
allocator_may_return_null=1:\
strict_init_order=1:\
fast_unwind_on_fatal=1:\
strip_path_prefix=/srv/jenkins/jobs/faulty/workspace/"
export MOZ_LOG=gmp:5
export MOZ_IPC_MESSAGE_LOG=1

# Environment: Faulty
export FAULTY_ENABLE_LOGGING=1
export FAULTY_PROBABILITY=3000
export FAULTY_PICKLE=1
#export FAULTY_PIPE=1
export FAULTY_PARENT=1
#export FAULTY_CHILDREN=0

FIREFOX="firefox/firefox"
PROFILE="faulty-fuzzer"
COMMAND="xvfb-run -e /dev/stdout $FIREFOX -P $PROFILE -no-remote $1 -height 300 -width 300"
TIMEOUT=30
LOGPATH="$HOME/faulty/"`date +"%Y-%m-%d__%H-%M"`
LOGDATE=`date +"%Y-%m-%d__%H-%M-%S"`
LOGFILE="$LOGPATH/faulty-session-$LOGDATE.txt"
mkdir -p $LOGPATH

# Run
$COMMAND 2>&1 | tee $LOGFILE &
sleep $TIMEOUT
pkill -f $PROFILE
pkill -f "/tmp/xvfb-run"

# Package crash results
XZ_OPT=-9e tar cJf testcase-$LOGDATE.tar.xz /root/.local/share/rr/faulty-rr.sh-0
mv testcase-$LOGDATE.tar.xz $LOGPATH
rm -rf /root/.local/share/rr/faulty-rr.sh-0/

# TODO: post $LOGFILE to FuzzManager with accessible link to testcase-$LOGDATE.tar.xz
