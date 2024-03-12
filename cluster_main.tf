data ibm_resource_group "resource_group" {
    name = "sh-rg"
}
resource ibm_container_cluster "tfcluster" {
name            = "tfclusterdoc"
datacenter      = "dal10"
machine_type    = "b3c.4x16"
hardware        = "shared"
public_vlan_id  = "2234945"
private_vlan_id = "2234947"

kube_version = "1.21.9"

default_pool_size = 3
    
public_service_endpoint  = "true"
private_service_endpoint = "true"

resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool_zone_attachment" "dal12" {
cluster         = ibm_container_cluster.tfcluster.id
worker_pool     = ibm_container_cluster.tfcluster.worker_pools.0.id
zone            = "dal12"
private_vlan_id = "<private_vlan_ID_dal12>"
public_vlan_id  = "<public_vlan_ID_dal12>"
resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool_zone_attachment" "dal13" {
cluster         = ibm_container_cluster.tfcluster.id
worker_pool     = ibm_container_cluster.tfcluster.worker_pools.0.id
zone            = "dal13"
private_vlan_id = "<private_vlan_ID_dal13>"
public_vlan_id  = "<public_vlan_ID_dal13>"
resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool" "workerpool" {
    worker_pool_name = "tf-workerpool"
    machine_type     = "u3c.2x4"
    cluster          = ibm_container_cluster.tfcluster.id
    size_per_zone    = 2
    hardware         = "shared"

    resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool_zone_attachment" "tfwp-dal10" {
cluster         = ibm_container_cluster.tfcluster.id
worker_pool     = element(split("/",ibm_container_worker_pool.workerpool.id),1)
zone            = "dal10"
private_vlan_id = "<private_vlan_ID_dal10>"
public_vlan_id  = "<public_vlan_ID_dal10>"
resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool_zone_attachment" "tfwp-dal12" {
cluster         = ibm_container_cluster.tfcluster.id
worker_pool     = element(split("/",ibm_container_worker_pool.workerpool.id),1)
zone            = "dal12"
private_vlan_id = "<private_vlan_ID_dal12>"
public_vlan_id  = "<public_vlan_ID_dal12>"
resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_container_worker_pool_zone_attachment" "tfwp-dal13" {
cluster         = ibm_container_cluster.tfcluster.id
worker_pool     = element(split("/",ibm_container_worker_pool.workerpool.id),1)
zone            = "dal13"
private_vlan_id = "<private_vlan_ID_dal13>"
public_vlan_id  = "<public_vlan_ID_dal13>"
resource_group_id = data.ibm_resource_group.resource_group.id
}


resource "null_resource" "delete-default-worker-pool" {
    provisioner "local-exec" {
    command = "ibmcloud ks worker-pool rm --cluster ${ibm_container_cluster.tfcluster.id} --worker-pool ${ibm_container_cluster.tfcluster.worker_pools.0.id}"
    }
}
