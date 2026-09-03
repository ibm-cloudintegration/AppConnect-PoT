# Kafka_APIs_Operator_Deployment
This sample deployment project performs below tasks:
  - Create IntegrationServer Configuration CR for Truststore
  - Create IntegrationServer Configuration CR for Setdbparms
  - Create IntegrationServer Configuration CR for Policy project ( In this example Kafka Policy)
  - Create IntegrationServer Configuration CR for Server.conf.yaml
  - Reference these CRs into the IntegrationServer CRD (Kafka_APIs.yaml) and deploy it

The ConfigurationInputs folder contains the below files:
# ConfigurationInputs/es-cert.p12
Either PKCS12 or JKS truststores can be configured. Since APIs contained in this project, connect to IBM EventStreams, this es-cert.p12 has been downloaded from IBM EventStreams. Content of this file is base64 encoded and seeded into truststore.yaml before creating the CR for truststore. This step is being done in jenkinsfile during deployment.

# ConfigurationInputs/kafka_policy.zip
This is the zipped policy project that may contain one or more policies. In this case, it contains kafka_policy, which is referenced in Kafka Producer and Consumer nodes of the API flows. The kafka_policy project is also checked-into github for the reference: https://github.com/awasthan/kafka_policy.git
Content of this file is base64 encoded and seeded into policyProject.yaml before creating the CR for policy project. This step is being done in jenkinsfile during deployment.

# ConfigurationInputs/setdbparms.txt
This file contains the parameters for security identifiers. In this case it contains the password to open the truststore and password for the ace-consumer to conenct to Kafka cluster (EventStreams).
Content of this file is base64 encoded and seeded into setdbparms.yaml before creating the CR for policy project. This step is being done in jenkinsfile during deployment.

# ConfigurationInputs/server.conf.yaml
This file contains the configuration parameters for IntegrationServer. In this case, only below configuration has been overwritten under ResourceManagers.JVM

truststoreType: 'PKCS12'
    truststoreFile: '/home/aceuser/truststores/es-cert.p12'
    truststorePass: 'ace-server::truststorePass'
Content of this file is base64 encoded and seeded into server.conf.yaml.yaml before creating the CR for policy project. This step is being done in jenkinsfile during deployment.

Below files inside ConfigurationResources folder are the CRDs for Truststore, Policy, Setdbparms and server.conf.yaml. Namespace and Content is being dynamically overwritten in jenkinsfile.
- policyProject.yaml
- server.conf.yaml
- setdbparms.yaml
- truststore.yaml

Below file is the CRD for IntegrationServer and referenced to the above four CRs:
- Kafka_APIs_IS.yaml

The jenkinsfile performs below steps:
- Checks-out the project
- Pulls the BAR files for the mentioned two ACE APIs from the Nexus repository
- Creates a custom image by baking in BAR files using the Dockerfile
- Pushes the baked image to OCP registry
- Creates the four CRs for the IntegrationServer
- Creates the CR for the IntegrationServer

The script handles the install and upgrade of IntegrationServer.
