# Using IBM Cloud Object Storage discovery Connector

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment](#workshop-env)
- [3. App Connect Toolkit](#toolkit)
- [4. CreateBucket Message Flow](#create-bucket-msgflow)
  * [4a. Configure HTTPInput Node](#configure-httpinput)
  * [4b. Configure Mapping Node](#configure-mapping)
  * [4c. Configure IBM Cloud Object Storage S3 Request Node](#configure-ibmcos)
- [5. CreateItem Message Flow](#create-item-msgflow)
  * [5a. Configure HTTPInput Node](#configure-httpinput)
  * [5b. Configure Mapping Node](#configure-mapping)
  * [5c. Configure IBM Cloud Object Storage S3 Request Node](#configure-ibmcos)
- [6. Deployment](#deployment)
- [7. Testing ](#testing)
  * [7a. Testing CreateBucket Flow](#testing-bucket)
  * [7a. Testing CreateItem Flow](#testing-item)
- [8. Summary ](#summary)

---

<br>

## 1. Introduction <a name="introduction"></a>

In this lab, you will explore IBM App Connect Enterprise (ACE) Toolkit's IBM Cloud Object Storage Discovery Connector for creating a Bucket and an Object. We have provided other Object Storage connectors such as Amazon S3 as well. Please check the list of connectors in the Toolkit pallete. <br>

**What is a discovery connector?** <brA
A discovery connector node is a connector node that contains properties whose values are set through a process of connector discovery, by using the Connector Discovery wizard that is provided with the IBM® App Connect Enterprise Toolkit. <br>
Reference: https://www.ibm.com/docs/en/app-connect/13.0.x?topic=use-discovery-connector-nodes



## 2. Workshop Environments  <a name="workshop-env"></a>

![alt text](./images/image-0.png)

You will be doing this lab from the Windows VM. <br>

**IBM Cooud Object Storage Access, and Credentials:** Please make sure your instructor provides IBM COS credentials. <br>

<br>

## 3. App Connect Toolkit <a name="toolkit"></a>
Open IBM App Connect Toolkit, create workspace discovery_connectors. <br>
![alt text](./images/image.png)

You will be greeted with the IBM App Connect Enterprise Toolkit Welcome page. <br>
![alt text](./images/image-1.png)

Create New Application, name it: ObjectStorageApp <br>
![alt text](./images/image-2.png)

<br>


## 4. CreateBucket Message Flow <a name="create-bucket-msgflow"></a>

Create New Message Flow, call it CreateBucket <br>
![alt text](./images/image-3.png)

Drag HttpInput, Mapping, "IBMCloudObjectStorage S3 Request", and Mapping Nodes into the Message flow canvas, and wire them as below. <br>
![alt text](./images/image-4.png)

<br>


### 4a. Configure HttpInput Node <a name="configure-httpinput"></a>

Under the Basic tab, set "Path suffix for URL" as /ibmcos-create-bucket
![alt text](./images/image-5.png)

![alt text](./images/image-6.png)

<br>



### 4b. Configure IBM Cloud Object Storage S3 Request Node <a name="configure-ibmcos"></a>

Click on "IBM Cloud Object Storage S3 Request" node. <br>

Click 'Launch Connector Discovery" button under the Properties pane, and Basic tab.  <br>
![alt text](./images/image-10.png)

**Note:** Use the credentials provided by the instructor. <br>

Create New Policy. <br>
![alt text](./images/image-12.png)

Enter MyPolicies as the Policy Project name. <br>
![alt text](./images/image-11.png)

Enter "passw0rd" for the Value Key. Click "Create an External directory vault" <br>
![alt text](./images/image-13.png)

Click Launch Discovery. <br>
![alt text](./images/image-14.png)

Locate "Create Bucket" function. <br>
![alt text](./images/image-15.png)

Click \<Connect\>. <br>
![alt text](./images/image-16.png)

Enter the credentials provided above, then click \<Connect\> <br>
![alt text](./images/image-17.png)


Enter Bucket name as student(n)-bucket, where (n) is your student number. <br>
![alt text](./images/image-18.png)

<br>

Hit the \<Save\> button on the top and close the wizard. <br>

<br><br>


### 4c. Configure Mapping Node <a name="configure-mapping"></a>

Double click on the Mapping Node. <br>
![alt text](./images/image-7.png)


Click \<Next\> <br>

Select "CreateBucket_Request" JSON Model, then click <Finish>. <br>

![alt text](./images/image-8.png)

Expand JSON segment, and drag on the "Name" field, that should create "Assign" action. In the General tab, set Value as "student(yournumber)-bucket as below. <br>
![alt text](./images/image-9.png)

Save the map, and click on the Message Flow tab. <br><br>


Save the Message Flow from the File Menu or hit Control key and s. <br>

<br> <br>



## 5. CreateItem Message Flow <a name="create-item-msgflow"></a>

Create New Message Flow, call it CreateItem <br>

![alt text](./images/image-27.png)

![alt text](./images/image-28.png)


Drag FileInput, Compute, and "IBMCloudObjectStorage S3 Request" into the Message flow canvas, and wire them as below. <br>
![alt text](./images/image-29.png)

<br>


### 5a. Configure FileInput Node <a name="configure-fileinput"></a>

Under the Basic tab, set "Input Directory" (C:\Users\techzone\Downloads), and "File name or pattern" as below. <br> 
![alt text](./images/image-30.png)

Under Input Message Parsing, select BLOB. <br>
![alt text](./images/image-31.png)

<br>

### 4b. Configure Compute Node <a name="configure-compute"></a>

Double click on the Compute Node. <br>

Copy and paste the below lines as in the picture. <br>
```
		-- The Object name to be created
		SET OutputRoot.JSON.Data.Key = InputLocalEnvironment.File.Name;
		-- Object Content
		SET OutputRoot.JSON.Data.content = ASBITSTREAM(InputBody);
		-- Object Content Type
		SET OutputRoot.JSON.Data.contentType = 'text/plain';
```
![alt text](./images/image-32.png)

Save and close the ESQL editor. <br>


### 5c. Configure IBM Cloud Object Storage S3 Request Node <a name="configure-ibmcos"></a>

Click on "IBM Cloud Object Storage S3 Request" node. <br>

Click 'Launch Connector Discovery" button under the Properties pane, and Basic tab.  <br>

Select "MyPolicies" project, then click \<Launch Discovery\> button. <br>
![alt text](./images/image-34.png)

Locate "Create Object" function, and click to open. <br>
![alt text](./images/image-35.png)

Pickup as below, then \<Save\> and close the Connector discovery wizard. <br>
![alt text](./images/image-36.png)


Save the Message Flow. <br><br>




## 6. Deployment <a name="deployment"></a>

Create a Local Integration Server. <br>
![alt text](./images/image-19.png)

Choose the defaults, and click Finish. <br>
![alt text](./images/image-20.png)

Drag and drop MyPolicies project into the Integration Server TEST_SERVER. <br>
![alt text](./images/image-21.png)
<br>

Similarly, drag and drop ObjectStorageApp project into the Integration Server TEST_SERVER as well. <br>
![alt text](./images/image-22.png)

<br><br>


## 7. Testing <a name="testing"></a>

First lets test CreateBucket flow, then CreateItem flow. <br>

### 7a. Testing CreateBucket Flow <a name="testing-bucket"></a>
Lets use the Flow Exerciser to test the API. <br>
![alt text](./images/image-23.png)

Click \<Yes\>, if you get "The artifact is already deployed" dialog. <br>

Check "Do not show the warnings" dialog, and \<Ok\> button. <br>

Now, click "Send Message" button. <br>
![alt text](./images/image-24.png)

Enter empty JSON (open, close curly brackets as below), then click \<Send\>. <br>
![alt text](./images/image-25.png)

If successful, you should see like below. <br>
![alt text](./images/image-26.png)

Click \<Close\> and stop Flow Exerciser. Now, your bucket should be created in IBM Cloud Object Storage. <br>

Logon to IBM Cloud with the user/password provided in the beginning then check Storage under the Resource List. Make sure the Bucket is created.<br><br>



### 7b. Testing CreateItem Flow <a name="testing-item"></a>
Lets use the Flow Exerciser to test the API. <br>



Download,
[<b><u>dummy.txt</u></b>](./resources/dummy.txt) <br>

THe file will be downloaded to C:\Users\techzone\Downloads folder. The CreateItem Message flow should pick up the file as soon its downloaded. The flow, then should deliver the file to IBM Cloud Object storage bucket. <br>

Login to IBM Cloud and check the bucket and objects. If successful, you should see the object as below. <br>

![alt text](./images/image-37.png)

![alt text](./images/image-38.png)


<br>

## 6. Summary <a name="summary"></a>

Congratulations! You have effectively explored the Cloud Object Storage Discovery connector and are capable of creating both a Bucket and an Object.<br>


<br><br>


## 9. INSTRUCTOR Notes <a name="notes"></a>

IBM Cloud Object Storage details: <br>

Instructor: make sure to provision IBM COS techzone environment then create credential, then update the below. <br>

a) Provision IBM Cloud OBject storage from Techzone. <br>
b) Once provisioned, logon with the URL, and user/password to the IBM Cloud and Resource List > Storage. <br>

```
IBM Cloud Login: https://cloud.ibm.com/authorize/xxxxx
Username: xxxx
Password: yyyyyy
````
c) Create Service Credential with Manager access. <br>

d) Capture apikey, and resouceinstanceid <br>

```
Endpoint URL: s3.us.cloud-object-storage.appdomain.cloud
API Key: xxxxx
Resource Instance ID: crn:v1:bluemix:public:cloud-object-storage:global:a/xxxx:3bcfbdc5-a67d-473c-87d8-xxxxxx::
```
Provide the above 3 values to students. <br>

<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)