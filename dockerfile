FROM ubi8:latest AS builder
COPY $REMOTE_SOURCE $REMOTE_SOURCE_DIR

WORKDIR $REMOTE_SOURCE_DIR/app

FROM registry.redhat.io/openshift4/ose-ansible-operator:v4.6.0

COPY --from=builder $REMOTE_SOURCE_DIR/app/vendor /tmp/vendor

RUN ansible-galaxy collection install --force /tmp/vendor/galaxy.ansible.com/kubernetes/core/kubernetes-core-1.1.1.tar.gz -p ${HOME}/.ansible/collections \
  && ansible-galaxy collection install --force /tmp/vendor/galaxy.ansible.com/operator_sdk/util/operator_sdk-util-0.1.0.tar.gz -p ${HOME}/.ansible/collections \
  && chmod -R ug+rwx ${HOME}/.ansible

COPY --from=builder $REMOTE_SOURCE_DIR/app/main.yml ${HOME}/main.yml

COPY --from=builder $REMOTE_SOURCE_DIR/app/watches.yaml ${HOME}/watches.yaml

COPY --from=builder $REMOTE_SOURCE_DIR/app/roles/ ${HOME}/roles/

ENV DESCRIPTION="Red Hat Ansible Automation Controller Operator" \
    container=oci

LABEL com.redhat.component="automation-controller-operator-container" \
      name="ansible-automation-platform-20-early-access/controller-rhel8-operator" \
      version="2.0.0" \
      summary="${DESCRIPTION}" \
      io.openshift.expose-services="" \
      io.openshift.tags="automation,ansible" \
      io.k8s.display-name="automation-controller-operator" \
      maintainer="Ansible Automation Platform Productization Team" \
      description="${DESCRIPTION}"
