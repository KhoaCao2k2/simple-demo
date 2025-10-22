pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'khoacao2002/simple-demo-argocd'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY = 'docker.io'
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    // Build Docker image with build number as tag
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                echo 'Testing Docker image...'
                script {
                    try {
                        // Run the container to test if it starts properly
                        sh """
                            docker run -d --name test-container -p 8000:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                            sleep 10
                            # Test health endpoint
                            curl -f http://localhost:8000/health || exit 1
                            # Test main endpoint
                            curl -f http://localhost:8000/ || exit 1
                        """
                    } finally {
                        // Clean up test container even if tests fail
                        sh """
                            docker stop test-container || true
                            docker rm test-container || true
                        """
                    }
                }
            }
        }
        
    //     stage('Push to Docker Hub') {
    //         steps {
    //             echo 'Pushing Docker image to Docker Hub...'
    //             script {
    //                 // Login to Docker Hub
    //                 withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
    //                     usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    //                     sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
    //                 }
                    
    //                 // Push both tagged and latest versions
    //                 sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
    //                 sh "docker push ${DOCKER_IMAGE}:latest"
                    
    //                 // Logout from Docker Hub
    //                 sh "docker logout"
    //             }
    //         }
    //     }
        
    //     stage('Cleanup') {
    //         steps {
    //             echo 'Cleaning up local Docker images...'
    //             script {
    //                 // Remove local images to save space
    //                 sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
    //                 sh "docker rmi ${DOCKER_IMAGE}:latest || true"
    //             }
    //         }
    //     }
    // }
    
    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo "✅ Successfully built and pushed ${DOCKER_IMAGE}:${DOCKER_TAG} to Docker Hub"
            echo "✅ Latest tag also updated: ${DOCKER_IMAGE}:latest"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs for details."
        }
    }
}
