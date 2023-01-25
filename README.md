The lab setup for experimenting with Consul Connect CA on AWS EKS (EC2)

### 1) Create a EKS cluster:
```
terraform plan
terraform apply
```
### 2) Set the kubernetes context:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
### 3) Fix IAM for ebs-csi-controller:
```
kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw iam_ebs-csi-controller_role)
kubectl rollout restart deployment ebs-csi-controller -n kube-system
```
### 4) Install Consul:
```
kubectl create namespace consul
kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.4.0"
helm install consul hashicorp/consul --values consul_values.yaml -n consul  --version=0.49.0
```
### 5) Deploy NGINX inside Service Mesh with API GW as an entry point
```
kubectl apply -f nginx-deployment.yaml 
```
