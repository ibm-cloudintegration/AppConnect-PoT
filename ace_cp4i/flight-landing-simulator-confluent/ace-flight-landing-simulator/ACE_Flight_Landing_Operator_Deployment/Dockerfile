#12.0.6.0-r1 https://www.ibm.com/docs/en/app-connect/containers_cd?topic=obtaining-app-connect-enterprise-server-image-from-cloud-container-registry
FROM cp.icr.io/cp/appc/ace-server-prod@sha256:3dbcc7caa22b0b0e6a5467cbb1a6086fafa0e125682dee4d2f51b7a59cecc766
COPY *.bar /home/aceuser/initial-config/bars/ 
###COPY *.jar /opt/ibm/ace-12/server/connectors/kafka/
EXPOSE 7600 7800 7843 9483
ENV LICENSE accept
