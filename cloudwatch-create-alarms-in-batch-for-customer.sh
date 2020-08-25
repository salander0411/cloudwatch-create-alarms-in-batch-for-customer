#!/bin/bash

# need to install jq from https://stedolan.github.io/jq/download/ first
output=$(aws ec2 describe-instances --filters Name=instance-state-code,Values=16 --query "Reservations[*].Instances[*].{Instance:InstanceId}"  --output json  --region cn-northwest-1 )

echo $output

json_length=$(echo $output | jq length)

for ((i=0;i<json_length;i++))
#for ((i=0;i<1;i++))
do 
	echo $i
	value=$(echo $output | jq '.['$i'][0].Instance')
	echo $value
	reboot_name='reboot-alarm-'$i
	recover_name='reover-name-'$i
	aws cloudwatch put-metric-alarm --alarm-name $reboot_name --alarm-description "auto reboot" --metric-name StatusCheckFailed_Instance --namespace AWS/EC2 --statistic Average --period 60  --comparison-operator GreaterThanOrEqualToThreshold --threshold 2 --dimensions "Name=InstanceId,Value=$value" --evaluation-periods 3 --actions-enabled  --alarm-actions arn:aws-cn:automate:cn-northwest-1:ec2:reboot arn:aws-cn:sns:cn-northwest-1:2874XXX:reboot-alarm(替换成自己的SNS TOPIC ARN) --region cn-northwest-1  
	
	aws cloudwatch put-metric-alarm --alarm-name $recover_name --alarm-description "auto recovery" --metric-name StatusCheckFailed_System --namespace AWS/EC2 --statistic Average --period 60  --comparison-operator GreaterThanOrEqualToThreshold --threshold 2 --dimensions "Name=InstanceId,Value=$value" --evaluation-periods 3 --actions-enabled  --alarm-actions arn:aws-cn:automate:cn-northwest-1:ec2:recover arn:aws-cn:sns:cn-northwest-1:2874XXX:recovery-alarm(替换成自己的SNS TOPIC ARN) --region cn-northwest-1  
	
done
