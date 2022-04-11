#!/bin/sh

VIRT_BIN=${VIRT_BIN-/usr/local/virtuoso-opensource/bin/virtuoso-t}

VIRT_PORT=${VIRT_PORT-1111}
VIRT_UID=${VIRT_UID-dba}
VIRT_PWD=${VIRT_PWD-dba}

ISQL=${ISQL-/usr/local/virtuoso-opensource/bin/isql}

REL_DIR=${VIRT_PROM_REL_DIR-../release}
REL_PACKAGE=$REL_DIR/virt-prom-exporter.vad
VAD_PACKAGE=./vad/virt-prom-exporter.vad

NETSTAT=${NETSTAT_PATH-/usr/bin/netstat}

VAD_DIR=${VAD_DIR-./vad}
DB_DIR=${DB_DIR-./db}
VAD_DIR_SAFETY=VIRT_PROM_TEST_VAD_DIR
DB_DIR_SAFETY=VIRT_PROM_TEST_DB_DIR

CURL=${CURL_PATH-/usr/bin/curl}
PROM_URI=${PROM_URI-http://localhost:8890/metrics}

CHECK_LISTEN()
{
    LISTENING=$($NETSTAT -an 2> /dev/null | grep "[\.\:]$VIRT_PORT " | grep LISTEN)
    
    echo "LISTENING: z$LISTENING"
    
    if [ "z$LISTENING" = z ]
    then
        echo "NOT LISTENING"
        return 1
    else
        echo "LISTENING"
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
    
    if [ ! $? -eq 0 ]
    then
        echo "--- FAILURE Could not stop server."
        exit 1
    fi
    
    exit 0
}

INSTALL_VAD()
{
    $ISQL $SQL_PORT $UID $DBA EXEC="vad_install('$VAD_PACKAGE',0)"
    if [ ! $? -eq 0 ]
    then
        echo "--- FAILURE VAD install"
        return 1
    else
        return 0
    fi
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
        echo "+++ SUCCESS metrics received"
        return 1
    else
        echo "--- FAILURE no metrics received!"
        return 0
    fi
}

FINAL_CLEANUP()
{
    NUKE_DIR $VAD_DIR $VAD_DIR_SAFETY
    NUKE_DIR $DB_DIR $DB_DIR_SAFETY
}

RUN_TESTS()
{
    NUKE_AND_CREATE_DIR $VAD_DIR $VAD_DIR_SAFETY
    NUKE_AND_CREATE_DIR $DB_DIR $DB_DIR_SAFETY
    cp $REL_PACKAGE $VAD_DIR
    
    echo "STARTING TEST at $(date +%Y%m%d%H%M%S)"
    if START_SERVER
    then
        echo "Installing VAD package..."
        INSTALL_VAD
        if [ $? -ne 0 ]
        then
            echo "Cleaning up..."
            STOP_SERVER
            FINAL_CLEANUP
            echo "Over and out"
            exit 1
        fi
        echo "Running tests..."
        TEST_EXPORTER
        result=$?
        echo "Cleaning up..."
        STOP_SERVER
        FINAL_CLEANUP
        echo "Test DONE"
        if [ $result -eq 1 ]
        then
            exit 0
        else
            exit 1
        fi
    else
        echo "--- FAILURE couldn't start server. Cleaning up and exiting."
        FINAL_CLEANUP
        exit 1
    fi
}

RUN_TESTS
