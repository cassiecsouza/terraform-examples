terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.19.0"
    }
  }
}

provider "harness" {
  platform_api_key = var.api_key
  account_id = var.account_id
}

resource "harness_platform_project" "my_project" {
  identifier = var.project_identifier
  name       = var.project_name
  org_id     = var.org_id
  color      = var.project_color
}

resource "harness_platform_service" "my_service" {
  depends_on = [harness_platform_project.my_project]
  identifier  = var.service_identifier
  name        = var.service_name
  description = var.service_description
  org_id      = var.org_id
  project_id  = harness_platform_project.my_project.id
  force_delete = true
    
  yaml = <<-EOT
    service:
      name: ${var.service_name}
      identifier: ${var.service_identifier}
      serviceDefinition:
        spec:
          manifests:
            - manifest:
                identifier: Manifests
                type: K8sManifest
                spec:
                  store:
                    type: Github
                    spec:
                      connectorRef: account.Public_Github
                      gitFetchType: Branch
                      paths:
                        - deploy/deployment.yaml
                      repoName: <+input>
                      branch: develop
                  skipResourceVersioning: false
                  enableDeclarativeRollback: false
          artifacts:
            primary:
              primaryArtifactRef: Dockerhub
              sources:
                - spec:
                    connectorRef: account.LRDockerHub
                    imagePath: luisredda/harness-java-demo-k8s
                    tag: latest-wf
                  identifier: Dockerhub
                  type: DockerRegistry         
        type: Kubernetes
      gitOpsEnabled: false
  EOT
}

resource "harness_platform_environment" "example" {
  depends_on = [harness_platform_service.my_service]
  identifier = var.environment_id
  name       = var.environment_name
  org_id     = var.org_id
  project_id = var.project_identifier
  tags       = ["wfdemo", "aks"]
  type       = "PreProduction"
  force_delete = true

  ## ENVIRONMENT V2 Update
  ## The YAML is needed if you want to define the Environment Variables and Overrides for the environment
  ## Not Mandatory for Environment Creation nor Pipeline Usage

  yaml = <<-EOT
       environment:
         name: ${var.environment_name}
         identifier: ${var.environment_id}
         tags:
           type: autoprovisioned
           terraform: "true"  
         orgIdentifier: ${var.org_id}
         projectIdentifier: ${harness_platform_project.my_project.id}
         type: PreProduction
         variables:
           - name: envVar1
             type: String
             value: v1
             description: ""
           - name: envVar2
             type: String
             value: v2
             description: ""          
      EOT
}

resource "harness_platform_infrastructure" "example" {
  depends_on = [harness_platform_environment.example]
  identifier      = var.infra_id
  name            = var.infra_name
  org_id          = var.org_id
  project_id      = var.project_identifier
  env_id          = var.environment_id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
        infrastructureDefinition:
         name: ${var.infra_name}
         identifier: ${var.infra_id}
         description: ""
         tags:
           terraform: "true"
         orgIdentifier: ${var.org_id}
         projectIdentifier: ${var.project_identifier}
         environmentRef: ${var.environment_id}
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: org.cassieaks
          namespace: wfdemo
          releaseName: release-<+INFRA_KEY>
          allowSimultaneousDeployments: false
      EOT
}

resource "harness_platform_pipeline" "example" {
  depends_on = [harness_platform_infrastructure.example]
  identifier = "Build_and_Deploy_Java_App"
  org_id     =  var.org_id
  project_id =  var.project_identifier
  name       = "Build and Deploy Java App"
  yaml = <<-EOT
    pipeline:
      name: Build and Deploy Java App
      identifier: Build_and_Deploy_Java_App
      template:
        templateRef: org.WF_Java_Template
        versionLabel: v1
        templateInputs:
          properties:
            ci:
              codebase:
                build: <+input>
                repoName: <+input>
          stages:        
            - stage:
                identifier: Change_Management
                type: Custom
                spec:
                  environment:
                    environmentRef: dev
                    infrastructureDefinitions:
                      - identifier: kubedev        
            - stage:
                identifier: K8s_Deployment
                type: Deployment
                spec:
                  service:
                    serviceRef: datascience
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          manifests:
                            - manifest:
                                identifier: Manifests
                                type: K8sManifest
                                spec:
                                  store:
                                    type: Github
                                    spec:
                                      repoName: <+input>                    
                  environment:
                    environmentRef: dev
                    infrastructureDefinitions:
                      - identifier: kubedev
      tags: {}
      projectIdentifier: ${var.project_identifier}
      orgIdentifier: ${var.org_id}

  EOT
}
