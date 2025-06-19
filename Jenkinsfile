pipeline{
    agent any
    stages{
        stage("checkout"){
            steps{
                checkout scm
            }
        }
        stage('Load Infra Pipeline') {
            steps {
                script {
                    load 'jenkins/infra/infra_pipeline.groovy'
                }
            }
        }
        stage('Load App Pipeline') {
            steps {
                script {
                    load 'jenkins/application/app_pipeline.groovy'
                }
            }
        }
    }
}