#!/bin/bash
# helper script to deploy given service with given tag to k8s infrastructure

set -e

if [ $# -lt 2 ]; then
     echo "The required parameters for service and tag are missing. Please use deploy-srv.sh <service> <tag> <env> "
     exit 1;
fi

# example output:
# CURRENT   NAME      CLUSTER                      AUTHINFO        NAMESPACE
#           preprod   cmsweb-k8s-prodsrv-v1.22.9   openstackuser   dmwm
# *         test11    cmsweb-test11                cmsweb-test11   dmwm
cluster_name=$(kubectl config get-contexts | grep "[*]" | awk '{print $3}')

check=true

if [ $# -ne 3 ]; then
	if [[ "$cluster_name" == *"prodsrv-v1.22.9" ]] ; then
		env="preprod"
	fi
	if [[ "$cluster_name" == *"prodsrv" ]] ; then
                env="prod"
        fi
	if [[ "$cluster_name" == *"preprod"* ]] ; then
		env="prod"
	fi
        if [[ "$cluster_name" == *"cmsweb-auth"* ]] ; then
                env="auth"
        fi
	if [[ "$cluster_name" == *"cmsweb-test1" ]] ; then
                env="test1"
		echo "test1"
        fi
        if [[ "$cluster_name" == *"cmsweb-test2" ]] ; then
                env="test2"
        fi
        if [[ "$cluster_name" == *"cmsweb-test3" ]] ; then
                env="test3"
        fi
        if [[ "$cluster_name" == *"cmsweb-test4" ]] ; then
                env="test4"
        fi
        if [[ "$cluster_name" == *"cmsweb-test5" ]] ; then
                env="test5"
        fi
        if [[ "$cluster_name" == *"cmsweb-test6" ]] ; then
                env="test6"
        fi
        if [[ "$cluster_name" == *"cmsweb-test7" ]] ; then
                env="test7"
        fi
        if [[ "$cluster_name" == *"cmsweb-test8" ]] ; then
                env="test8"
        fi
        if [[ "$cluster_name" == *"cmsweb-test9" ]] ; then
                env="test9"
        fi
        if [[ "$cluster_name" == *"cmsweb-test10" ]] ; then
                env="test10"
        fi
        if [[ "$cluster_name" == *"cmsweb-test11" ]] ; then
                env="test11"
        fi
        if [[ "$cluster_name" == *"cmsweb-test12" ]] ; then
                env="test12"
        fi
        if [[ "$cluster_name" == *"cmsweb-test13" ]] ; then
                env="test13"
        fi
	
fi
srv=$1
cmsweb_image_tag=:$2

if [ $# == 3 ]; then
	env=$3
fi

cmsweb_env=k8s-$env
cmsweb_log=logs-cephfs-claim-prod

tmpDir=/tmp/$USER/k8s/srv

# use tmp area to store service file
if [ -d $tmpDir ]; then
    rm -rf $tmpDir
fi
mkdir -p $tmpDir

cp ./services/$srv.yaml $tmpDir/$srv.yaml
cd $tmpDir
# curl -ksLO https://raw.githubusercontent.com/dmwm/CMSKubernetes/master/kubernetes/cmsweb/services/$srv.yaml


# check that service file has imagetag
if [ -z "`grep imagetag $srv.yaml`" ]; then
    echo "unable to locate imagetag in $srv.yaml"
    exit 1
fi
echo "The downloaded and newly generated service manifest files are available at $tmpDir"
echo "Using Environment: $cmsweb_env"

# replace imagetag with real value and deploy new service
if [ "$cmsweb_env" == "k8s-prod" ] ; then

      cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" > $srv.yaml.new
      cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | kubectl apply -f -

elif  [ "$cmsweb_env" == "k8s-preprod" ] ; then

	if [ "$srv" == "crabserver" ] ; then

            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | sed -e 's+crabserver/prod+crabserver/preprod+g' >  $srv.yaml.new

            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | sed -e 's+crabserver/prod+crabserver/preprod+g' |  kubectl apply -f -

        elif [[ "$srv" == "dbs-global-r"  || "$srv" == "dbs-global-w"  ||  "$srv" == "dbs-migrate"  ||  "$srv" == "dbs-phys03-r" || "$srv" == "dbs-phys03-w" || "$srv" == "dbs2go-global-r" || "$srv" == "dbs2go-global-w" || "$srv" == "dbs2go-phys03-r" || "$srv" == "dbs2go-phys03-w" || "$srv" == "dbs2go-global-m" || "$srv" == "dbs2go-phys03-m" || "$srv" == "dbs2go-global-migration" || "$srv" == "dbs2go-phys03-migration" ]] ; then
            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | sed -e 's+dbs/prod+dbs/int+g' >  $srv.yaml.new

            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | sed -e 's+dbs/prod+dbs/int+g' |  kubectl apply -f -
        elif [[ "$srv" == "reqmgr2"  || "$srv" == "reqmon"  ||  "$srv" == "t0_reqmon" ||  "$srv" == "t0wmadatasvc" ]] ; then
            cat $srv.yaml | sed -e "s,1 #PROD# 5,2,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" >  $srv.yaml.new

            cat $srv.yaml | sed -e "s,1 #PROD# 5,2,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | kubectl apply -f -
	else
            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" >  $srv.yaml.new

            cat $srv.yaml | sed -e "s,1 #PROD#,,g" | sed -e "s,#PROD#,      ,g" |  sed -e "s,logs-cephfs-claim,$cmsweb_log,g" | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g" | kubectl apply -f -
        fi	

elif [ "$srv" == "crabserver" ]; then
            cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+crabserver/prod+crabserver/preprod+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g"  >  $srv.yaml.new
            cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+crabserver/prod+crabserver/preprod+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g" | kubectl apply -f -
 
elif  [[ "$cmsweb_env" == "k8s-auth" ]] && [[ "$srv" == "dbs2go-global-r" || "$srv" == "dbs2go-global-w" || "$srv" == "dbs2go-phys03-r" || "$srv" == "dbs2go-phys03-w" || "$srv" == "dbs2go-global-m" || "$srv" == "dbs2go-phys03-m" || "$srv" == "dbs2go-global-migration" || "$srv" == "dbs2go-phys03-migration" ]] ; then
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+dbs/prod+dbs/int+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g"  >  $srv.yaml.new
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+dbs/prod+dbs/int+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g"  | kubectl apply -f - 
elif [[ "$srv" == "dbs-global-r"  || "$srv" == "dbs-global-w"  ||  "$srv" == "dbs-migrate"  ||  "$srv" == "dbs-phys03-r" || "$srv" == "dbs-phys03-w" || "$srv" == "dbs2go-global-r" || "$srv" == "dbs2go-global-w" || "$srv" == "dbs2go-phys03-r" || "$srv" == "dbs2go-phys03-w" || "$srv" == "dbs2go-global-m" || "$srv" == "dbs2go-phys03-m" || "$srv" == "dbs2go-global-migration" || "$srv" == "dbs2go-phys03-migration" ]] ; then
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+dbs/prod+dbs/dev+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g"  >  $srv.yaml.new
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" |  sed -e 's+dbs/prod+dbs/dev+g' | sed -e "s,k8s #k8s#,$cmsweb_env,g"  | kubectl apply -f -
else 
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g"  > $srv.yaml.new
        cat $srv.yaml | sed -e "s, #imagetag,$cmsweb_image_tag,g" | sed -e "s,k8s #k8s#,$cmsweb_env,g"  | kubectl apply -f -
fi

# return to original directory
cd -

set +e

