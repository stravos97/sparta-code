#!/bin/bash
# Script to update security group rules to allow all traffic

echo "Updating security group rules for sg-0a873b18b194fb5b6..."
# Revoke existing inbound rule (HTTP port 80)
aws ec2 revoke-security-group-ingress --group-id sg-0a873b18b194fb5b6 --protocol tcp --port 80 --cidr 0.0.0.0/0
# Revoke existing outbound rule
aws ec2 revoke-security-group-egress --group-id sg-0a873b18b194fb5b6 --protocol all --cidr 0.0.0.0/0
# Add new inbound rule for all traffic
aws ec2 authorize-security-group-ingress --group-id sg-0a873b18b194fb5b6 --protocol all --cidr 0.0.0.0/0
# Add new outbound rule for all traffic
aws ec2 authorize-security-group-egress --group-id sg-0a873b18b194fb5b6 --protocol all --cidr 0.0.0.0/0

echo "Updating security group rules for sg-03c12e29f28183a72..."
# Revoke existing inbound rule (SSH port 22)
aws ec2 revoke-security-group-ingress --group-id sg-03c12e29f28183a72 --protocol tcp --port 22 --cidr 0.0.0.0/0
# Revoke existing outbound rule
aws ec2 revoke-security-group-egress --group-id sg-03c12e29f28183a72 --protocol all --cidr 0.0.0.0/0
# Add new inbound rule for all traffic
aws ec2 authorize-security-group-ingress --group-id sg-03c12e29f28183a72 --protocol all --cidr 0.0.0.0/0
# Add new outbound rule for all traffic
aws ec2 authorize-security-group-egress --group-id sg-03c12e29f28183a72 --protocol all --cidr 0.0.0.0/0

echo "Updating security group rules for sg-045b5009d682f4c27..."
# Revoke existing inbound rule (TCP all ports on smaller CIDR)
aws ec2 revoke-security-group-ingress --group-id sg-045b5009d682f4c27 --protocol tcp --port 0-65535 --cidr 0.0.0.0/24
# Revoke existing outbound rule (currently limited to 0.0.0.0/24)
aws ec2 revoke-security-group-egress --group-id sg-045b5009d682f4c27 --protocol all --cidr 0.0.0.0/24
# Add new inbound rule for all traffic
aws ec2 authorize-security-group-ingress --group-id sg-045b5009d682f4c27 --protocol all --cidr 0.0.0.0/0
# Add new outbound rule for all traffic
aws ec2 authorize-security-group-egress --group-id sg-045b5009d682f4c27 --protocol all --cidr 0.0.0.0/0

echo "All security group rules have been updated to allow all traffic."
