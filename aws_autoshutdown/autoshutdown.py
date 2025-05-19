import boto3
from datetime import datetime, timedelta

# Initialize Boto3 EC2 and CloudWatch clients
ec2_client = boto3.client('ec2')
cloudwatch_client = boto3.client('cloudwatch')

def get_instance_name(tags):
    """Extract the instance name from the instance tags."""
    for tag in tags:
        if tag['Key'] == 'Name':
            return tag['Value']
    return "Unknown"

def get_instances_by_tag(tag_key, tag_value):
    """Retrieve all EC2 instances with a specific tag, their names, and states."""
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': f'tag:{tag_key}',
                'Values': [tag_value]
            },
        ]
    )
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_name = get_instance_name(instance.get('Tags', []))
            instance_state = instance['State']['Name']
            instances.append((instance['InstanceId'], instance_name, instance_state))
    return instances

def get_average_cpu_usage(instance_id, start_time, end_time):
    """Get the average CPU usage for an instance over a specified time period."""
    response = cloudwatch_client.get_metric_statistics(
        Namespace='AWS/EC2',
        MetricName='CPUUtilization',
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            },
        ],
        StartTime=start_time,
        EndTime=end_time,
        Period=3600,  # 1 hour in seconds
        Statistics=['Average']
    )
    datapoints = response['Datapoints']
    if not datapoints:
        return 0
    average_cpu = sum(d['Average'] for d in datapoints) / len(datapoints)
    return average_cpu

def shutdown_low_utilization_instances(instance_id):
    """Shutdown instances with less than 3% average CPU utilization."""
    ec2_client.stop_instances(InstanceIds=[instance_id])
    print(f"Instance {instance_id} has been shut down due to low CPU utilization.")

def main(tag_key, tag_value):
    # Time range for the past 12 hours
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(hours=12)

    instances = get_instances_by_tag(tag_key, tag_value)
    instance_cpu_usage = []

    for instance_id, instance_name, instance_state in instances:
        avg_cpu = get_average_cpu_usage(instance_id, start_time, end_time)
        instance_cpu_usage.append((instance_id, instance_name, avg_cpu))
        if avg_cpu < 3 and instance_state == 'running':
            print(f"Killing: {instance_name} / {instance_id} / {instance_state}")
            shutdown_low_utilization_instances(instance_id)

    # Sort instances by average CPU usage
    sorted_instances = sorted(instance_cpu_usage, key=lambda x: x[2], reverse=True)

    # Output the sorted list
    for instance in sorted_instances:
        print(f"Instance ID: {instance[0]}, Name: {instance[1]}, Average CPU Usage: {instance[2]}%")

if __name__ == "__main__":
    TAG_KEY = "cloud"
    TAG_VALUE = "1.0.0"
    main(TAG_KEY, TAG_VALUE)