# IBM AppConnect Labs
![](images\ACE-page.png)
## What is IBM App Connect?
IBM App Connect is a solution for connecting applications, data, and APIs, whether they are in the cloud or on-premises. 

**IBM App Connect Enterprise Product Page:** [Click here](https://www.ibm.com/products/app-connect)


## Lab Abstracts

**App Connect Enterprise Basic labs** <br>

|  Subject                            | Description                                            |                                                               
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [ESQL Experience](ace_onprem/lab17_Transform_ESQL/README.md)       | In this lab, you will develop a straightforward message flow to transform data from one XML format to another XML format utilizing a Compute node and ESQL code.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Mapping Node Experience](ace_onprem/lab18_Transform_Mapping/README.md)       | In this lab, you will develop a straightforward message flow to transform data from one XML format to JSON format utilizing a Mapping node.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [JavaCompute Experience](ace_onprem/lab19_Transform_JavaCompute/README.md)       | In this lab, you will develop a straightforward message flow to transform data from one XML format to JSON format utilizing a JavaCompute node.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [RESTRequest Petstore API](ace_onprem/lab20_Petstore_API/README.md)       | In this lab, you will learn how to invoke Petstore external OpenAPI 3.0 API using RESTRequest Node. 
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Debugging a message flow](ace_onprem/lab7_debugging_msgflows/README.md)       | Examine the Message Flow Debugger within the App Connect Toolkit. Utilize the flow debugger to investigate payloads, message headers, context trees, and environment trees across different sections of the Message flows. Discover the process of establishing breakpoints to analyze the activities occurring within the flow.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Build Rest service with Local Designer](ace_onprem/lab5a_designer_flow/README.md)       | App Connect Designer is the browser-based (web) development environment used to create integrations and flows in IBM App Connect.  Using a low-code / no-code approach.  You access it through a browser — no desktop installation required.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [MSSQL & ODBC](ace_onprem/lab8_mssql_odbc_compute/README.md)       | Databases - Using a Compute node to insert data into a MSSQl database via ODBC. Discover the process of setting up an MSSQL database within a container, and how to connect to the HRDB database for the purpose of inserting EMPLOYEE records into the EMPLOYEES table. Investigate the steps to create Vault and ODBC Credentials, and subsequently configure the Compute Node in the message flow to utilize ODBC.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [HTTP Basic Authentication](ace_onprem/lab15_HTTP_BasicAuth/README.md)       | Discover the methods to protect your APIs using HTTP Basic Authentication. Import the tutorial titled "Using an HTTP Input to drive a message flow" and set up the HTTPInput node to activate Basic Authentication. Furthermore, acquire knowledge on how to implement the Message Flow, Security Profiles, Vault-archive, Vault-archive-key policies, and the Bar files onto the App Connect dashboard within Containers.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Unit testing](ace_onprem/lab4_unit_testing/README.md)       | Discover the process of conducting unit testing for an App Connect Message flow.
|-----------------------------|------------------------------------------------------------------------------------------------------------|

<br><br>


**App Connect Enterprise Advanced labs** <br>

|  Subject                            | Description                                            |                                                               
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Customer REST API](ace_onprem/lab1_customer_database_restapi/README.md)       | Discover the process of developing REST APIs using IBM App Connect Toolkit. Construct a basic Customer REST API.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Change Data Capture Node](ace_onprem/lab2_cdc_postgres/README.md)       | Discover the utilization of the Change Data Capture Node in App Connect Toolkit to extract records from a Postgres database.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Salesforce Discovery Connector](ace_onprem/lab5_discovery_connector/README.md)       | Explore the  Salesforce Discovery Connector within the App Connect Toolkit. Develop a straightforward message flow to establish connection to Salesforce and retrieve a full Contact record.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Cloud Object Storage Discovery Connector](ace_onprem/lab6_discovery_connector_IBMCOS/README.md)       | Explore the IBM Cloud Object Storage Request S3 Discovery Connector within the App Connect Toolkit. Develop a straightforward message flow to establish connection to Cloud Object Storage, Create Bucket and Create Objects to it.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Kafka Event Serialization](ace_onprem/lab3_avro_kafka/README.md)       | Discover the utilization of Kafka nodes within the App Connect Toolkit and the serialization of the payload using an AVRO schemas.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Context Trees](ace_onprem/lab12_Context_Trees/README.md)       | An introduction to the Context Tree, which was first introduced in ACE version 13.0.4.0.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Global Cache](ace_onprem/lab11_inmemory_global_cache/README.md)       | Utilizing the in-memory embedded global cache functionality of App Connect version 13.0.3.0.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [ACE with MQ Native HA](ace_onprem/lab10_ace_with_mqnativeha/README.md)       | Utilizing the App Connect Toolkit Message Flow to connect to a NativeHA Queue Manager running on Linux, and Read from, Write to MQ Native HA Queues.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Container Explorer](ace_onprem/lab13_Container_Explorer/README.md)       | Utilizing the App Connect Toolkit's Container Explorer feature to establish connection to App Connect Dashboard deployed onto OpenShift, then explore, manage Integration Runtimes and bar files.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Activity Logs](ace_onprem/lab9_log_node/README.md)       | Learn how to use the Log node within the Message flow of the App Connect Toolkit to create Activity Logs.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Introduction to FTE Nodes](ace_onprem/lab14_Using_FTE_Nodes/README.md)       | Discover the process of establishing a simple MQ Managed File Transfer (MQMFT) network, creating MQMFT Agents, and ultimately integrating MQMFT into the App Connect Toolkit Flow through the utilization of FTEInput and FTEOutput Nodes.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [Message Modeling, Mapping, JDBC](ace_onprem/lab16_DFDL_Mapping_JDBC_DB2/README.md)       | Learn how to utilize IBM App Connect Toolkit to create a Message Model from the ground up to parse tab-delimited records. Subsequently, you configure the FileInput Node to read files, followed by Mapping Node to map & insert each record into DB2 database table.
|-----------------------------|------------------------------------------------------------------------------------------------------------|
| [ Basic Auth to send HTTP Requests ](ace_onprem/lab21_HTTPRequest_BasicAuth/README.md)       | This tutorial demonstrates how to send HTTP Request messages from a message flow running in ACE to a back-end web service which is secured using Basic Authentication.
|-----------------------------|------------------------------------------------------------------------------------------------------------|


