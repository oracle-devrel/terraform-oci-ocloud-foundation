#!/bin/bash

# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

if [ ${ol} = 8 ]; then
  dnf config-manager --enable ol8_developer && dnf -y install python3-oci-cli 
else
  yum -y -t update --security
  yum install -y python3
  pip3 install oci-cli
fi

sed -i -e "s/autoinstall\s=\sno/autoinstall = yes/g" /etc/uptrack/uptrack.conf
uptrack-upgrade -y