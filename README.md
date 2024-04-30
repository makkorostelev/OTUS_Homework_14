# OTUS_Homework_14
 
Project creates CEPH Cluster.

To work with the project you need to write your data into variables.tf.\
![Variables](https://github.com/makkorostelev/OTUS_Homework_14/blob/main/Screenshots/variables.png)\
# **IMPORTANT!**
Before installation, check and install the required components. Information is available via the link: https://docs.ceph.com/projects/ceph-ansible/en/latest/


Then enter the commands:\
`terraform init`\
`terraform apply`

After ~15 minutes project will be initialized and run:\

You can log in to any node in the cluster and check its status.\
`sudo ceph status`\

![Ceph](https://github.com/makkorostelev/OTUS_Homework_14/blob/main/Screenshots/ceph.png)

