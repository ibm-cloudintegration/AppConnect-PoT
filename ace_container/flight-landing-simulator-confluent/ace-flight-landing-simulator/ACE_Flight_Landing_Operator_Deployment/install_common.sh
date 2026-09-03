# Make Sure to Logon to OpenShift cluster before this running this script.

echo "Begin... make sure to pass BAR_URL"

ACE_LICENSE=$1
BAR_URL=$2
echo "ACE license=$ACE_LICENSE"
echo "BAR_URL=$BAR_URL"
if [ "$#" -ne 2 ]; then
    echo "Invalid number of parameters, please pass <ACE_LICENSE> <BAR_URL (get barurl from ace dashboard)>"
    exit 1
fi

EVENTSTREAMS_NAMESPACE=cp4i-eventstreams
EVENTSTREAMS_INSTANCE=es-demo
ACE_NAMESPACE=cp4i-ace
INTEGRATION_RUNTIME=ace-tk-flight-landing-simulator
# DEPLOY_PROJECT_NAME=ace-flight-landing-simulator/ACE_Flight_Landing_Operator_Deployment
DEPLOY_PROJECT_NAME=.
KAFKA_SCRAM_USER=kafka-connect-credentials

BOOTSTRAP_URL=`oc get -n $EVENTSTREAMS_NAMESPACE EventStreams $EVENTSTREAMS_INSTANCE -o json | grep 443 | grep bootstrap | cut -d \" -f 4`


BAR_URL2=$(echo $BAR_URL | sed -e "s~\/~\\\/~g")

# Download Event Streams certificates
echo "Downloading es-cert pem, p12 certficates and password"
oc get -n $EVENTSTREAMS_NAMESPACE secret es-demo-cluster-ca-cert -o jsonpath="{.data.ca\.crt}" | base64 -d > es-cert.pem
oc get -n $EVENTSTREAMS_NAMESPACE secret es-demo-cluster-ca-cert -o jsonpath="{.data.ca\.p12}" | base64 -d > es-cert.p12
ES_CERT_PASSWORD=`oc get -n $EVENTSTREAMS_NAMESPACE secret es-demo-cluster-ca-cert -o jsonpath="{.data.ca\.password}" | base64 -d`

# Generating es-cert.jks on the kafka pods.
echo "Generating es-cert.jks file"

oc -n $EVENTSTREAMS_NAMESPACE exec -it es-demo-kafka-2 -- /bin/bash -c "cd /tmp && rm es-cert.*"

# copy es-cert.pemto kafka pod
oc -n $EVENTSTREAMS_NAMESPACE cp es-cert.pem es-demo-kafka-2:/tmp

oc -n $EVENTSTREAMS_NAMESPACE exec -it es-demo-kafka-2 -- /bin/bash -c "cd /tmp && keytool -import -noprompt \
        -alias escertca \
        -file es-cert.pem \
        -keystore es-cert.p12 -storepass passw0rd"

oc -n $EVENTSTREAMS_NAMESPACE exec -it es-demo-kafka-2 -- /bin/bash -c "cd /tmp && keytool -importkeystore -srckeystore es-cert.p12 \
        -srcstoretype PKCS12 \
        -destkeystore es-cert.jks \
        -deststoretype JKS \
        -srcstorepass passw0rd \
        -deststorepass passw0rd \
        -noprompt"

oc -n $EVENTSTREAMS_NAMESPACE cp es-demo-kafka-2:/tmp/es-cert.p12 ./es-cert.p12
oc -n $EVENTSTREAMS_NAMESPACE cp es-demo-kafka-2:/tmp/es-cert.jks ./es-cert.jks


echo "Updating dev.policyxml bootstrapServers with $EVENTSTREAMS_INSTANCE bootstrapURL"
# Update policy.xml bootstrapServers URL
echo $BOOTSTRAP_URL 

sed "s/<bootstrapServers>.*<\/bootstrapServers>/<bootstrapServers>"$BOOTSTRAP_URL"<\/bootstrapServers>/" \
        ../es-policy-project/dev.policyxml > ../es-policy-project/dev.policyxml.new
mv ../es-policy-project/dev.policyxml.new ../es-policy-project/dev.policyxml

# Create es-policy.zip file
echo "Creating es-policy.zip"
rm es-policy.zip
pwd
cd ..
pwd
zip -r es-policy.zip es-policy-project
cd -
pwd
mv ../es-policy.zip .

ls -l 

######## Create ACE Configuration for Kafka Policy 
echo "Creating kafka-policy-temp.yaml"

ESPOLICY_CONF=$(base64 -i es-policy.zip)

sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~replace-with-policy-base64~${ESPOLICY_CONF}~" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/kafka-policy.yaml > es-policy-temp.yaml

#######
echo "Creating setdbparms.txt"
# create setdbparms.txt 
ES_KAFKA_USER_PASSWORD=`oc get -n $EVENTSTREAMS_NAMESPACE secret $KAFKA_SCRAM_USER -o jsonpath="{.data.password}" | base64 -d`

echo "kafka::myKafkaSecId $KAFKA_SCRAM_USER $ES_KAFKA_USER_PASSWORD
truststore::truststorePass dummy passw0rd" > setdbparms.txt

#######
echo "Creating setdbparms-temp.yaml"
# Create ACE Configuraiton for setdbparms.txt 
setdbparms=$(base64 -i setdbparms.txt) 
sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~replace-with-setdbparms-base64~${setdbparms}~" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/setdbparms.yaml > setdbparms-temp.yaml 

######## Create ACE Configuration for Event Streams TrustStore
echo "Creating truststore-temp.yaml"
truststore=$(base64 -i es-cert.jks)
sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~ace-tk-flight-landing-truststore-es-cert~es-cert.jks~" \
    -e "s~replace-with-truststore-base64~${truststore}~" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/truststore.yaml > truststore-temp.yaml

######## Create ACE Configuration for Serverconf
echo "Creating server-conf-temp.yaml"
serverconf=$(base64 -i $DEPLOY_PROJECT_NAME/ConfigurationInputs/server.conf.yaml)
sed -e "s/replace-with-namespace/${Namespace}/" -e "s~replace-with-serverconf-base64~${serverconf}~" $DEPLOY_PROJECT_NAME/ConfigurationResources/server.conf.yaml > server-conf-temp.yaml 

######## Update IntegrationRuntime.yaml
echo "Creating IntegrationRuntime-temp.yaml"
sed -e "s/replace-with-integration-runtime/${INTEGRATION_RUNTIME}/" \
    -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s/replace-with-artifactory-url.*/$BAR_URL2'/"  \
    -e "s/- artifactory-barauth-conf//"  \
    -e "s/- es-kafka-policy-conf/- ace-tk-flight-landing-es-policy-conf/"  \
    -e "s/- es-kafka-setdbparms-conf/- ace-tk-flight-landing-setdbparms-conf/"  \
    -e "s/- mq-mqdv03-policy-conf//"  \
    -e "s/license: L.*/license: $ACE_LICENSE/"  \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/IntegrationRuntime.yaml > IntegrationRuntime-temp.yaml

### APPLY THE YAMLS

echo "Creating App Connect Configurations"
# oc project $ACE_NAMESPACE
oc -n $ACE_NAMESPACE apply -f es-policy-temp.yaml
oc -n $ACE_NAMESPACE apply -f setdbparms-temp.yaml
oc -n $ACE_NAMESPACE apply -f server-conf-temp.yaml
oc -n $ACE_NAMESPACE apply -f truststore-temp.yaml
oc -n $ACE_NAMESPACE apply -f IntegrationRuntime-temp.yaml

echo "Complete"
