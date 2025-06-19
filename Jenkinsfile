node {
    stage('Debug') {
        sh 'pwd'
        sh 'ls -la'
        sh 'find . -name "*.groovy" -type f'
    }
    stage('Load Infra Pipeline') {
        load 'jenkins/infra/infra_pipeline.groovy'
    }
    stage('Load App Pipeline') {
        load 'jenkins/application/app_pipeline.groovy'
    }
}
