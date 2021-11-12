#!/bin/bash
# run crabrest service

#==== PARSE ARGUMENTS
helpFunction(){
  echo -e "\nUsage example: ./start.sh -c | -g [-d]"
  echo -e "\t-c start current crabrest instance"
  echo -e "\t-g start crabrest instance from GitHub repo"
  echo -e "\t-d start crabrest in debug mode. Option can be combined with -c or -g"
  exit 1
  }

while getopts ":dDcCgGhH" opt
do
    case "$opt" in
      h|H) helpFunction ;;
      g|G) MODE="fromGH" ;;
      c|C) MODE="current" ;;
      d|D) debug=true ;;
      * ) echo "Unimplemented option: -$OPTARG"; helpFunction ;;
    esac
done

if ! [ -v MODE ]; then
  echo "Please set how you want to start crabrest (add -c or -g option)." && helpFunction
fi

#==== SETUP ENVIRONMENT
if [ "$debug" = true ]; then
  # this will direct WMCore/REST/Main.py to run in the foreground rather than as a demon
  # allowing among other things to insert pdb calls in the crabrest code and debug interactively
  export DONT_DAEMONIZE_REST=True
  # this will start crabrest with only one thread (default is 25) to make it easier to run pdb
  export CRABSERVER_THREAD_POOL=1
fi

if [ "$MODE" = fromGH ]; then
  export RUN_FROM_GH=True
fi

#==== START THE SERVICE
export CRYPTOGRAPHY_ALLOW_OPENSSL_102=true
/data/srv/current/config/crabrest/manage start 'I did read documentation'
