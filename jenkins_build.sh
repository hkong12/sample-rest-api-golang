#/bin/bash

IMAGE_REPO_NAME='xueerk/sample-api'
IMAGE_TAG=${BUILD_NUMBER}

echo "Build started on `date`"
echo "Building the Docker image..."   
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
docker push $IMAGE_REPO_NAME:$IMAGE_TAG 


# SERVICE_NAME="flask-signup-service"
# IMAGE_VERSION="v_"${BUILD_NUMBER}
# TASK_FAMILY="flask-signup"

# Create a new task definition for this build
# sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" flask-signup.json > flask-signup-v_${BUILD_NUMBER}.json
# aws ecs register-task-definition --family flask-signup --cli-input-json file://flask-signup-v_${BUILD_NUMBER}.json

# Update the service with the new task definition and desired count
# TASK_REVISION=`aws ecs describe-task-definition --task-definition flask-signup | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
# DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} | egrep "desiredCount" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
# if [ ${DESIRED_COUNT} = "0" ]; then
#     DESIRED_COUNT="1"
# fi

# aws ecs update-service --cluster default --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}
