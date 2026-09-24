def gv

pipeline {   
    agent any
    stages {
        stage("test") {
            steps {
                echo "testing the app"
            }
        }
        stage("build jar") {
            steps {
                script {
                    echo 'building the application...'
                }
            }
        }

        stage("build image") {
            steps {
                script {
                    echo "building the docker image..."
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "deploying the app"
                    def dockerCmd = 'docker run -p 3080:3080 -d tomkley/demo-app:1.1.1-30'
                    sshagent(credentials: ['00c30b53-0e90-4575-b664-73b8e14d3ff0'], executable: '') {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@16.170.133.212 ${dockerCmd}"
                    }
                }
            }
        }
    }
} 
