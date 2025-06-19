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
                    def infraPipeline = load 'jenkins/infra/infra_pipeline.groovy'
                    infraPipeline()
                }
            }
        }
        stage('Load App Pipeline') {
            steps {
                script {
                    def appPipeline = load 'jenkins/application/app_pipeline.groovy'
                    appPipeline()
                }
            }
        }
    }
}