#!/bin/bash

BUILDAH='buildah'
echo "Pull registry.centos.org/centos:latest"
CNAME=$($BUILDAH from registry.centos.org/centos:latest)
echo "Install repos"
$BUILDAH run $CNAME -- yum install -q -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
$BUILDAH run $CNAME -- yum install -q -y https://yum.puppet.com/puppet5-release-el-7.noarch.rpm
echo "Updating system"
$BUILDAH run $CNAME -- yum update -q -y > /dev/null 2>&1
echo "Install packages"
$BUILDAH run $CNAME -- yum install -q -y iproute puppet-agent.x86_64 vim less > /dev/null 2>&1
#for p in iproute puppet-agent.x86_64 vim less; do
#  echo "- $p"
#  $BUILDAH run $CNAME -- yum install -q -y $p > /dev/null 2>&1
#done
echo
if [[ -d ./files ]]; then
  CMNT=$($BUILDAH mount $CNAME)
  echo "### Copy ./files dir to container mount: $CMNT"
  cp -va ./files/* ${CMNT}/root/
fi
$BUILDAH run $CNAME -- yum clean all
echo
echo "Testing puppet agent"
$BUILDAH run $CNAME -- /opt/puppetlabs/bin/puppet apply -e 'notice("It Works!")'
echo
echo "Building image..."
$BUILDAH commit $CNAME img-puppet-agent
$BUILDAH rm $CNAME
echo "Built img-puppet-agent"
echo
echo "Example: podman run --rm -it -v \$(pwd)/files:/work:Z -w /work img-puppet-agent"

