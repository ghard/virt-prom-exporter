#!/bin/sh

VIRT_BIN=${VIRT_BIN-/usr/local/virtuoso-opensource/bin/virtuoso-t}

VIRT_PORT=${VIRT_PORT-1111}
VIRT_UID=${VIRT_UID-dba}
VIRT_PWD=${VIRT_PWD-dba}
VIRT_HTTP_PORT=${VIRT_HTTP_PORT-8890}
ISQL=${ISQL-/usr/local/virtuoso-opensource/bin/isql}

REL_DIR=${VIRT_PROM_REL_DIR-../release}
VAD_PACKAGE_NAME=virt-prom-exporter
REL_PACKAGE=$REL_DIR/$VAD_PACKAGE_NAME.vad
VAD_PACKAGE=./vad/$VAD_PACKAGE_NAME.vad
VAD_PACKAGE_VERSION=1.0

NETSTAT=${NETSTAT_PATH-/usr/bin/netstat}

VAD_DIR=${VAD_DIR-./vad}
DB_DIR=${DB_DIR-./db}
VAD_DIR_SAFETY=VIRT_PROM_TEST_VAD_DIR
DB_DIR_SAFETY=VIRT_PROM_TEST_DB_DIR

CURL=${CURL_PATH-/usr/bin/curl}
PROM_URI=${PROM_URI-http://localhost:$VIRT_HTTP_PORT/metrics}

SUCC_CNT=0
FAIL_CNT=0

TEST_REPORT_FSPEC=test_report.org

CHECK_LISTEN()
{
    LISTENING=$($NETSTAT -an 2> /dev/null | grep "[\.\:]$VIRT_PORT " | grep LISTEN)
    
    if [ "z$LISTENING" = z ]
    then
        echo "Virtuoso not listening"
        return 1
    else
        return 0
    fi
}

START_SERVER()
{
    $VIRT_BIN +wait
    
    if CHECK_LISTEN
    then
        return 0
    else
        return 1
    fi
}

STOP_SERVER()
{
    $ISQL $VIRT_PORT $VIRT_UID $VIRT_PWD EXEC="shutdown()"
}

INSTALL_VAD()
{
    $ISQL $VIRT_PORT $VIRT_UID $VIRT_PWD EXEC="vad_install('$VAD_PACKAGE',0)"
}

UNINSTALL_VAD()
{
    $ISQL $VIRT_PORT $VIRT_UID $VIRT_PWD EXEC="vad_uninstall('$VAD_PACKAGE_NAME/$VAD_PACKAGE_VERSION')"
}

NUKE_DIR()
{
    if [ $# -lt 2 ]
    then
        echo "$FUNCNAME missing parameters."
        echo "Usage: \n\t$FUNCNAME path safety_file"
        exit 1
    else
        if [ -d $1 ]
        then
            if [ -f $1/$2 ]
            then
                rm -rf $1
            else
                echo "$FUNCNAME: Refusing to NUKE existing dir $1 - missing safety file $2"
                exit 1
            fi
        fi
    fi
}

NUKE_AND_CREATE_DIR()
{
    if [ $# -lt 2 ]
    then
        echo "$FUNCNAME missing parameters"
        echo "Usage: \n\t$FUNCNAME path indicator"
    else
        NUKE_DIR $1 $2
        mkdir $1
        touch $1/$2
    fi
}

TEST_EXPORTER()
{
    $CURL $PROM_URI 2> /dev/null | grep sys_stat_db_pages > /dev/null
    if [ $? -eq 0 ]
    then
        echo "*** Metrics received."
        return 0
    else
        echo "*** No metrics received!"
        return 1
    fi
}

TEST_EXPORTER_MISSING()
{
    $CURL -I $PROM_URI 2> /dev/null | grep "HTTP/1.1 404" >/dev/null
    if [ $? -eq 1 ]
    then
        echo "*** Whoa! Metrics endpoint is still there!"
        return 1
    else
        echo "*** Metrics are gone. Good."
        return 0
    fi
}


NUKE_TEST_DIRS()
{
    NUKE_DIR $VAD_DIR $VAD_DIR_SAFETY
    NUKE_DIR $DB_DIR $DB_DIR_SAFETY
}

INC_FAIL_CNT()
{
    FAIL_CNT=$(($FAIL_CNT+1))
}

DEC_FAIL_CNT()
{
    SUCC_CNT=$(($SUCC_CNT+1))
}

INIT_TEST_REPORT()
{
    >$TEST_REPORT_FSPEC
    echo "* VIRT_PROM_EXPORTER TEST REPORT" >> $TEST_REPORT_FSPEC
    echo "" >> $TEST_REPORT_FSPEC
    echo "Date: $(date +%Y%m%d%H%M%S)" >> $TEST_REPORT_FSPEC
    echo "Host: $(hostname)" >> $TEST_REPORT_FSPEC
    echo "" >> $TEST_REPORT_FSPEC
    echo "| Result  | Test                                         |" >> $TEST_REPORT_FSPEC
    echo "|---------|----------------------------------------------|" >> $TEST_REPORT_FSPEC
}

ADD_TEST_REPORT()
{
    echo "| $1 | $2 |" >> $TEST_REPORT_FSPEC
}

COUNT_SUCC_FAIL()
{
    if [ $1 -ne 0 ]
    then
        echo "--- FAIL $2"
        ADD_TEST_REPORT "FAIL   " "$2"
        INC_FAIL_CNT
        return 1
    else
        echo "+++ SUCCESS $2"
        ADD_TEST_REPORT "SUCCESS" "$2"
        DEC_FAIL_CNT
        return 0
    fi
}

REPORT_RESULTS()
{
    if [ $FAIL_CNT -gt 0 ]
    then
        echo "\n*****************************"
        echo "*** FAILED TESTS REPORTED ***"
        echo "*****************************\n"
    else
        echo "\n***********************"
        echo "*** TEST SUCCESSFUL ***"
        echo "***********************\n"
    fi
    
    echo "\nFINISHED test with $SUCC_CNT SUCCESSFUL, $FAIL_CNT FAILED" >> $TEST_REPORT_FSPEC
    echo "*** Test report available - see $TEST_REPORT_FSPEC\n"
}

RUN_TESTS()
{
    NUKE_AND_CREATE_DIR $VAD_DIR $VAD_DIR_SAFETY
    NUKE_AND_CREATE_DIR $DB_DIR $DB_DIR_SAFETY
    cp $REL_PACKAGE $VAD_DIR


    INIT_TEST_REPORT
    echo "*** STARTING TEST at $(date +%Y%m%d%H%M%S)"
    echo "*** Starting server..."
    START_SERVER
    COUNT_SUCC_FAIL $? "START server"
    if [ $? -eq 0 ]
    then
        echo "*** Installing VAD package..."
        INSTALL_VAD
        COUNT_SUCC_FAIL $? "VAD install"
        if [ $? -ne 0 ]
        then
            echo "*** Cleaning up..."
            STOP_SERVER
            COUNT_SUCC_FAIL $? "STOP server"
            NUKE_TEST_DIRS
            REPORT_RESULTS
            exit 1
        fi
        echo "*** START TEST RUN..."
        TEST_EXPORTER
        COUNT_SUCC_FAIL $? "Check for metrics availability"
        UNINSTALL_VAD
        COUNT_SUCC_FAIL $? "VAD package uninstall"
        TEST_EXPORTER_MISSING
        COUNT_SUCC_FAIL $? "Metrics endpoint gone after VAD uninstall"
        STOP_SERVER
        COUNT_SUCC_FAIL $? "STOP Server"
        NUKE_TEST_DIRS
        REPORT_RESULTS
        if [ $FAIL_CNT -eq 0 ]
        then
            exit 0
        else
            exit 1
        fi
    else
        echo "--- FAIL couldn't start server. Cleaning up and exiting."
        INC_FAIL_CNT
        ADD_TEST_REPORT FAIL "Start Virtuoso server"
        NUKE_TEST_DIRS
        REPORT_RESULTS
        exit 1
    fi
}

RUN_TESTS
