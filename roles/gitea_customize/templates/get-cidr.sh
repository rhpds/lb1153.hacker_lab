    JOB_SUCCEEDED=$(oc get job {{ gitea_customize_gitea_user_name_base }}1-start-lab -n default --ignore-not-found=true --output json | jq -r '.status.succeeded')

    if [ "${JOB_SUCCEEDED}" == "1" ]; then

      CLUSTER_ID=$(curl -ks -u {{ gitea_customize_stackrox_admin_user }}:{{ gitea_customize_stackrox_admin_password }} https://{{
      gitea_customize_stackrox_endpoint }}/v1/clusters | jq -r '.clusters[] | select(.name=="production").id')

      if [ -z "${CLUSTER_ID}" ]; then

        exit 1

      fi

      DEPLOYMENT_ID=$(curl -ks -u {{ gitea_customize_stackrox_admin_user }}:{{ gitea_customize_stackrox_admin_password }} https://{{
      gitea_customize_stackrox_endpoint }}/v1/networkgraph/cluster/${CLUSTER_ID} | jq -r '.nodes[] | select(.entity.type == "DEPLOYMENT" and .entity.deployment.name == "quarkus-template" and .entity.deployment.namespace == "customers-{{
      gitea_customize_gitea_user_name_base }}1").entity.id')

      if [ -z "${DEPLOYMENT_ID}" ]; then

        exit 1

      fi

      CIDR=$(curl -ks -u {{ gitea_customize_stackrox_admin_user }}:{{ gitea_customize_stackrox_admin_password }} https://{{
      gitea_customize_stackrox_endpoint }}/v1/networkgraph/cluster/${CLUSTER_ID}/externalentities/flows/${DEPLOYMENT_ID} | jq -r '.flows[] | select(.props.dstEntity.type == "EXTERNAL_SOURCE").props.dstEntity.externalSource.cidr')

      if [ ! -z "${CIDR}" ]; then

        echo $CIDR

      else

        exit 1

      fi

    else

      exit 1

    fi