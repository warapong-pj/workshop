# How to install istioctl
1. curl -sL https://istio.io/downloadIstioctl | sh -
2. export PATH=$PATH:$HOME/.istioctl/bin
3. istioctl operator init --watchedNamespaces default

# auto inject sidecars
kubectl label namespace default istio-injection=enabled --overwrite

# Uninstall istio
1. kubectl label namespace default istio-injection-
2. kubectl delete istiooperators.install.istio.io -n istio-system poc
3. istioctl operator remove
4. istioctl manifest generate | kubectl delete -f -
5. kubectl delete ns istio-system --grace-period=0 --force