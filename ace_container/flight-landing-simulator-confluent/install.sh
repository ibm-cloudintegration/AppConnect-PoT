#
# PreReq: make sure to download kafka-ca.crt from Techzone Confluent Reservation.
# 
# 
echo "Begin..."

BAR_URL=$1

source ./global.properties

echo "BAR_URL=$BAR_URL"

if [ "$#" -ne 1 ]; then
    echo "Invalid number of parameters, please pass <BAR_URL (get barurl from ace dashboard)>"
    exit 1
fi

if [ ! -f "./kafka-ca.crt" ]; then
    echo "kafka-ca.crt File does not exist. Download from TZ Confluent Reservation."
    exit 1
fi

# Make Sure to Logon to OpenShift cluster before this running this script.
OCP_CLUSTER=$(oc project | cut -d ':' -f 2 | sed 's/\///g')
if [[ -z "${OCP_CLUSTER// /}" ]]; then
  echo -e "error: You must be logged in to the server (Unauthorized)"
  exit 1
fi

echo "$OCP_CLUSTER - is this the correct cluster y/n?: "
read var1

if [ $var1 == 'y' ]
then
   echo ""
else
   echo "Sorry"
   exit 0
fi


DEPLOY_PROJECT_NAME=ace-flight-landing-simulator/ACE_Flight_Landing_Operator_Deployment

BAR_URL2=$(echo $BAR_URL | sed -e "s~\/~\\\/~g")

# Download Confluent Certificates
echo "Generating confluent-cert.jks file"

rm kafka-ca.p12 confluent-cert.jks

# downloaded kafka-ca.crt from the TZ reservation

keytool -import -noprompt \
        -alias escertca \
        -file kafka-ca.crt \
        -keystore kafka-ca.p12 -storepass passw0rd

keytool -importkeystore -srckeystore kafka-ca.p12 \
        -srcstoretype PKCS12 \
        -destkeystore confluent-cert.jks \
        -deststoretype JKS \
        -srcstorepass passw0rd \
        -deststorepass passw0rd \
        -noprompt

echo "Updating dev.policyxml bootstrapServers with $EVENTSTREAMS_INSTANCE bootstrapURL"
# Update policy.xml bootstrapServers URL
echo $BOOTSTRAP_URL 

sed -e "s/<bootstrapServers>.*<\/bootstrapServers>/<bootstrapServers>${BOOTSTRAP_URL}<\/bootstrapServers>/" \
    -e "s/es-cert/confluent-cert/" \
    -e "s/SCRAM-SHA-512/PLAIN/" \
    ace-flight-landing-simulator/es-policy-project/dev.policyxml \
    > ace-flight-landing-simulator/es-policy-project/dev.policyxml.new


mv ace-flight-landing-simulator/es-policy-project/dev.policyxml.new ace-flight-landing-simulator/es-policy-project/dev.policyxml


# Create es-policy.zip file
echo "Creating es-policy.zip"
rm es-policy.zip
pwd
cd ace-flight-landing-simulator
pwd
zip -r ../es-policy.zip es-policy-project
cd -
pwd

echo "Creating kafka-policy-temp.yaml"
# Create ACE Configuration for Kafka Policy 
ESPOLICY_CONF=$(base64 -i es-policy.zip)

sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~replace-with-policy-base64~${ESPOLICY_CONF}~" \
    -e "s/ace-tk-flight-landing-es-policy-conf/ace-tk-flight-landing-confluent-policy-conf/" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/kafka-policy.yaml > kafka-policy-temp.yaml

echo "Creating setdbparms.txt"
# create setdbparms.txt 

echo "kafka::myKafkaSecId $KAFKA_SCRAM_USER $KAFKA_SCRAM_PASSWORD
truststore::truststorePass dummy passw0rd" > setdbparms.txt

echo "Creating setdbparms-temp.yaml"
# Create ACE Configuraiton for setdbparms.txt 
setdbparms=$(base64 -i setdbparms.txt) 
sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~replace-with-setdbparms-base64~${setdbparms}~" \
    -e "s/ace-tk-flight-landing-setdbparms-conf/ace-tk-flight-landing-confluent-setdbparms-conf/" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/setdbparms.yaml > setdbparms-temp.yaml 

# Create ACE Configuration for Event Streams TrustStore
echo "Creating truststore-temp.yaml"
truststore=$(base64 -i confluent-cert.jks)
sed -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s~ace-tk-flight-landing-truststore-es-cert~confluent-cert.jks~" \
    -e "s~replace-with-truststore-base64~${truststore}~" \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/truststore.yaml > truststore-temp.yaml


# Create ACE Configuration for Serverconf
echo "Creating server-conf-temp.yaml"
serverconf=$(base64 -i $DEPLOY_PROJECT_NAME/ConfigurationInputs/server.conf.yaml)
sed -e "s/replace-with-namespace/${Namespace}/" \
    -e "s~replace-with-serverconf-base64~${serverconf}~" \
    $DEPLOY_PROJECT_NAME/ConfigurationResources/server.conf.yaml > server-conf-temp.yaml 


# Update IntegrationRuntime.yaml
echo "Creating IntegrationRuntime-temp.yaml"
sed -e "s/replace-with-integration-runtime/${INTEGRATION_RUNTIME}/" \
    -e "s/replace-with-namespace/${ACE_NAMESPACE}/" \
    -e "s/replace-with-artifactory-url.*/$BAR_URL2'/"  \
    -e "s/- artifactory-barauth-conf//"  \
    -e "s/- es-kafka-policy-conf/- ace-tk-flight-landing-confluent-policy-conf/"  \
    -e "s/- es-kafka-setdbparms-conf/- ace-tk-flight-landing-confluent-setdbparms-conf/"  \
    -e "s/- es-cert.jks/- confluent-cert.jks/"  \
    -e "s/- mq-mqdv03-policy-conf//"  \
    -e "s/license: L.*/license: $ACE_LICENSE/"  \
    ${DEPLOY_PROJECT_NAME}/ConfigurationResources/IntegrationRuntime.yaml > IntegrationRuntime-temp.yaml

### APPLY THE YAMLS

echo "Creating App Connect Configurations"
# oc project $ACE_NAMESPACE
oc -n $ACE_NAMESPACE apply -f kafka-policy-temp.yaml
oc -n $ACE_NAMESPACE apply -f setdbparms-temp.yaml
oc -n $ACE_NAMESPACE apply -f server-conf-temp.yaml
oc -n $ACE_NAMESPACE apply -f truststore-temp.yaml
oc -n $ACE_NAMESPACE apply -f IntegrationRuntime-temp.yaml

echo "Complete"
