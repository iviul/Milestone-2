pipeline {
  agent any

  stages {
    stage('local test') {
      steps {
        echo "Hello world from application"
      }
    }
  }
}
