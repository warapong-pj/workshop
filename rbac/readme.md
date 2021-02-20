# Deploy certificate signing requests to kubernetes  
1. openssl req -new -newkey rsa:4096 -nodes -keyout developer.key -out developer.csr -subj "/CN=developer/O=engineer"
2. kubectl apply -f csr.yml
3. kubectl certificate approve developer

# Create kubeconfig
1. kubectl get csr developer -o jsonpath='{.status.certificate}' | base64 --decode > developer.crt
2. kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > k8s-ca.crt
3. kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=developer-config --embed-certs
4. kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --embed-certs --kubeconfig=developer-config
5. kubectl config set-context developer --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=default --user=developer --kubeconfig=developer-config
6. kubectl config use-context developer --kubeconfig=developer-config
7. kubectl version --kubeconfig=developer-config
