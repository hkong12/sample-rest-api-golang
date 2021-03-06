#/bin/bash

IMAGE_REPO_NAME='xueerk/sample-api'
IMAGE_TAG=${BUILD_NUMBER}
CLUSTER_NAME='sample-api-cluster'
SERVICE_NAME='sample'
TASK_FAMILY='sample-api'

# Build docker image
echo "Build started on `date`"
echo "Building the Docker image..."   
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
docker push $IMAGE_REPO_NAME:$IMAGE_TAG 

# Create new task definition for the build
echo "Create new task definition"
sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" task_definition.json > task_definition_${BUILD_NUMBER}.json
aws ecs register-task-definition --cli-input-json file://task_definition_${BUILD_NUMBER}.json

# Update the service with the new task definition and desired count
echo "Update ECS service"
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count 1