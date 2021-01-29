# Install CRD
kubectl apply -f https://download.elastic.co/downloads/eck/1.3.1/all-in-one.yaml  

# Get elastic password
kubectl get secret logging-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo  