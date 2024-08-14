get_id() {
    input=$@
    instance=$(aws ec2 describe-instances \
      --output json \
      --region us-west-2 \
      --filter "Name=private-ip-address,Values=$input" \
      --query 'Reservations[].Instances[]' | jq '.[0]')
    instance_id=$(echo $instance | jq -r '.InstanceId')
    crdb_cluster_name=$(echo $instance | jq -r '.Tags[] | select(.Key == "crdb_cluster_name") | .Value')
    node_id=$(echo $instance | jq -r '.Tags[] | select(.Key == "node_id") | .Value')
    jq -n \
      --arg instance_id "$instance_id" \
      --arg crdb_cluster_name "$crdb_cluster_name" \
      --arg node_id "$node_id" \
      '{instance_id: $instance_id, crdb_cluster_name: $crdb_cluster_name, node_id: $node_id}'
}

get_ip() {
    input=$@
    instance=$(aws ec2 describe-instances \
      --output json \
      --region us-west-2 \
      --filter "Name=instance-id,Values=$input" \
      --query 'Reservations[].Instances[]' | jq '.[0]')
    private_ip=$(echo $instance | jq -r '.NetworkInterfaces[].PrivateIpAddress')
    crdb_cluster_name=$(echo $instance | jq -r '.Tags[] | select(.Key == "crdb_cluster_name") | .Value')
    node_id=$(echo $instance | jq -r '.Tags[] | select(.Key == "node_id") | .Value')
    jq -n \
      --arg private_ip "$private_ip" \
      --arg crdb_cluster_name "$crdb_cluster_name" \
      --arg node_id "$node_id" \
      '{private_ip: $private_ip, crdb_cluster_name: $crdb_cluster_name, node_id: $node_id}'
}
