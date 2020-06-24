# Terraform AWS EKS
Terraform AWS EKS complete build

 Work in Progress -- Do not use!

 ## Setup

Run Terraform:

```
terraform init
terraform apply
```

Set kubectl context to the new cluster: `export KUBECONFIG=kubeconfig_eks-irsa-dev` (or -qa or -prod)

Check that there is a node that is `Ready`:

```
$ kubectl get nodes
NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-255-0-190.us-east-1.compute.internal   Ready    <none>   6m39s   v1.16.1-eks-b8860f
```

Replace `<ACCOUNT ID>` with your AWS account ID in `cluster-autoscaler-chart-values.yaml`. There is output from terraform for this.

Install the chart using the provided values file:

```
helm install --name cluster-autoscaler --namespace kube-system stable/cluster-autoscaler --values=cluster-autoscaler-chart-values.yaml
```

## Verify

Ensure the cluster-autoscaler pod is running:

```
$ kubectl --namespace=kube-system get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler"
NAME                                                        READY   STATUS    RESTARTS   AGE
cluster-autoscaler-aws-cluster-autoscaler-5545d4b97-9ztpm   1/1     Running   0          3m
```

Observe the `AWS_*` environment variables that were added to the pod automatically by EKS:

```
kubectl --namespace=kube-system get pods -l "app.kubernetes.io/name=aws-cluster-autoscaler" -o yaml | grep -A3 AWS_ROLE_ARN

- name: AWS_ROLE_ARN
  value: arn:aws:iam::xxxxxxxxx:role/cluster-autoscaler
- name: AWS_WEB_IDENTITY_TOKEN_FILE
  value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

Verify it is working by checking the logs, you should see that it has discovered the autoscaling group successfully:

```
kubectl --namespace=kube-system logs -l "app.kubernetes.io/name=aws-cluster-autoscaler"

I0128 14:59:00.901513       1 auto_scaling_groups.go:354] Regenerating instance to ASG map for ASGs: [test-eks-irsa-worker-group-12020012814125354700000000e]
I0128 14:59:00.969875       1 auto_scaling_groups.go:138] Registering ASG test-eks-irsa-worker-group-12020012814125354700000000e
I0128 14:59:00.969906       1 aws_manager.go:263] Refreshed ASG list, next refresh after 2020-01-28 15:00:00.969901767 +0000 UTC m=+61.310501783
```
