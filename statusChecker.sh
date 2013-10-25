#!/usr/bin/env bash

# set up working directory
cd ${0%/*}

# load parameters from file
source config.txt

# loop over all IPS/HOSTS
for HOST in "${!HOSTS[@]}"; do

    # ping each $HOST
    if ping -c 10 $HOST > /dev/null; then

        echo "Host $HOST is up on $(date)"

        # if $HOST got fixed, send an email informing the new status
        if [ $(grep -c "$HOST" hostsDown.txt) -eq 1 ]; then

            SUBJECT="Host $HOST is not down anymore. It got fixed."

            # send email to the people in charge of $HOST
            for RECIPIENT in ${HOSTS[$HOST]}; do
                sendEmail -f "$SENDERNAME <$SENDEREMAIL>" -t $RECIPIENT \
                -u $SUBJECT -m $SUBJECT -s $SMTPSERVER -xu $USERNAME -xp $PASSWORD
                sleep 1
            done

            # remove $HOST's name from file
            sed -i "/$HOST/d" hostsDown.txt
        fi

    # if $HOST is down AND the machine that runs this script has a 
    # functional internet connection, then flag $HOST for intervention
    elif ping -c 5 www.google.com > /dev/null; then

        SUBJECT="Host $HOST is down on $(date)."
        echo $SUBJECT

        # if $HOST is down, send an email alerting for the situation
        if [ $(grep -c "$HOST" hostsDown.txt) -eq 0 ]; then

            MESSAGE="$SUBJECT\nPlease act accordingly."

            # send email to the people in charge of $HOST
            for RECIPIENT in ${HOSTS[$HOST]}; do
                sendEmail -f "$SENDERNAME <$SENDEREMAIL>" -t $RECIPIENT \
                -u $SUBJECT -m $MESSAGE -s $SMTPSERVER -xu $USERNAME -xp $PASSWORD
                sleep 1
            done

            # write $HOST's name into file
            echo $HOST >> hostsDown.txt
        fi
    fi
done
