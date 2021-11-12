```
helm repo add bitnami/external-dns https://charts.bitnami.com/bitnami
helm repo update
helm template external-dns bitnami/external-dns \
  --version 5.4.15 \
  --namespace external-dns \
  --values values.yaml \
  --output-dir base
```
