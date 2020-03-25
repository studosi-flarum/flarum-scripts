#!/bin/bash

#   Copyright 2020 Studosi
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

############################################################
#   VARIABLES                                              #
############################################################

#   Can be on of the following: "apache", "nginx"
STUDOSI_WEB_SERVER="apache"

#   Can be one of the following: "7.1", "7.2", "7.3", "7.4"
STUDOSI_PHP_VERSION="7.1"

STUDOSI_DB_NAME="flarum"
STUDOSI_DB_USERNAME="micho"
STUDOSI_DB_PASSWORD="123"

STUDOSI_FLARUM_ROOT=""

############################################################
#   CONSTANTS (don't mess with this!)                      #
############################################################

STUDOSI_OLD_PHP_WARNING="You've selected an older version of PHP, which may affect your forum's performance and be deprecated in the future."

STUDOSI_DIRECTORY_MISSING="The given folder doesn't exist!"

############################################################
#   HELPER FUNCTIONS                                       #
############################################################

prompt_web_server()
{
    while [[ ! ${STUDOSI_WEB_SERVER,,} =~ ^(a(pache)?|n(ginx)?)$ ]]
    do
        read -p "Web server ([a]pache|[n]ginx): " STUDOSI_WEB_SERVER
    done
    
    STUDOSI_WEB_SERVER=${STUDOSI_WEB_SERVER:0:1}
    STUDOSI_WEB_SERVER=${STUDOSI_WEB_SERVER,,}
    
    if [[ $STUDOSI_WEB_SERVER == "a" ]]
    then
        _web_server_to_print="apache"
    elif [[ $STUDOSI_WEB_SERVER == "n" ]]
    then
        _web_server_to_print="nginx"
    else
        _web_server_to_print="UNKNOWN"
    fi
        
    printf "\nUsing ${_web_server_to_print} web server.\n\n\n"
}

prompt_php_version()
{
    if [[ ! ${STUDOSI_PHP_VERSION} =~ ^7\.[1-4]$ ]]
    then
        while [[ 1 ]]
        do
            read -p "PHP version: (7.1-7.4): " STUDOSI_PHP_VERSION

            if [[ ! ${STUDOSI_PHP_VERSION} =~ ^7\.[1-4]$ ]]
            then
                continue
            fi

            _php_sub_version=${STUDOSI_PHP_VERSION:2:1}

            if [[ $_php_sub_version -lt "4" ]]
            then
                echo ""
                echo $STUDOSI_OLD_PHP_WARNING;
                _old_php_answer=""

                while [[ ! ${_old_php_answer,,} =~ ^(y(es)?|no?)$ ]]
                do
                    read -p "Are you sure you want to do this ([y]es|[n]o): " _old_php_answer
                done

                _old_php_answer=${_old_php_answer:0:1}
                _old_php_answer=${_old_php_answer,,}

                if [[ $_old_php_answer == "y" ]]
                then
                    break
                else
                    echo ""
                fi
            else
                break
            fi
        done
    fi
    
    printf "\nUsing PHP $STUDOSI_PHP_VERSION.\n\n\n"
}

prompt_db_credentials()
{
    while [[ ! $STUDOSI_DB_NAME =~ ^[a-z0-9_]+$ ]]
    do
        read -p "Database name: " STUDOSI_DB_NAME
    done
    
    while [[ ! $STUDOSI_DB_USERNAME =~ ^[a-z0-9_]+$ ]]
    do
        read -p "Username for ${STUDOSI_DB_NAME}: " STUDOSI_DB_USERNAME
    done
    
    while [[ ! $STUDOSI_DB_PASSWORD =~ ^[a-z0-9_]+$ ]]
    do
        read -sp "Password for ${STUDOSI_DB_NAME}: " STUDOSI_DB_PASSWORD
    done
    
    printf "\n\nDatabase name: ${STUDOSI_DB_NAME}\n"
    printf "Using username ${STUDOSI_DB_USERNAME}.\n\n\n"
}

prompt_flarum_root()
{
    while [[ 1 ]]
    do
        read -p "Flarum root directory (empty for /var/www/html/flarum): " STUDOSI_FLARUM_ROOT
        
        if [[ $STUDOSI_FLARUM_ROOT == "" ]]
        then
            STUDOSI_FLARUM_ROOT="/var/www/html/flarum"
        fi
        
        if [[ ! -d $STUDOSI_FLARUM_ROOT ]]
        then
            echo $STUDOSI_DIRECTORY_MISSING
            _create_flarum_root=""
            
            while [[ ! ${_create_flarum_root,,} =~ ^(y(es)?|no?)$ ]]
            do
                read -p "Do you want to create ${STUDOSI_FLARUM_ROOT} ([y]es|[n]o): " _create_flarum_root
            done
            
            _create_flarum_root=${_create_flarum_root:0:1}
            _create_flarum_root=${_create_flarum_root,,}

            if [[ $_create_flarum_root == "y" ]]
            then
                echo "Making ${STUDOSI_FLARUM_ROOT}"
                # mkdir $STUDOSI_FLARUM_ROOT
            else
                echo ""
            fi
        fi
        
        if [[ "$(ls -A $STUDOSI_FLARUM_ROOT)" ]]
        then
            print "\nDirectory ${STUDOSI_FLARUM_ROOT} is not empty!"
            continue
        else
            break
        fi
    done
}

############################################################
#   FUNCTIONALITY                                          #
############################################################

prompt_web_server
prompt_php_version
prompt_db_credentials