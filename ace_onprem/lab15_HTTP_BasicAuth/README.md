# Secure API's with Basic Authentication 

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment](#lab-env)
- [3. App Connect Toolkit](#toolkit)
	* [3a. Import Tutorial ](#tutorial-import)
	* [3b. Create Integration Server](#is-create)
	* [3c. Deploy the Application and Flow](#deploy-flow)
	* [3d. Test the API](#test-api)
- [4. Secure the API](#secure-api)
	* [4a. Create Credential](#create-credential)
	* [4b. Create Security Profile Policy](#create-policy)
	* [4c. Enable Security Profile on HTTPInput Node](#enable-policy)
	* [4d. Create Security Profile Policy](#create-policy)
- [5. Deploy Projects](#deploy-2)	
- [6. Testing with Basic Authentication](#test-2)
- [7. Summary](#summary)
- [8. Deploying to App Connect on OpenShift](#deploy-3)
	* [8a. Extract credentials as Vault Archive](#vault-archive)
	* [8b. Create MyPolicies.zip ](#zip-policy)
	* [8c. Upload BAR file to App Connect Dashboard](#bar-upload)
	* [8d. Create Vault Archive Configuration](#vault-archive-config)
	* [8e. Create Vault Archive Key Configuration](#vault-archive-key-config)
	* [8f. Create Policy Project Configuration](#policy-project-config)
	* [8g. Create Integration Runtime](#ir-create)
- [9. Testing the API Deployed on OpenShift](#testing-3)
	* [9a. Capture the API endpoint](#endpoint)
	* [9b. Test the API  ](#testing-4)
- [10. Summary](#summary-2)
- [11. References](#references)

---

# 1. Introduction <a name="introduction"></a>

In this lab, you will learn how to secure an API with Basic Authentication. You can authenticate HTTP clients that want to call a HTTP API by enabling HTTP Basic Authentication. IBM App Connect Enterprise supports several authentication providers that can be used for this purpose, including Lightweight Directory Access Protocol (LDAP), any WS-Trust V1.3 compliant Security Token Service (STS), and Tivoli® Federated Identity Manager.

<br>

# 2. Workshop Environment  <a name="lab-env"></a>

You will be doing this lab from the Windows VM. <br>

![alt text](./images/env.png)

<br>


# 3. App Connect Toolkit  <a name="ace-toolkit"></a>

Open IBM App Connect Toolkit from the desktop or from the taskbar. You can use the default workspace or set to C:\Users\techzone\IBM\ACET13\workspace\ace-workshop. <br>

![alt text](./images/toolkit.png)

If are greeted with Welcome page, then close it. <br>
<br>


## 3a. Import Tutorial <a name="tutorial-import"></a>

Instead of building the API from the scratch, let's reuse an existing Tutorial. App Connect Enterprise provides several Tutorials, and Patterns as part of the Toolkit. <br>

Import "Using an HTTP Input to drive a message flow" tutorial. Navigate to Help > Tutorial Gallery > search for HTTP and hit \<ENTER\>. Click on \<Start\>, then \<import\>. <br>

![alt text](./images/image.png)

After it's imported, you should see the Message Flow as below. <br>

![alt text](./images/image-1.png)

Click on the HTTPInput Node, and notice that the URL or the Basepath is defined as "/HTTPInnputMessageFlow". That is the URL we will be using to test the API. <br>

![alt text](./images/image-7.png)

<br>


## 3b. Create Integration Server <a name="is-create"></a>

Right click on "Integration Servers", then click on "Create a local integration server". <br>

![alt text](./images/image-2.png)

Let's create TEST_SERVER with an External directory vault. Set the External directory valut key as "passw0rd". <br>

![alt text](./images/image-3.png)

Click **\<Create vault\>**. <br>

![alt text](./images/image-4.png)

Click **\<Finish\>**. <br>

The TEST_SERVER will be started automatically. <br>

<br>


## 3c. Deploy the Application and Flow <a name="deploy-flow"></a>

Drag and drop the HTTPInputApplication into the Integration Server TEST_SERVER. <br>

![alt text](./images/image-5.png)

Close the confirmation window, the flow should be deployed as below. <br>

![alt text](./images/image-6.png)

Notice the API Endpoint for our Message flow. <br>

![alt text](./images/image-8.png)

<br>


## 3d. Test the API <a name="test-api"></a>

At this point, this API "HTTPInputMessageFlow" is not enabled with any security. Let's test it with curl from a Terminal window. Follow below step to open a Terminal in App Connect Toolkit. <br>

**Open Terminal** by navigating the Menu, Window > Show View > Other > Terminal then click on Terminal. <br>

![alt text](./images/image-19.png)

Click on "Open a Terminal" Icon. <br>

![alt text](./images/image-20.png)



Copy / Paste the below to test the API. <br>
```
curl http://localhost:7800/HTTPInputMessageFlow -d "{\"InputField1\":\"Hello\", \"InputField2\":\"World\"}"
```

![alt text](./images/image-9.png)

Note that there isn't any security, hence you are able to call the API without passing any credentials. <br>
<br>


# 4. Secure the API <a name="secure-api"></a>

Now, let's secure and protect our API by enabling Basic Authentication by using the following steps. <br>


## 4a. Create Credential  <a name="create-credential"></a>

First, let's create security Credential in our External Directory Vault. Remember that that the Vault was created during creating of the Integration Server. <br>

Run the below command from the Terminal that was opened previously. <br>

```
mqsicredentials --ext-vault-dir C:\Users\techzone\IBM\ACET13\workspace\ace-workshop\TEST_EXT_DIR_VAULT --ext-vault-key passw0rd --create --credential-type local --credential-name MYAPI_BASIC_AUTH_CREDENTIAL_ALIAS --username apiuser --password passw0rd
```

![alt text](./images/image-16.png)


## 4b. Create Security Profile Policy <a name="create-policy"></a>

Create a New Policy Project, name it "MyPolicies". <br>

![alt text](./images/image-10.png)

Create New Policy. <br>

![alt text](./images/image-11.png)

Name the policy as "BasicAuthentication" as below. <br>

![alt text](./images/image-12.png)

Pick "Security Profiles" type. The "Security Profiles" template will be automatically selected. Now populate the properties as below. <br>

Authentication: Local <br>
Authentication configuration: MYAPI_BASIC_AUTH_CREDENTIAL_ALIAS <br>

![alt text](./images/image-13.png)

Save the Policy. <br>



## 4c. Enable Security Profile on HTTPInput Node  <a name="enable-policy"></a>

Switch to the Message flow, and configure HTTPInput node, Security policy as below. <br>

**Security profile:** {MyPolicies}:BasicAuthentication <br>
**Identify token type: Username + Password** (Select from the dropdown) <br>

![alt text](./images/image-14.png)

SAVE the flow. <br>

<br>


# 5. Deploy Projects   <a name="deploy-2"></a>

Let's deploy the "MyPolicies": Policy Project, and "HTTPInputMessageFlow" Application. <br>

![alt text](./images/image-15.png)




# 6. Testing with Basic Authentication  <a name="test-2"></a>

Now, let's re-test our API same as you tested above without passing any security. <br> 

Copy / Paste the below to test the API. <br>
```
curl http://localhost:7800/HTTPInputMessageFlow -d "{\"InputField1\":\"Hello\", \"InputField2\":\"World\"}"
```

![alt text](./images/image-17.png)

Notice that, the API has failed due to the Security was enabled and we didn't pass security credentials. THAT IS EXPECTED! <br>

Now, let's call the API with security credentials. <br>

Copy/paste the below command. <br>
```
curl -H "Authorization: Basic YXBpdXNlcjpwYXNzdzByZA==" http://http-basicauth-test-http-cp4i-ace.apps.68f19488fe8d8ce89eab7672.am1.techzone.ibm.com/HTTPInputMessageFlow -d "{\"InputField1\":\"Hello\",\"InputField2\":\"World\"}"
```

Note that "YXBpdXNlcjpwYXNzdzByZA==" is base64 encoded user:password that you have used in mqsicredentials command. <br>

```
INFO ONLY! DO NOT RUN THIS. This is how to encode user:password.
echo -n "apiuser:passw0rd" | base64
```

![alt text](./images/image-18.png)

Notice above that the API ran successfully. <br>

<br>


# 7. Summary <a name="summary"></a>

Congratulations! You have successfully enabled Basic Authentication for your API. <br>



**NOTE:** If you are working on standalone App Connect labs then STOP here. <br>
If, you are working on Cloud Pak for Integraiton labs then CONTINUE to the next sections. <br>
<br>


# 8. Deploying to App Connect on OpenShift <a name="deploy-3"></a>

Follow the below procedures to extract credentials from the External directory Vault, as well as creating a bar file to be imported into App Connect Dashboard on OpenShift. <br>

## 8a. Extract credentials as Vault Archive <a name="vault-archive"></a>


Run the following command on the Terminal to extract Vault Archive zip file. <br>

```
ibmint export credentials  --external-directory-vault C:\Users\techzone\IBM\ACET13\workspace\ace-workshop\TEST_EXT_DIR_VAULT --external-directory-vault-key passw0rd --archive-location C:\Users\techzone\Downloads\vault_archive.zip --archive-key passw0rd
```
![alt text](./images/image-21.png)


## 8b. Create MyPolicies.zip <a name="zip-policy"></a>


Right click on MyPolicies, click Export. <br>

![alt text](./images/image-36.png)

Locate  "Archive File", under "General" section. <br>

![alt text](./images/image-37.png)


Archive to Downloads folder C:\Users\techzone\Downloads\mypolicy-project.zip <br>

![alt text](./images/image-38.png)




## 8c. Upload BAR file to App Connect Dashboard <a name="bar-upload"></a>


Open Browser and logon to App Connect Dashboard. <br>

Click on "Bar Files" <br>

![alt text](./images/image-22.png)

Click on \<Import BAR file\>. <br>

![alt text](./images/image-23.png)

Drag and drop bar file from the Toolkit to ACE Dashboard on OpenShift, then click \<import\> <br>

![alt text](./images/image-24.png)

Bar file is uploaded to ACE Dashboard. <br>

![alt text](./images/image-25.png)



## 8d. Create Vault Archive Configuration <a name="vault-archive-config"></a>


Now click on "Configurations" feature. <br>
![alt text](./images/image-26.png)

Click \<Create Configuration\> button. <br>

![alt text](./images/image-28.png)

Drag and drop vault-archive.zip that was created in step 7a. <br>

![alt text](./images/image-27.png)

Hit \<Create\>. 

![alt text](./images/image-29.png)


## 8e. Create Vault Archive Key Configuration <a name="vault-archive-key-config"></a>

Just as above, let's create "Vault Archive Key" Configuration. <br>

![alt text](./images/image-30.png)

Click \<Create\>.

<br><br>




## 8f. Create My Policy Project Configuration <a name="policy-project-config"></a>


Click \<Create Configuration\> button. <br>

Select "Policy Project", and name it as below. Then, drag-n-drop mypolicy-project.zip from Downloads folder. <br>

![alt text](./images/image-39.png)

Click \<Create\>.

![alt text](./images/image-40.png)

<br>


## 8g. Create Integration Runtime <a name="ir-create"></a>

Click on Home icon on the left, then click on "Deploy Integrations" tile. <br>

![alt text](./images/image-31.png)

Click on "Quick start integration" tile, then click \<Next\>. <br>

Select our BAR file, then click \<Next\>. <br>

![alt text](./images/image-32.png)

Select myapi-security-policym myapi-vault-archive, myapi-vault-archive-key configurations, then click \<Next\>. <br>


![alt text](./images/image-33.png)

Change name to my-basicauth-api, then click \<Create\>.. <br>

![alt text](./images/image-34.png)


Refresh screen and make sure the Integration Runtime is Ready. <br>

![alt text](./images/image-35.png)

<br>




# 9. Testing the API Deployed on OpenShift <a name="testing-3"></a>

## 9a. Capture the API endpoint <a name="endpoint"></a>

Click on the Integration Runtime (my-basicauth-api). <br>

Then, click on "HTTPInputApplication". <br>

Then click on "HTTPInputMessageFlow".  <br>

Copy the URL. <br>

![alt text](./images/image-41.png)


## 9b. Test the API <a name="testing-4"></a>

From the Toolkit's Terminal view, copy / paste the below. <br>

```
curl REPLACE_WITH_COPIED_URL -d "{\"InputField1\":\"Hello\", \"InputField2\":\"World\"}"
```

![alt text](./images/image-42.png)


Now, test with Basic Auth credentials as below. <br>

```
curl -H "Authorization: Basic YXBpdXNlcjpwYXNzdzByZA==" REPLACE_WITH_COPIED_URL -d "{\"InputField1\":\"Hello\",\"InputField2\":\"World\"}"
```

![alt text](./images/image-43.png)

Now the API worked with the correct credentials. <br><br>

# 10. Summary <a name="summary-2"></a>

Congratulations! You have successfully enabled Basic Authentication for your API, and deployed to App Connect Dashboard on Cloud Pak for Integration and OpenShift. <br>



# 11. References <a name="references"></a>

HTTPInput Node: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=nodes-httpinput-node" target="_blank"> https://www.ibm.com/docs/en/app-connect/13.0.x?topic=nodes-httpinput-node </a>

<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)