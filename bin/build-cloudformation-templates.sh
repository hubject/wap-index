#!/usr/bin/env bash

set -e

usage() {
    echo "[error] $1"
	echo "[info] usage: $0 -p <aws-profile> -pn <project-name> -e <environment> -c <component> -l <layer> -u <repouser> -pw <repopassword>"
	exit 1;
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--profile)
    PROFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -pn|--project-name)
    PROJECT_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--environment)
    ENVIRONMENT="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--component)
    COMPONENT="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--layer)
    LAYER="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--repouser)
    REPOUSER="$2"
    shift # past argument
    shift # past value
    ;;
    -pw|--repopassword)
    REPOPASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

[[ -z "${PROFILE}" ]] && { usage "No profile."; exit 1; }
[[ -z "${PROJECT_NAME}" ]] && { usage "No project name."; exit 1; }
[[ -z "${ENVIRONMENT}" ]] && { usage "No environment."; exit 1; }
[[ -z "${COMPONENT}" ]] && { usage "No component."; exit 1; }
[[ -z "${LAYER}" ]] && { usage "No layer."; exit 1; }
[[ -z "${REPOUSER}" ]] && { usage "No layer."; exit 1; }
[[ -z "${REPOPASSWORD}" ]] && { usage "No layer."; exit 1; }

COMPONENT_LIST=`find deploy/templates -maxdepth 1 -type d | cut -f3 -d'/'`
[[ ${COMPONENT_LIST} =~ (^|[[:space:]])$COMPONENT($|[[:space:]]) ]] && : || { usage "Unknown component '${COMPONENT}'. Available components: ${COMPONENT_LIST//$'\n'/|}"; exit 1; }

LAYER_LIST=`find deploy/templates/${COMPONENT} -maxdepth 1 -type d | cut -f4 -d'/'`
[[ ${LAYER_LIST} =~ (^|[[:space:]])$LAYER($|[[:space:]]) ]] && : || { usage "Unknown layer '${LAYER}'. Available layers: ${LAYER_LIST//$'\n'/|}"; exit 1; }

# settings
DIR_BASE=deploy/templates/${COMPONENT}/${LAYER}/aws-cloudformation
AWS_REGION=$(aws configure get region --profile ${PROFILE})

# create bucket
S3_BUCKET=cfn-${AWS_REGION}-${PROJECT_NAME}-${ENVIRONMENT}-${COMPONENT}-${LAYER}
if aws s3 ls "s3://${S3_BUCKET}" --profile ${PROFILE} 2>&1 | grep -q 'NoSuchBucket'
then
    echo "[info] ${S3_BUCKET} doesn't exist, so it will be created"
    if [ "${AWS_REGION}" = "us-east-1" ] ; then
        aws s3api create-bucket \
            --profile ${PROFILE} \
            --bucket ${S3_BUCKET} \
            --region ${AWS_REGION}
    else
        aws s3api create-bucket \
            --profile ${PROFILE} \
            --bucket ${S3_BUCKET} \
            --region ${AWS_REGION} \
            --create-bucket-configuration LocationConstraint=${AWS_REGION}
    fi
fi

# validate template
aws cloudformation validate-template \
    --profile ${PROFILE} \
    --template-body file://$DIR_BASE/master.yml

# package template
DIR_PACKAGED=$DIR_BASE/_packaged_
#echo $DIR_PACKAGED
if [ ! -d "${DIR_PACKAGED}" ]
then
  echo "[info] ${DIR_PACKAGED} doesn't exist, so it will be created"
  mkdir -p "${DIR_PACKAGED}"
fi

aws cloudformation package \
    --profile ${PROFILE} \
    --template ./$DIR_BASE/master.yml \
    --s3-bucket ${S3_BUCKET} \
    --output-template-file ${DIR_PACKAGED}/master.yml

echo '[info] apply fix: replace S3 china URL: https://s3.amazonaws.com/ -> https://s3.cn-northwest-1.amazonaws.com.cn'
sed -i.bak s/s3.amazonaws.com/s3.cn-northwest-1.amazonaws.com.cn/g ${DIR_PACKAGED}/master.yml

# deploy template
echo '[info] deploy CloudFormation template'
aws cloudformation deploy \
    --profile ${PROFILE} \
    --template-file ${DIR_PACKAGED}/master.yml \
    --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-${COMPONENT}-${LAYER} \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        Environment=${ENVIRONMENT} \
        ProjectName=${PROJECT_NAME} \
        Component=${COMPONENT} \
        Layer=${LAYER} \
        RepoUser=${REPOUSER} \
        RepoPassword=${REPOPASSWORD} 

# EOF
