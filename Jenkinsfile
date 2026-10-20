#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/TomKley345/twn-dbc-09-jenkins-shared-library.git',
    credentialsID: 'gitlab-credentials'
    ]
)

pipeline {
    agent any
    tools {
        maven 'maven'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage('build app') {
            steps {
                echo 'building application jar...'
                buildJar()
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image: ${IMAGE_NAME}"
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        } 
        stage("deploy") {
            steps {
                script {
                    echo 'deploying docker image to EC2...'

                    def ec2Instance = "ec2-user@16.170.133.212"

                    // sshagent(['ec2-server-key']) {
                    // sshagent(credentials: ['00c30b53-0e90-4575-b664-73b8e14d3ff0']) {
                    //     sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                    //     sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                    //     sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    // }

                    echo "..., deploying the maven app"
                    // def dockerCmd = "docker run -p 3080:3080 -d tomkley/demo-app:${IMAGE_NAME}"
                    // def dockerComposeCmd = "docker-compose -f docker-compose.yaml up --detach"
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    
                    sshagent(credentials: ['00c30b53-0e90-4575-b664-73b8e14d3ff0']) {
                        // echo "logging inside ec2"
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }               
        }

        stage('commit version update'){
            steps {
                script {
                    echo "committing version update ..."
                    // withCredentials([usernamePassword(credentialsId: 'gitlab-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                        // sh 'git remote set-url origin https://$USER:$PASS@gitlab.com/twn-devops-bootcamp/latest/09-AWS/java-maven-app.git'
                        // sh 'git add .'
                        // sh 'git commit -m "ci: version bump"'
                        // sh 'git push origin HEAD:jenkins-jobs'
                    // }
                }
            }
        }

        stage('Push version update to GitHub via HTTPS') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'github-https-token', passwordVariable: 'GIT_USERNAME', usernameVariable: 'GIT_PASSWORD')]) {
                    sh """
                        # 1. Git-Identität für den Commit-Eintrag setzen
                        git config user.name "TomKley345"
                        git config user.email "tk345@gmx.de"
                        
                        # 2. Änderungen committen (falls noch nicht geschehen)
                        git add .
                        git commit -m "Jenkins ci: bumping up the version" || echo "Keine Änderungen zu committen"
                        
                        # 3. Die Remote-URL von SSH auf HTTPS mit Token-Authentifizierung umschreiben
                        # https://github.com/TomKley345/twn-dbc-09-aws-services.git
                        git remote set-url origin https://\${GIT_USERNAME}:\${GIT_PASSWORD}@github.com/\${GIT_USERNAME}/twn-dbc-09-aws-services.git
                
                        # 4. Den Push auf den Ziel-Branch ausführen
                        git push origin HEAD:jenkins-shared-pipeline
                    """
                }
            }
        }
    }
}
