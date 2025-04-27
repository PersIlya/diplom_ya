

master_extip=$(yc compute instance list | awk '/master/ {print $10}')

ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
# ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip chmod 700 get_helm.sh
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip bash get_helm.sh
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip kubectl create namespace monitoring
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring

ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip rm stable-kube-prometheus-sta-prometheus.yaml
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip 'kubectl get svc stable-kube-prometheus-sta-prometheus -n monitoring -o yaml >> stable-kube-prometheus-sta-prometheus.yaml'
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip sed -i 's/ClusterIP/NodePort/' stable-kube-prometheus-sta-prometheus.yaml
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip kubectl apply -f stable-kube-prometheus-sta-prometheus.yaml -n monitoring

sleep 10
firefox --new-window http:\\$master_extip:`ssh -o StrictHostKeyChecking=no ubuntu@$master_extip kubectl get all -n monitoring | awk '/serv.+sta-prometheus/ {print $5}' | sed -E "s|/TCP.+$||" | sed 's|9090:||'`

ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip rm stable-grafana.yaml
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip 'kubectl get svc stable-grafana -n monitoring -o yaml >> stable-grafana.yaml'
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip sed -i 's/ClusterIP/NodePort/' stable-grafana.yaml
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip kubectl apply -f stable-grafana.yaml -n monitoring

sleep 10
firefox --new-window http:\\$master_extip:`ssh -o StrictHostKeyChecking=no ubuntu@$master_extip kubectl get all -n monitoring | awk '/serv.+grafana/ {print $5}' | grep -Eo "[0-9]{4,6}"`

scp -o "StrictHostKeyChecking=no" *-site.yaml ubuntu@$master_extip:~/
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip kubectl apply -f depl-site.yaml
ssh -o "StrictHostKeyChecking=no" ubuntu@$master_extip kubectl apply -f svc-site.yaml

sleep 10
firefox --new-window http:\\$master_extip:31333
