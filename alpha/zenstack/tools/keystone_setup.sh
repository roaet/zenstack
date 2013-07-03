#!/bin/bash
# this file assumes a working keystone binary is available and is within the
# $PATH and that OS_SERVICE_TOKEN is defined, and OS_SERVICE_ENDPOINT is also
# defined.
DEFAULT_TENANT=openstack
SERVICE_TENANT=service
DEFAULT_USER=admin
USER_PASS=password
ADMIN_ROLE=admin

create_tenant() {
    keystone tenant-create --name $1 \
        --description "$2" \
        --enabled true > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error making tenant"
        exit 1
    fi
    uuid=`keystone tenant-list | \
        grep $1 | awk -F " " '{print $2}'`
    echo $uuid
}

create_user() {
    keystone user-create --name $1 \
        --tenant_id $2 \
        --pass $3 \
        --enabled true > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error making user"
        exit 1
    fi
    uuid=`keystone user-list | \
        grep $1 | awk -F " " '{print $2}'`
    echo $uuid
}

create_role() {
    keystone role-create --name $1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error making role"
        exit 1
    fi
    uuid=`keystone role-list | \
        grep $1 | awk -F " " '{print $2}'`
    echo $uuid
}

grant_role() {
    keystone user-role-add --user_id $1 --tenant_id $2 --role_id $3 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error granting role"
        exit 1
    fi

}

create_service() {
    keystone service-create --name $1 --type $2 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error creating service"
        exit 1
    fi
    uuid=`keystone service-list | \
        grep $1 | awk -F " " '{print $2}'`
    echo $uuid
}

create_endpoint() {
    keystone endpoint-create \
        --region $1 \
        --service_id $2 \
        --publicurl=$3 \
        --internalurl=$4 \
        --adminurl=$5 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error creating endpoint"
        exit 1
    fi
    uuid=`keystone endpoint-list | \
        grep $3 | awk -F " " '{print $2}'`
    echo $uuid
}


DEFAULT_TENANT_UUID=`create_tenant $DEFAULT_TENANT "Default Tenant"`
echo "Default tenant: '$DEFAULT_TENANT_UUID'"
SERVICE_TENANT_UUID=`create_tenant $SERVICE_TENANT "Service Tenant"`
echo "Service tenant: '$SERVICE_TENANT_UUID'"
ADMIN_USER_UUID=`create_user $DEFAULT_USER $DEFAULT_TENANT_UUID password`
echo "Admin user: '$ADMIN_USER_UUID'"
GLANCE_UUID=`create_user glance $SERVICE_TENANT_UUID glance`
echo "Glance user: '$GLANCE_UUID'"
NOVA_UUID=`create_user nova $SERVICE_TENANT_UUID nova`
echo "Nova user: '$NOVA_UUID'"
EC2_UUID=`create_user ec2 $SERVICE_TENANT_UUID ec2`
echo "EC2 user: '$EC2_UUID'"
SWIFT_UUID=`create_user switch $SERVICE_TENANT_UUID swift`
echo "Swift user: '$SWIFT_UUID'"
ADMIN_ROLE_UUID=`create_role $ADMIN_ROLE`
echo "Admin role: '$ADMIN_ROLE_UUID'"
MEMBER_ROLE_UUID=`create_role memberRole`
echo "Member role: '$MEMBER_ROLE_UUID'"

grant_role $ADMIN_USER_UUID $DEFAULT_TENANT_UUID $ADMIN_ROLE_UUID
echo "Granted admin to $ADMIN_USER_UUID"
grant_role $GLANCE_UUID $SERVICE_TENANT_UUID $ADMIN_ROLE_UUID
echo "Granted admin to $GLANCE_UUID"
grant_role $NOVA_UUID $SERVICE_TENANT_UUID $ADMIN_ROLE_UUID
echo "Granted admin to $NOVA_UUID"
grant_role $EC2_UUID $SERVICE_TENANT_UUID $ADMIN_ROLE_UUID
echo "Granted admin to $EC2_UUID"
grant_role $SWIFT_UUID $SERVICE_TENANT_UUID $ADMIN_ROLE_UUID
echo "Granted admin to $SWIFT_UUID"

nova_service=`create_service nova compute`
echo "Nova service: $nova_service"
volume_service=`create_service volume volume`
echo "Volume service: $volume_service"
glance_service=`create_service glance image`
echo "Glance service: $glance_service"
ec2_service=`create_service ec2 ec2`
echo "EC2 service: $ec2_service"
swift_service=`create_service swift object-store`
echo "Swift service: $swift_service"8774
quantum_service=`create_service quantum network`    
echo "Quantum service: $quantum_service"            

region="RegionOne"

nova_url='http://127.0.0.1:8774/v2/%(tenant_id)s'
volume_url='http://127.0.0.1:8776/v1/%(tenant_id)s'
glance_url='http://127.0.0.1:9292/v1'
ec2_url='http://127.0.0.1:8773/Cloud'
ec2_admin_url='http://127.0.0.1:8773/Admin'
swift_url='http://127.0.0.1:8888/v1/AUTH_%(tenant_id)s'
swift_admin_url='http://127.0.0.1:8888/'
quantum_url='http://127.0.0.1:9696/'

nova_endpoint=`create_endpoint $region $nova_service \
    $nova_url $nova_url $nova_url`
echo "Nova endpoint: $nova_endpoint"

volume_endpoint=`create_endpoint $region $volume_service \
    $volume_url $volume_url $volume_url`
echo "Volume endpoint: $volume_endpoint"

glance_endpoint=`create_endpoint $region $glance_service \
    $glance_url $glance_url $glance_url`
echo "Glance endpoint: $glance_endpoint"

ec2_endpoint=`create_endpoint $region $ec2_service \
    $ec2_url $ec2_url $ec2_admin_url`
echo "EC2 endpoint: $ec2_endpoint"

swift_endpoint=`create_endpoint $region $swift_service \
    $swift_url $swift_url $swift_admin_url`
echo "Swift endpoint: $swift_endpoint"

quantum_endpoint=`create_endpoint $region $quantum_service \
    $quantum_url $quantum_url $quantum_url`
echo "Quantum endpoint: $quantum_endpoint"
