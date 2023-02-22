The lab setup for experimenting with Consul Connect on AWS EKS (EC2)

### 1) Test your AWS CLI credentials:
```
aws sts get-caller-identity
```
### 2) Create an EKS cluster:
```
terraform plan
terraform apply
```
### 3) Set the kubernetes context:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
### 4) Fix IAM for ebs-csi-controller:
```
kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw iam_ebs-csi-controller_role)
kubectl rollout restart deployment ebs-csi-controller -n kube-system
```
### 5) Install Consul:
```
kubectl create namespace consul
kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.4.0"
helm install consul hashicorp/consul --values consul_values.yaml -n consul  --version=0.49.0
```
### 6) Deploy NGINX inside Service Mesh with API GW as an entry point
```
kubectl apply -f nginx-deployment.yaml 
```

In order to find out the ELB FQDNs you can use the following command:
```
aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].[DNSName, ListenerDescriptions[0].Listener.LoadBalancerPort]' --output=text | awk '{print $1":"$2}'
```
Output example:
```
a4f1f722e0c7f4fed8721bafce454d08-1478636051.eu-north-1.elb.amazonaws.com:443
a7a252c22eabc4ab8960e12767cbb2b6-1319286787.eu-north-1.elb.amazonaws.com:30080
```
```443``` port is for Consul UI; ```30080``` port for NGINX

### WARNING! By default SGs assigned to the created ELBs allow incoming connections from ANY address. You might want to limit it to your own IP

### Troubleshooting

If Consul UI shows ```0 upstreams``` for ```nginx-apigw``` service it can be resolved by re-creating the ```httproute```:
```
kubectl delete httproute -n nginx nginx-http-route-1 
kubectl apply -f nginx-deployment.yaml 
```
