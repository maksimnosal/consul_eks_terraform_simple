### 1 Create a EKS cluster:

```
terraform plan
terraform apply
```

### 2 Set the kubernetes context:

```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### 3 Fix IAM for ebs-csi-controller:

```
kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw iam_ebs-csi-controller_role)
kubectl rollout restart deployment ebs-csi-controller -n kube-system
```

### 4 Install Consul:

```
helm install consul hashicorp/consul -n consul --create-namespace
```
