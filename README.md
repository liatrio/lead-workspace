# Overview
This repo contains instructions for configuring a LEAD workspace.

# Provision Workspace

* [Create](https://console.aws.amazon.com/cloud9/home/create) a new AWS Cloud9 environment

<img src='img/c9-env-1.png' width="80%">

* Choose `m4.large` for the **Instance type** and `Ubuntu Server 18.04 LTS` for the **Platform**
 
<img src='img/c9-env-2.png' width="80%">

* Review and click **Create environment**

<img src='img/c9-env-3.png' width="80%">

# Tooling setup

In the terminal, run:

```
    git clone https://github.com/liatrio/lead-workspace.git
    lead-workspace/setup.sh
```
