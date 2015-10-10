#!/bin/bash
#
# This script tests OpenROAD functionality.
#   It has to be run in an OpenROAD environment (II_SYSTEM, PATH, etc. should be set)
#   Ingres/Net and OR Server should  be running.
#   The parameter passed is the database (incl. vnode) used for the tests.
# USAGE:
#        or_tests.bash <dbname>
#

# -----------------------------------------------------------------------------
# Function TEST_CLEANUP
#   This function performs the cleanup (deletion of files) and exit of the script.
#   Parameter passed is the exit code to be returned to the shell.
# ------------------------------------------------------------------------------
TEST_CLEANUP()
{
    return_code=$1
    if [ -d $TESTDIR ]
    then
        cd $TESTDIR
        rm -f *.xml *.img
    fi
    exit $return_code
}

TEST_CHECKCMD()
{
# -----------------------------------------------------------------------------
# Function TEST_CHECKCMD
#   First parameter passed is the return code of the last command executed.
#   Second parameter passed is the expected return code.
#   Third parameter:
#       Y: Indicates an error is deemed as critical
#       N: Any errors are reported, but not as critical
#   Remaining parameters give a brief description of what the command was doing.
# ------------------------------------------------------------------------------
   h_clf_return_code=$1
   shift

   h_clf_return_code_expected=$1
   shift

   h_clf_critical=$1
   shift

   h_clf_command=$*

   if [ $h_clf_return_code -ne $h_clf_return_code_expected ]
   then
      printf "++ ERROR ++\n%s\n" "$h_clf_command"
      printf "+++ Status Code: expected: %s, actual: %s\n\n" $h_clf_return_code_expected $h_clf_return_code

      if [ "$h_clf_critical" = "Y" ]
      then
         if [ -f $TESTDIR/test.log ]
         then
            printf "\nw4gl log file:\n\n"
            cat $TESTDIR/test.log
         fi
         TEST_CLEANUP 1
      else
          ((rv++))
      fi
   fi

   return 0
}

# -----------------------------------------------------------------------------
#       Main execution
# -----------------------------------------------------------------------------

rv=0

cd $(dirname $0)
export SCRIPTDIR=`pwd`

if [ $# -lt 1 ]
then
    printf "USAGE:\n\t$0 <dbname> [<testno>]\n\n"
    exit 1
fi
if [ -z "$1" ]
then
    printf "Empty <dbname> supplied!\n\n"
    exit 1
fi
export TESTDB=$1
if [ -z "$2" ]
then
    export TESTNO=$(date +"%y%m%d%H%M%S")
else
    export TESTNO=$2
fi

export TESTDIR=$SCRIPTDIR/tests/test${TESTNO}

echo '\q' | tm -S $TESTDB
TEST_CHECKCMD $? 0 "Y" "Unable to connect to ${TESTDB}"

chmod 644 *.xml unittests/*.xml
mkdir -p $TESTDIR
TEST_CHECKCMD $? 0 "Y" "Unable to create test directory $TESTDIR"
cp $SCRIPTDIR/*.xml $TESTDIR
TEST_CHECKCMD $? 0 "Y" "Unable to copy XML files into test directory $TESTDIR"
cd $TESTDIR
TEST_CHECKCMD $? 0 "Y" "Unable to change to test directory $TESTDIR"

export II_LOG=.
export II_W4GL_EXPORT_INDENTED=TRUE
unset II_W4GL_EXPORT_COMMENT


printf "\nOR Unit tests:\n Using logfile $TESTDIR/orunittest.log ...\n\n"

rm -f *.xml
cp ${SCRIPTDIR}/unittests/*.xml .
TEST_CHECKCMD $? 0 "Y" "Unable to copy unittests XML files into test directory $TESTDIR"

rc=0

w4gldev backupapp in ${TESTDB} UnitTestFramework UnitTestFramework.xml -nreplace -xml -nowindows -Lorunittest.log -Tyes,logonly
if [ $? -ne 0 ]
then
    printf "\nUnable to import application UnitTestFramework into ${TESTDB}.\n"
    TEST_CLEANUP 1
fi

for utxml in $(ls *.xml | grep -v "^UnitTestFramework\.xml")
do
    utapp=$(basename $utxml .xml)
    w4gldev backupapp in ${TESTDB} $utapp $utxml -nreplace -xml -nowindows -Lorunittest.log -Tyes,logonly -A
    rv1=$?
    if [ $rv1 -eq 0 ]
    then
        printf " ${utapp}: ... "
        w4gldev rundbapp ${TESTDB} $utapp -nowindows -Lorunittest.log -Tyes,logonly -A
        if [ $? -eq 0 ]
        then
            printf "OK.\n"
        else
            printf "FAILED.\n"
            ((rc++))
        fi
    else
        printf " ${utapp}: Import of application FAILED.\n"
        ((rc++))
    fi
done

if [ $rc -ne 0 ] || [ $rv -ne 0 ]
then
   printf "\nOR Tests completed. ERROR(s) encountered in %s non-critical command line test(s) and %s unit test(s).\n" $rv $rc
   TEST_CLEANUP 1
else
    printf "\nOR Tests successfully executed.\n"
fi

TEST_CLEANUP $rv

