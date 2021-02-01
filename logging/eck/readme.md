# Install CRD
kubectl apply -f https://download.elastic.co/downloads/eck/1.3.1/all-in-one.yaml  

# Get elastic password
kubectl get secret logging-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo  

# How to send log to Logstash
```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: app
  annotations:
    kubernetes.io/ingress.class: "kong"
    konghq.com/plugins: "eck"
spec:
  rules:
  - host: app.demo.local
    http:
      paths:
      - path: /
        backend:
          serviceName: app
          servicePort: 80
```