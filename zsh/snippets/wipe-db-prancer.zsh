wipe-db-prancer() {
  # optionally, pass the dump file to use
  # default uses dbs/develop.dmp
  readonly dumpfile=~/prancer/dbs/${1:?develop}.dmp.gz
  echo "Using dump file $dumpfile"
  unsetopt pushdignoredups
  # optionally, pass a prancer version suffix to use as directory to switch to
  # (or . to not switch directory)
  # default uses ~/prancer
  if [[ "$2" == "." ]]; then
    prancer_dir=.
  else
    prancer_dir="$HOME/prancer/${2:-develop}"
  fi
  if [ ! -f "$dumpfile" ]; then
    echo "File $dumpfile does not exist!"
    return 1
  fi
  pushd $prancer_dir
  docker compose stop backend celery celery-beat db-builder && \
    docker compose exec db psql -U prancer -d postgres -c 'drop database if exists prancer with (force)' && \
    docker compose exec db psql -U prancer -d postgres -c 'create database prancer' && \
    gunzip -c $dumpfile | docker compose exec -T db psql -U prancer -d prancer && \
    docker compose up -d && \
    docker compose logs -f db-builder
  popd
}
