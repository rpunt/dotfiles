alias cr_start_single='cockroach start-single-node --store=$(brew --prefix)/var/cockroach/single --http-port=26256 --insecure --host=localhost'

function cr_start_n1() {
  cockroach start --insecure --store="$(brew --prefix)/var/cockroach/node1" --listen-addr=localhost:26257 --http-addr=localhost:8080 --join=localhost:26257,localhost:26258,localhost:26259 --background --pid-file "$(brew --prefix)/var/run/cr_node1.pid"
}
function cr_start_n2() {
  cockroach start --insecure --store="$(brew --prefix)/var/cockroach/node2" --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257,localhost:26258,localhost:26259 --background --pid-file "$(brew --prefix)/var/run/cr_node2.pid"
}
function cr_start_n3() {
  cockroach start --insecure --store="$(brew --prefix)/var/cockroach/node3" --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257,localhost:26258,localhost:26259 --background --pid-file "$(brew --prefix)/var/run/cr_node3.pid"
}

function cr_start_cluster() {
  cr_start_n1
  cr_start_n2
  cr_start_n3
  # for a new cluster, don't forget: cockroach init --insecure --host=localhost:26257
}

function cr_stop_cluster() {
  for pidfile in $(ls `brew --prefix`/var/run/cr_node*.pid 2>/dev/null); do
    echo "$pidfile"
    kill -TERM $(cat "$pidfile")
    rm -f "$pidfile"
  done
}
