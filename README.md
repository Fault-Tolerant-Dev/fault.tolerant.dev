# How to Hugo on Google Cloud

---
### Who You Are
1) You want to use a Static Site Generator like Hugo
2) You would like to host it somewhere other than GitHub or Netlify
3) You don't want to litter your local machine with binaries/libraries when tools like Docker have existed for 6+ years
4) Terraform is cool so you figured why not 

### Things You Will Need  
1) A Domain Name - https://domains.google/  
2) Docker Desktop - https://www.docker.com/products/docker-desktop  
3) Google Cloud - https://cloud.google.com  

*Google Cloud Note*  
I've yet to test this with a free ($300 service credits) style account 

### Things You Will Do - Super High Level
1) Build a docker image 
2) Deploy a google cloud project  
3) Build a simple hugo site
4) Deploy a simple hugo site
---

### Repository Files - What's What
**Container**  
Holds Dockerfile for our dev/deployment environment. Image is built upon Ubuntu 20.04 and builds the following:     
-Hugo  
-Git  
-Vim  
-Curl  
-Unzip  
-Google-Cloud-SDK  
-Terraform V1.0.3 <-- Pinned at this version  

**Hosting**  
Holds all Terraform related configs:            
-main.tf   
-outputs.tf  
-terraform.tf  
-terraform.tfvars <-- This is where the magic happens  
-variables.tf  

**Site**  
Holds all hugo site configuration:    
*Crickets....yeah its empty*
----
## Getting Started

### Preflight Checklist
Domain name purchased and ready to use  
Google Cloud account that is up, running, and tested. To test, create a project and a compute instance, then terminate in reverse order  
Docker Desktop installed


### Clone or Download this Repo
Change working directory to an ideal location  
Download this repository either by cloning via git/gh or downloading from a web browser 

### Build Container Image  
Change working directory to 'container'  
Run command - **docker build -t myown:tools .**
````
MacBook-Pro-2:container fault-tolerant-dev$ docker build -t myown:tools .
[+] Building 1.0s (12/12) FINISHED                                                                                                
 => [internal] load build definition from Dockerfile                                                                         0.0s
 => => transferring dockerfile: 37B                                                                                          0.0s
 => [internal] load .dockerignore                                                                                            0.0s
 => => transferring context: 2B                                                                                              0.0s
 => [internal] load metadata for docker.io/library/ubuntu:20.04                                                              0.8s
 => [auth] library/ubuntu:pull token for registry-1.docker.io                                                                0.0s
 => [1/7] FROM docker.io/library/ubuntu:20.04@sha256:82becede498899ec668628e7cb0ad87b6e1c371cb8a1e597d83a47fac21d6af3        0.0s
 => CACHED [2/7] RUN apt-get update &&     apt-get install -y hugo git vim curl apt-transport-https ca-certificates gnupg u  0.0s
 => CACHED [3/7] RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud  0.0s
 => CACHED [4/7] RUN apt-get update &&     apt-get install -y google-cloud-sdk                                               0.0s
 => CACHED [5/7] WORKDIR /configs                                                                                            0.0s
 => CACHED [6/7] RUN curl -O https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_SHA256SUMS &&     curl -O https  0.0s
 => CACHED [7/7] RUN apt-get clean &&     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /configs*                            0.0s
 => exporting to image                                                                                                       0.0s
 => => exporting layers                                                                                                      0.0s
 => => writing image sha256:5e5c5f5dcfed3ce7c7270366180f54d5fd6cc769bad9f88eaf24e0a967f117d1                                 0.0s
 => => naming to docker.io/library/myown:tools                                                                               0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
````

### Run Container Image
Change working directory back to where you started  
docker run -it -v $PWD:/configs -p 1313:1313 -p 8000:8000 myown:tools  
*Notes:    
'/config' is the WORKDIR called out in the Dockerfile  
'-p 1313' is the port the Hugo server will run on*  

You will now be at a shell within the container - something like the following
````
MacBook-Pro-2:container fault-tolerant-dev$ docker run -it -v $PWD:/configs -p 1313:1313 myown:tools
root@3a13a1d6d8f4:/configs# 
````

### Project Create, State Bucket Create
Replace, Copy, and Paste the following into the container *update values marked in bold*  
````
gcloud auth login --update-adc  
gcloud projects create **mysite-97512** --name=**mysite** --set-as-default  
gsutil mb -l **us-central1** -b on gs://tfstate-**97512**  
````

*if you need to link your project to a billing account*  
````
gcloud beta billing accounts list  
gcloud beta billing projects link **mysite-97512** --billing-account=**128123831454**
````

### Checklist 
| Required Item  | Output |
| ------------- | ------------- |
| Domain Name  | domain.io  |
| Google Project  | mysite  |
| Google Project ID | mysite-97512 |
| Google Bucket | gs://tfstate-97512 |
| Google Region | us-central1 | 
---
## Building out Google with Terraform

### 


hugo new site ./ --force

deployment:
  order:
    - .jpg$
    - .gif$
  targets:
    - name: mydeployment
      URL: gs://bucket-site
  matchers:
    - pattern: ^.+\.(js|css|svg|ttf)$
      cacheControl: 'max-age=31536000, no-transform, public'
      gzip: true
    - pattern: ^.+\.(png|jpg)$
      cacheControl: 'max-age=31536000, no-transform, public'
      gzip: false
    - pattern: ^sitemap\.xml$
      contentType: application/xml
      gzip: true
    - pattern: ^.+\.(html|xml|json)$
      gzip: true