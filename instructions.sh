#!/bin/bash
# Author: Daniel Bowder
# Date: March 25, 2020 17:50 PST


# Variables
METALLB_CONFIG_IP_RANGE="192.168.0.20-192.168.0.29";         # CRITICAL
PLEX_FQDN="plex.k3s.example.com";                            # CRITICAL
METALLB_PLEX_IP="192.168.0.21";                              # CRITICAL
METALLB_CONFIG_NAME="my-release-metallb-config";             # CRITICAL

PLEX_NAMESPACE_NAME="plex";                                  # arbitrary
METALLB_SHARING_KEY="plex";                                  # arbitrary
PLEX_CONFIG_NAME="plex-config";                              # arbitrary
PLEX_CONTAINER_NAME="plex";                                  # arbitrary
PLEX_APP_NAME="plex-app";                                    # arbitrary
PLEX_TCP_SERVICE_NAME="plex-service-tcp";                    # arbitrary
PLEX_UDP_SERVICE_NAME="plex-service-udp";                    # arbitrary



# 1. Install metallb via helm
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm install my-release bitnami/metallb



# 2. Create metallb config yaml
echo "\
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: default
  name: ${METALLB_CONFIG_NAME}
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${METALLB_CONFIG_IP_RANGE}
" > metallb_config.yaml



# 3. Apply metallb_config.yaml
# kubectl apply -f metallb_config.yaml



# 4. Create a plex namespace
echo "\
apiVersion: v1
kind: Namespace
metadata:
  name: ${PLEX_NAMESPACE_NAME}
" > plex_namespace.yaml



# 5. Define the environment variables for the unifi controller
echo "\
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${PLEX_CONFIG_NAME}
  namespace: ${PLEX_NAMESPACE_NAME}
data:
  ADVIERTISE_IP: https://${PLEX_FQDN}:32400/
" > plex_configmap.yaml



# 5. Define the container deployment of the unifi controller
# NOTE: I did not include volumes in this deployment. You will need to
#      setup your own persitent volumes/claims on this deployment.
echo "\
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${PLEX_FQDN}
  namespace: ${PLEX_NAMESPACE_NAME}
  labels:
    app: ${PLEX_APP_NAME}
spec:
  selector:
    matchLabels:
      app: ${PLEX_APP_NAME}
  replicas: 1
  template:
    metadata:
      namespace: ${PLEX_NAMESPACE_NAME}
      labels:
        app: ${PLEX_APP_NAME}
    spec:
      containers:
        - name: ${PLEX_CONTAINER_NAME}
          image: plexinc/pms-docker
          ports:
          - containerPort: 32400
          - containerPort: 32469
          - containerPort: 1900
            protocol: UDP
          - containerPort: 5353
            protocol: UDP
          - containerPort: 32410
            protocol: UDP
          - containerPort: 32412
            protocol: UDP
          - containerPort: 32413
            protocol: UDP
          - containerPort: 32414
            protocol: UDP
          envFrom:
          - configMapRef:
              name: ${PLEX_CONFIG_NAME}
          # Add Persistent Volume Claim
" > plex_deployment.yaml



# 6. Define the services of plex media server in the context of metallb
echo "\
apiVersion: v1
kind: Service
metadata:
  name: ${PLEX_TCP_SERVICE_NAME}
  namespace: ${PLEX_NAMESPACE_NAME}
  annotations:
    metallb.universe.tf/allow-shared-ip: \"${METALLB_SHARING_KEY}\"
spec:
  selector:
    app: ${PLEX_APP_NAME}
  ports:
    - name: pms-1
      port: 32400
      targetPort: 32400
    - name: pms-https
      port: 443
      targetPort: 32400
    - name: pms-http
      port: 80
      targetPort: 32400
    - name: dlna-2
      port: 32469
      targetPort: 32469
  type: LoadBalancer
  loadBalancerIP: ${METALLB_PLEX_IP}
---
apiVersion: v1
kind: Service
metadata:
  name: ${PLEX_UDP_SERVICE_NAME}
  namespace: ${PLEX_NAMESPACE_NAME}
  annotations:
    metallb.universe.tf/allow-shared-ip: \"${METALLB_SHARING_KEY}\"
spec:
  selector:
    app: ${PLEX_APP_NAME}
  ports:
    - name: dlna-1
      protocol: UDP
      port: 1900
      targetPort: 1900
    - name: mdns
      protocol: UDP
      port: 5353
      targetPort: 5353
    - name: gdm-0
      protocol: UDP
      port: 32410
      targetPort: 32410
    - name: gdm-2
      protocol: UDP
      port: 32412
      targetPort: 32412
    - name: gdm-3
      protocol: UDP
      port: 32413
      targetPort: 32413
    - name: gdm-4
      protocol: UDP
      port: 32414
      targetPort: 32414
  type: LoadBalancer
  loadBalancerIP: ${METALLB_PLEX_IP}
" > plex_service.yaml



#7. Apply the yaml files
# kubectl apply -f plex_namespace.yaml -f plex_configmap.yaml -f plex_deployment.yaml -f plex_service.yaml
