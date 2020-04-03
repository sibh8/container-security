# Container Security: Hands On
A hands on guide for Trivy, Kube-hunter and Tracee.

## Assumptions
1. Ensure that latest version of Oracle Virtual Box and Vagrant is installed
2. Ensure that internet access is available for downloading/installing packages
3. The user has basic knowledge of docker, Kubernetes and minikube

## Part 0
### Prep the environment.
1. Clone the repository
2. Navigate the the container-security folder
3. Edit the file server_config.yaml to modify the compute and netwoek CIDR
4. Execute the below command to startup the VM
```
vagrant up
```
5. Enter in the VM using the following command
```
vagrant ssh
```
6. In order to perform the operations, please login as root in the container-security VM using the below command
```
sudo -i
```
7. If any problems are faced, delete the VM using the below command
```
vagrant destroy -f
```

### Common issues faced while interacting with Vagrant and Virtual Box
- Usually vagrant with Virtual Box users face the issue while spinning up the VM : vboxsf is not available
To get around this issue, execute the following command on the vagrant host
```
vagrant plugin install vagrant-vbguest
```

## Part 1 - Trivy (https://github.com/aquasecurity/trivy)

### Installing Trivy
Trivy is installed as a part of container-security VM

#### First let's get a summary
```
trivy ubuntu:18.04 | grep Total
```
#### Let's look at the total list now 
```
trivy ubuntu:18.04 
```
#### Get the crtical vulnerabilities
```
trivy -s CRITICAL --ignore-unfixed ubuntu:18.04
```
### Get the total from other Linux Distros
```
trivy centos:7.6.1810 | grep Total
```
```
trivy debian:10.2-slim | grep Total
```

### Let's take a quick look at the latest alpine base image to compare
```
trivy alpine:3.11
```

##### Notes:
Trivy could produce inconsistent results based on local caching if latest or non-specific tags are used


## Part 2 Kube-hunter (remote) (https://github.com/aquasecurity/kube-hunter)

#### Accessing the minikube kubeconfig
1. Login into minikube using the below command
```
minikube ssh
```
2. Copy the contents of the file ~/.kube/config and paste it in home directory in container-security VM as minikube-config-<K8S-VERSION>.yaml. This will be referred as <CON-SEC-HOME> directory for future references.

#### Installing kubectl and updating the KubeConfig to access the cluster
1. Kubectl is installed as a part of the container-security VM.
2. Before executing below commands, please replace the placeholders <CON-SEC-HOME> and <K8S-VERSION>
```
export KUBECONFIG=<CON-SEC-HOME>/minikube-config-<K8S-VERSION>.yaml
```
### Install kube-hunter by cloning the git repo
kube-hunter repository is already cloned in the container-security VM

## Part 2.1
##### CHANGE the job’s metadata
1. Navigate to the ``` <CON-SEC-HOME>/kube-hunter ``` in the container-security VM
2. In order to add an argument --quick as shown below, execute the command
```
cat job.yaml | sed 's/\["--pod"\]/\["--pod","--quick"\]/' | sed "s/name: kube-hunter/name: $USER-kubehunter/" > job1.yaml
```
It is to be noted that --quick argument limits the network interface scanning. It can turn a 45 min scan into seconds. This setting is not recomended for security in production environments but is good for Demo environments.
3. Execute the below commands on the kubernetes cluster
```
kubectl apply -f job1.yaml
kubectl get jobs
kubectl describe jobs <job-name> # <job-name> is retrived from above step. Replace the same while executing the query
kubectl get pods
kubectl logs <pod-name> > myresultspassive.txt # <pod-name> is retrived from above step. Replace the same while executing the query
```
4. View the pod logs from the 
```
cat myresultspassive.txt
```

## Part 2.2
### First delete the old job
```
kubectl delete -f job1.yaml
```

### You can do all this quickly via running a short command
```
cat job.yaml | sed 's/\["--pod"\]/\["--pod","--quick","--active"\]/' | sed "s/name: kube-hunter/name: $USER-3-kubehunter/" > job2.yaml
```

#### NOTE: the --active argument extends the test to use finding to test for specific exploits. Better for security. Most effective run within the cluster.
### Let's try it again
```
kubectl apply -f job2.yaml
kubectl get jobs
kubectl describe jobs <job-name> #<job-name> is retrived from above step. Replace the same while executing the query
kubectl get pods
kubectl logs <pod-name> > myresultsactive.txt  #<pod-name> is retrived from above step. Replace the same while executing the query

cat myresultsactive.txt

diff myresultsactive.txt myresultspassive.txt
```

#### Check the differences between the two results

## Part 3 - Tracee (https://github.com/aquasecurity/tracee)

### Tracee and Intro to eBPF (BPF references http://www.brendangregg.com/ebpf.html)

## Tracee (https://github.com/aquasecurity/tracee)
```
git clone https://github.com/aquasecurity/tracee.git
```

### Run in one terminal
```
sudo ./start.py -c
```
### Run in another terminal
```
docker run -it --rm alpine sh
```
### Try running similar commands in the docker shell to what you ran in the linux shell earlier and also experiment with networking commands like ping

### Observe the detailed tracing that appears in the first terminal!  There is a lot of detail.  Imagine what you could do with all that information programmatically to detect malicious behaviour built into containers from 3rd party providers or unvetted registries.  