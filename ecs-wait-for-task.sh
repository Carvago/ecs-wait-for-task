#!/usr/bin/env bash

# Heavily inspired by https://github.com/silinternational/ecs-deploy
# Thank you!


# Setup default values for variables
AWS_CLUSTER=false
TASK_ARN=false
TIMEOUT=90
VERBOSE=false


function usage() {
    cat <<EOM
## ecs-wait-for-task ##
Simple script for monitoring and waiting for success of Amazon Elastic Container Service Task run
https://github.com/janmikes/ecs-wait-for-task

Required arguments:
    --cluster               Name of ECS cluster
    --task                  Task ARN to wait for
Optional arguments:
    --timeout               Default is 90s
    --debug                 Verbose output
Requirements:
    aws:  AWS Command Line Interface
    jq:   Command-line JSON processor
Examples:
  Simple deployment of a service (Using env vars for AWS settings):
    ecs-wait-for-task --cluster "my-cluster" --task "arn:aws:ecs:eu-central-1:310753720731:task/8fbc18ee-6f44-42f8-ba33-b319e4fc1949"
EOM

    exit 1
}



# Check requirements
function require() {
    command -v "$1" > /dev/null 2>&1 || {
        echo "Some of the required software is not installed:"
        echo "    please install $1" >&2;
        exit 4;
    }
}



# Check that all required variables/combinations are set
function assertRequiredArgumentsSet() {
	# TODO: check for AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

	if [ -z ${AWS_ACCESS_KEY_ID+x} ]; then
        echo "AWS_ACCESS_KEY_ID env variable is required."
        exit 2
    fi

	if [ -z ${AWS_SECRET_ACCESS_KEY+x} ]; then
        echo "AWS_SECRET_ACCESS_KEY env variable is required."
        exit 2
    fi

	if [ -z ${AWS_REGION+x} ]; then
        echo "AWS_REGION env variable is required."
        exit 2
    fi

    if [ $AWS_CLUSTER == false ]; then
        echo "CLUSTER is required. You can pass the value using --cluster"
        exit 2
    fi

    if [ $TASK_ARN == false ]; then
        echo "TASK_ARN is required. You can pass the value using --task"
        exit 2
    fi
}



function waitForGreenDeployment {
  DEPLOYMENT_SUCCESS="false"
  every=2
  i=0

  echo "Waiting for service deployment to complete..."

  while [ $i -lt $TIMEOUT ]
  do
    NUM_DEPLOYMENTS=$($AWS_ECS describe-services --services $SERVICE --cluster $CLUSTER | jq "[.services[].deployments[]] | length")

    # Wait to see if more than 1 deployment stays running
    # If the wait time has passed, we need to roll back
    if [ $NUM_DEPLOYMENTS -eq 1 ]; then
      echo "Service deployment successful."
      DEPLOYMENT_SUCCESS="true"
      # Exit the loop.
      i=$TIMEOUT
    else
      sleep $every
      i=$(( $i + $every ))
    fi
  done

  if [[ "${DEPLOYMENT_SUCCESS}" != "true" ]]; then
    if [[ "${ENABLE_ROLLBACK}" != "false" ]]; then
      rollback
    fi
    exit 1
  fi
}


###################
# Run application #
###################

set -o errexit
set -o pipefail
set -u
set -e

# If no args are provided, display usage information
if [ $# == 0 ]; then usage; fi

# Check for AWS, AWS Command Line Interface
require aws

# Check for jq, Command-line JSON processor
require jq

# Loop through arguments, two at a time for key and value
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --cluster)
            AWS_CLUSTER="$2"
            shift # past argument
            ;;
        --timeout)
            TIMEOUT="$2"
            shift
            ;;
        --task)
            TASK_ARN="$2"
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        *)
            #If another key was given that is not empty display usage.
            if [[ ! -z "$key" ]]; then
              usage
              exit 2
            fi
        ;;
    esac
    shift # past argument or value
done

if [ $VERBOSE == true ]; then
    set -x
fi

# Check that required arguments are provided
assertRequiredArgumentsSet

TASK_DESCRIPTION=`aws ecs describe-tasks --region $AWS_REGION --cluster $AWS_CLUSTER --tasks $TASK_ARN | jq --raw-output '.tasks[0].containers[0].exitCode'`

EXIT_CODE=`echo $RESULT | jq --raw-output '.tasks[0].containers[0].exitCode'`

exit 0
