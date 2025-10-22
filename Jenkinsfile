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
                            # Use a different port to avoid conflicts
                            docker run -d --name test-container -p 8001:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                            echo "Container started, waiting for application to be ready..."
                            sleep 15
                            
                            # Check if container is still running
                            docker ps | grep test-container || (echo "Container stopped unexpectedly" && docker logs test-container && exit 1)
                            
                            # Check container logs for any errors
                            echo "Container logs:"
                            docker logs test-container
                            
                            # Check what's listening on ports
                            echo "Checking port 8001..."
                            netstat -tlnp | grep 8001 || echo "Port 8001 not listening"
                            
                            # Test health endpoint
                            echo "Testing health endpoint..."
                            curl -f http://localhost:8001/health || (echo "Health check failed" && exit 1)
                            
                            # Test main endpoint
                            echo "Testing main endpoint..."
                            curl -f http://localhost:8001/ || (echo "Main endpoint failed" && exit 1)
                            
                            echo "✅ All tests passed!"
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

        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                        usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                    }

                    // Push both tagged and latest versions
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"

                    // Logout from Docker Hub
                    sh "docker logout"
                }
            }
        }
        
    } 

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo "✅ Successfully built and tested ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "✅ Latest tag also updated: ${DOCKER_IMAGE}:latest"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs for details."
        }
    }
}
