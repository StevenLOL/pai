#!/bin/bash

# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pushd $(dirname "$0") > /dev/null

echo "Call stop.sh to stop all hadoop service first"
/bin/bash stop.sh

echo "Create hadoop-name-node-delete configmap for deleting data on the host"
kubectl create configmap hadoop-name-node-delete --from-file=hadoop-name-node-delete/

echo "Create cleaner daemon"
kubectl create -f delete.yaml
sleep 5

PYTHONPATH="../.." python -m  k8sPaiLibrary.monitorTool.check_pod_ready_status -w -k app -v delete-batch-job-hadoop-name-node

echo "Hadoop-name-node clean job is done"
echo "Delete hadoop-name-node cleaner daemon and configmap"
kubectl delete ds delete-batch-job-hadoop-name-node
kubectl delete configmap hadoop-name-node-delete
sleep 5

popd > /dev/null