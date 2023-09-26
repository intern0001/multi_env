terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}
data "aws_ssm_parameter" "github_token" {
  name = "github_token"
  
}
data "aws_ssm_parameter" "github_name" {
  name = "github_user_name"
  
}
data "aws_region" "current" {} #get current region
data "aws_caller_identity" "current" {} #get current user id

module "argocd" {
  source  = "terraform-module/release/helm"
  version = "2.8.1"
  app = {
    name          = "argocd"
    version       = "5.43.4"
    chart         = "argo-cd"
    force_update  = true
    wait          = false
    recreate_pods = false
    create_namespace = true
    deploy        = 1
  }
  namespace = "argocd"
  repository =  "https://argoproj.github.io/argo-helm/"
  values           = [<<EOF
  global: 
    image:
      tag: ${var.argo_version}
  server:
    extraArgs:
      - --insecure    
    ingress:
      https: false
      enabled: true
      annotations:
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      ingressClassName: "nginx"
      hosts: 
        - "${var.host}"
      extraPaths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: argocd-server
              port:
                name: http
  configs:                                        #github credentials 
    credentialTemplates:
      https-creds:
        url: ${var.helm_repo}
        password: ${local.github_token}
        username: ${local.github_name}             
    
        
  EOF 
  ]
}
module "updater" {
  source  = "terraform-module/release/helm"
  version = "2.8.1"
  app = {
    name          = "image-updater"
    version       = "0.9.1"
    chart         = "argocd-image-updater "
    force_update  = true
    wait          = false
    recreate_pods = false
    create_namespace = true
    deploy        = 1
  }
  namespace = "argocd"
  repository =  "https://argoproj.github.io/argo-helm/"

  values           = [<<EOF

image:
  tag: ${var.updater_version}

metrics:
  enabled: true

config:
    registries:
      - name: ECR
        api_url: "https://${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com"
        prefix: ${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com
        default: true
        ping: yes
        insecure: no
        credentials: ext:/scripts/ecr-login.sh  #script name should match here and in authScripts 
        credsexpire: 11h
authScripts:
    enabled: true
    scripts: 
        ecr-login.sh: |   # notice script name matches above    
          #!/bin/sh
          aws ecr --region ${local.aws_region} get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d


  EOF
  ]
 depends_on = [module.argocd]
}


module "app" {
  source  = "terraform-module/release/helm"
  version = "2.8.1"
  app = {
    name          = "argocd-apps"
    version       = "1.4.1"
    chart         = "argocd-apps"
    force_update  = true
    wait          = false
    recreate_pods = false
    create_namespace = true
    deploy        = 1
  }
  namespace = "argocd"
  repository =  "https://argoproj.github.io/argo-helm/"
  values           = [<<EOF
applications:
- name: ${var.env}-intern-app
  namespace: argocd
  project: default
  source:
    repoURL: ${var.argo_repo}
    targetRevision: HEAD
    path: app/${var.env}/
  destination:
    server: https://kubernetes.default.svc
    namespace: default  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true  

  EOF 
  ]
  depends_on = [module.updater]  
}


