function cr_start_node() {
  node='{
    "1": {
      "listen_addr": 26257,
      "http_addr": 8080
    },
    "2": {
      "listen_addr": 26258,
      "http_addr": 8081
    },
    "3": {
      "listen_addr": 26259,
      "http_addr": 8082
    }
  }'

  if [ -s "$(brew --prefix)/var/run/cr_node${1}.pid" ]; then
    echo "PIDfile exists; is this node already running?"
    return 1
  fi

  listen_addr=$(echo $node | jq --arg nodenumber "$1" '. | .[$nodenumber] | .listen_addr')
  http_addr=$(echo $node | jq --arg nodenumber "$1" '. | .[$nodenumber] | .http_addr')
  cockroach start \
    --insecure \
    --store="$(brew --prefix)/var/cockroach/node${1}" \
    --listen-addr=localhost:${listen_addr} \
    --http-addr=localhost:${http_addr} \
    --join=localhost:26257,localhost:26258,localhost:26259 \
    --background \
    --pid-file "$(brew --prefix)/var/run/cr_node${1}.pid"
}

function cr_stop_node() {
  PIDFILE="$(brew --prefix)/var/run/cr_node${1}.pid"
  kill -TERM "$(cat "$PIDFILE")" && rm -f "$PIDFILE"
}

function cr_restart_node() {
  echo "Stopping node ${1}"
  cr_stop_node "$1"
  sleep 5
  echo "Starting node ${1}"
  cr_start_node "$1"
}

function cr_start_cluster() {
  # for a new cluster, don't forget: cockroach init --insecure --host=localhost:26257
  cr_start_node 1
  cr_start_node 2
  cr_start_node 3
}

function cr_stop_cluster() {
  cr_stop_node 1
  cr_stop_node 2
  cr_stop_node 3
}
