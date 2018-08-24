# Terraform Kubernetes
A template for building a kubernetes environment with a master and worker nodes with terraform and packer.

## Intention:
The purpose of this template is to provide an easy-to-use approach to using an Infrastructure-as-a-service deployment to deploy a kubernetes cluster on Microsoft Azure.  The goal being that you can start fresh with a standardized approach and preconfigured master and worker nodes.  

## How it works?
This template create a master node, and as many worker nodes as you specify, and during creation will automatically execute the scripts required to join those nodes to the cluster.  The benefit of this being that once your cluster is created, all that is required to add additional nodes is to increase the count of the "lkwn" vm type, and reapply the template.  This will cause the newe VMs to be created and the cluster will start orchestrating them automatically.  

This template can also be built into a CI/CD pipeline to automatically provision the kubernetes cluster prior to pushing pods to it.  

This guide is designed to help you navigate the use of this template to standup and manage the infrastructure required by a kubernetes cluster on azure.  You will find the following documentation to assist:

* **[Configure Terraform Development Environment](https://github.com/KevinDMack/TerraformKubernetes/wiki/Configuring-Terraform-Development-Environment)**:  This page provides details on how to setup your locale machine to leverage this template and do development using Terraform, Packer, and VSCode.
* **[Use this template](https://github.com/KevinDMack/TerraformKubernetes/wiki/Using-this-template)**:  This document walks you through how to leverage this template to build out your kubernetes environment.
* **[Understanding the template](https://github.com/KevinDMack/TerraformKubernetes/wiki/Understanding-the-Template)**:  This page describes how to understand the Terraform Template being used and walks you through its structure.

## Key Contributors!
A special thanks to the following people who contributed to this template:
* **[Brandon Rohrer](https://github.com/rohrerb):** who introduced me to this template structure and how it works, as well as assisted with optimizing the functionality provided by this template.
