# Install Linkerd
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin
linkerd version
linkerd check --pre
linkerd install | kubectl apply -f - 
linkerd check

# Install Flagger
helm repo add flagger https://flagger.app
kubectl create namespace linkerd
kubectl apply -f https://raw.githubusercontent.com/fluxcd/flagger/main/artifacts/flagger/crd.yaml
helm upgrade -i flagger flagger/flagger \
  --namespace=linkerd \
  --set crd.create=false \
  --set meshProvider=linkerd \
  --set metricsServer=http://linkerd-prometheus:9090

# Create demo app namespace
kubectl create namespace test
kubectl annotate namespace test linkerd.io/inject=enabled

# Install Flagger loadtester
kubectl apply -k https://github.com/fluxcd/flagger//kustomize/tester?ref=main --namespace test

# Install demo app - Podinfo
kubectl apply -k https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main --namespace test

# Check current image version
echo "Current image is $(kubectl --namespace test get deployment podinfo -o=jsonpath='{.spec.template.spec.containers[0].image}')"