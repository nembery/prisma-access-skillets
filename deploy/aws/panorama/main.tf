############################################################################################
# Copyright 2020 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.resource_group}-paloaltonetworks-deployment"
  public_key = var.public_key

  tags = {
    "panhandler_resource_group" : var.resource_group
  }
}
resource "aws_resourcegroups_group" "test" {
  name = "test-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "panhandler_resource_group",
      "Values": ["${var.resource_group}"]
    }
  ]
}
JSON
  }
}

data "aws_ami" "panorama-vm" {
  most_recent = true
  owners = [
    '679593333241']
  # owner id for Paloaltonetworks

  filter {
    name = "name"
    values = [
      "Panorama-AWS-${var.panorama_version}*"]
  }
}

resource "aws_instance" "panorama" {
  ami = data.aws_ami.panorama-vm.id
  instance_type = "m4.2xlarge"
  key_name = aws_key_pair.key_pair.id

  ebs_optimized = true

//  network_interface {
//    device_index = 0
//    network_interface_id = aws_network_interface.panorama_mgmt.id
//  }

  tags = {
    "panhandler_resource_group" : var.resource_group
  }
}

//resource "aws_network_interface" "panorama_mgmt" {
//  subnet_id = var.subnet_id
//  private_ips = [
//    var.mgmt_ip
//  ]
//  security_groups = [
//    var.mgmt_sg_id
//  ]
//
//  tags = {
//    "panhandler_resource_group" : var.resource_group
//  }
//}
