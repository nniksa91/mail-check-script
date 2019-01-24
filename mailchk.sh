#!/bin/bash


case "$1" in

        -q|queue)

        echo; echo "Exim Mail Queue: " ; exim -bpc ;echo; echo "Mails in queue per sender: " ; exim -bp | exiqsumm ;echo;

        ;;

        -sm|--specific-mail)

        read -p "Please enter the email address which you want to search through the logs? " email_addr;

        ##### Email Address that was queried
        echo;echo -e "Email address: $email_addr";echo ;

        ##### Listing last 10 Email ID's
        echo; echo -e "Last 10 Email message ID's"; echo ; grep $email_addr /var/log/exim_mainlog | awk '{print $3}'| sort | uniq -c | awk '{print $2}';

        ##### Checking through ID's from above and checking warnings and if they are completed
        echo;echo -e "Checking for warnings in last 10 email ID's"; for i in $(grep $email_addr /var/log/exim_mainlog | awk '{print $3}'); do exigrep $i /var/log/exim_mainlog ; done | egrep "Warning|Completed";


        ##### Listin Last 10 Email entries from EXIM
        echo;echo -e "Last 10 email from Exim Main Log";echo ;grep $email_addr /var/log/exim_mainlog |tail ;

        ;;

        -spmr|--spam--repeating)

        #### Checking for spam on a server

        #### Checking for emails that are repeating in queue
        for i in `exim -bp | grep \< | grep -v "<>" | awk '{print $3}'`; do echo -n "Message ID: $i | "; exim -Mvh $i | grep auth_id | tr -d '\n'; echo -n ' | ';exim -Mvh $i | grep -w "Subject:" | cut -c 4-; done | grep auth_id;

        ;;

        -spmscr|--spam--script)

        #### Checking for Scripts that are spamming
        echo ; echo -e " Checking for scripts which are potentially spamming " ; echo;
        grep cwd /var/log/exim_mainlog | grep -v /var/spool | awk -F"cwd=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail -10 ;

        #### Checking for spam scripts through the logs
          echo ; echo -e "Checking the logs for scripts that were previously spamming" ; echo;
         zgrep "cwd=/home" /var/log/exim_mainlog* | awk '{for(i=1;i<=10;i++){print $i}}' | sort | uniq -c | grep cwd | sort -n

        ;;

        #### Possible login credentials breach
        
        -blogin|--breached--login)

        ##### Checking for the logins over authenticated sources
        
        echo ; echo -e "Checking for the logins";echo;
        cat /var/log/exim_mainlog | egrep -o 'dovecot_login[^ ]+' | cut -d: -f2 | sort | uniq -c | sort -n;

        ;;

esac

        
