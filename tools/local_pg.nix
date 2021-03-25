{ writeScriptBin, postgresql_12 }:
writeScriptBin "local_pg" ''
  export PGHOST=$PWD/tmp/postgres
  export PGDATA=$PGHOST/data
  export PGDATABASE=postgres
  export PGLOG=$PGHOST/postgres.log

  function start_pgsql {
    mkdir -p $PGHOST
    if [ ! -d $PGDATA ]; then
      ${postgresql_12}/bin/initdb --auth=trust --no-locale --encoding=UTF8
    fi
    if ! ${postgresql_12}/bin/pg_ctl status
    then
      ${postgresql_12}/bin/pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST' --listen_addresses='''"
    fi
  }

  function stop_pgsql {
    echo "stopping server"
    ${postgresql_12}/bin/pg_ctl stop
  }

  case $1 in
    "start")
      start_pgsql;;
    "stop")
      stop_pgsql;;
    *)
      echo "local_pg start | stop"
      ;;
  esac
''
