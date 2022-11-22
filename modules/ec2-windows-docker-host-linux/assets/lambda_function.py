import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
ec2_client = boto3.client('ec2')

def find_docker_host_id(instance_id):
    filters = [
        {'Name': 'resource-id', 'Values': [instance_id]},
        {'Name': 'key', 'Values': ['docker-host-instance']}
    ]
    
    response = ec2_client.describe_tags(Filters=filters)
    if len(response['Tags']) != 0:
        return response['Tags'][0]['Value']
    
    return None

def check_instance_status(instance_id, expected_status):
    response = ec2_client.describe_instance_status(InstanceIds=[instance_id], IncludeAllInstances=True)
    if len(response['InstanceStatuses']) == 0:
        logger.error("Cannot find ec2 instance %s", instance_id)
        return False

    return response['InstanceStatuses'][0]['InstanceState']['Name'] == expected_status


def lambda_handler(event, context):
    logger.info('## EVENT')
    logger.info(event)

    instance_id = event['detail']['instance-id']

    docker_host_id = find_docker_host_id(instance_id)

    if docker_host_id != None:
        logger.info("Found docker host machine for %s (%s)", instance_id, docker_host_id)
        
        instance_state = event['detail']['state'];
        if instance_state  == 'stopped':
            if check_instance_status(docker_host_id, 'running') == False:
                logger.warn("Docker host is not running")
                return

            stop_response = ec2_client.stop_instances(InstanceIds=[docker_host_id])
            logger.info("Stopped instance %s", docker_host_id)
            return stop_response
        
        if instance_state == 'running':
            if check_instance_status(docker_host_id, 'running'):
                logger.warn("Docker host is already running")
                return
            
            start_response = ec2_client.start_instances(InstanceIds=[docker_host_id])
            logger.info("Started instance %s", docker_host_id)
            return start_response
