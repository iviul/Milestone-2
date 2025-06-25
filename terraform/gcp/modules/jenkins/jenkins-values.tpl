namespace: ${jenkins_namespace}

controller:
  image: 
    registry: "docker.io"
    repository: "artamonovdima/jenkins-custom"
    tag: "6.0"
    pullPolicy: "IfNotPresent"
  installPlugins: false 

  admin:
    username: ${jenkins_admin_username}
    password: ${jenkins_admin_password}

  jenkinsUrl: ${jenkins_hostname}

  JCasC:
    enabled: true

    configScripts:
      custom-casc.yaml: |
        jenkins:
          systemMessage: "Jenkins configured automatically by JCasC\n\n"

        credentials:
          system:
            domainCredentials:
              - credentials:
                  - basicSSHUserPrivateKey:
                      scope: GLOBAL
                      id: "ssh_privatekey_github"
                      username: "git"
                      description: "SSH key for GitHub access"
                      privateKeySource:
                        directEntry:
                          privateKey: ${jenkins_github_ssh_private_key}
                  - file:
                      scope: GLOBAL
                      id: "gcp-sa-key"
                      description: "GCP service account key"
                      fileName: "gcp-key.json"
                      secretBytes: ${gcp_sa_key_b64}
                  - string:
                      scope: GLOBAL
                      id: cloudflare-token
                      description: Cloudflare API token
                      secret: ${cloudflare_api_token}
                  - string:
                      scope: GLOBAL
                      id: cloud_bucket
                      description: Cloud Storage bucket for Terraform state
                      secret: ${cloud_bucket}

        jobs:
          - script: >
              pipelineJob('Application Pipeline Job') {
                definition {
                  cpsScm {
                    scm {
                      git {
                        remote {
                          url('https://github.com/qjsoq/Jenkins-Automation.git')
                        }
                        branches('*/main')
                      }
                    }
                    scriptPath('jenkins/application/Jenkinsfile')
                  }
                }
              }
          - script: >
              pipelineJob('Infrastructure Pipeline Job') {
                definition {
                  cpsScm {
                    scm {
                      git {
                        remote {
                          url('https://github.com/Illusion4/jenkins-pipeline-infra.git')
                        }
                        branches('*/main')
                      }
                    }
                    scriptPath('Jenkinsfile')
                  }
                }
              }
              
        security:
          gitHostKeyVerificationConfiguration:
            sshHostKeyVerificationStrategy: "acceptFirstConnectionStrategy"
        
  sidecars:
    configAutoReload:
      enabled: true

  serviceAccount:
    create: true
rbac:
  create: true


