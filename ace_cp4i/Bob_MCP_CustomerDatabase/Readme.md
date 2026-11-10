# App Connect - Exposing Customer Database REST API as an MCP Server in IBM Bob

[Return to MQ lab page](../index.md)

---

# Table of Contents
- [1. Overview](#overview)
- [2. Signup to IBM Bob](#signup)
- [3. App Connect Dashboard](#ace-dashboard)
	* [3a. Deploy Customer Database REST API](#ace-dashboard-deploy-cdb)
	* [3b. Create MCP Server ](#ace-dashboard-create-mcp)
- [4. IBM Bob](#ibm-bob)
	* [4a. Add Customer Database MCP Server](#ibm-bob-add-mcp)
- [5. Sample Prompts](#prompts)
- [6. Summary](#summary)

---

## 1. Overview <a name="overview"></a>

In this lab, you will deploy Customer Database REST API into IBM App Connect on Cloud Pak for Integration, then you will create an Model Context Protocol (MCP) server in App Connect which will be used in IBM Bob. <br>
<br>

## 2. Signup to IBM Bob <a name="signup"></a>

Signup for IBM Bob 30-day free trial. <br>

https://bob.ibm.com/trial

<br>

![alt text](./images/image.png)

![alt text](./images/image-1.png)

![alt text](./images/image-2.png)

![alt text](./images/image-3.png)

<br>


## 3. App Connect Dashboard <a name="ace-dashboard"></a>

### 3a. Deploy Customer Database REST API <a name="ace-dashboard-deploy-cdb"></a>

For this lab, we already have the REST service built and available as a **bar** file. You can download the **CustomerDatabaseV3.bar** file for the service [<u>**here**</u>](./resources/CustomerDatabaseV3.bar).
<br>

Open IBM App Connect Dashboard from the Cloud Pak for Integration Platform Navigator, and click on Deploy Integrations. <br>

![alt text](./images/image-13.png)

Click Quick Start , then click \<Next\>. <br>

![alt text](./images/image-14.png)


![alt text](./images/image-15.png)

![alt text](./images/image-16.png)

![alt text](./images/image-17.png)

![alt text](./images/image-18.png)

![alt text](./images/image-19.png)

![alt text](./images/image-20.png)

<br><br>

### 3b. Create MCP Server <a name="ace-dashboard-create-mcp"></a>

![alt text](./images/image-4.png)

![alt text](./images/image-5.png)

![alt text](./images/image-6.png)

![alt text](./images/image-7.png)

![alt text](./images/image-8.png)

![alt text](./images/image-9.png)

![alt text](./images/image-10.png)

![alt text](./images/image-11.png)

Capture MCP Server URL, and Basic Auth Credentials. <br>

![alt text](./images/image-12.png)
<br>


## 4. IBM Bob <a name="ibm-bob"></a>

Open the IBM Bob IDE, and navigate to Settings <br>

### 4a. Add Customer Database MCP Server <a name="ibm-bob-add-mcp"></a>

![alt text](./images/image-21.png)

Navigate to MCP. <br>

![alt text](./images/image-22.png)

Click + sign. <br>

![alt text](./images/image-23.png)

![alt text](./images/image-24.png)

![alt text](./images/image-25.png)
Append the below between the curly braces. <br>
```
    "customer-database-v3": {
        "url": "",
        "headers": {
            "Authorization": ""
        }
    }
```

![alt text](./images/image-26.png)

Now, populate the url, and Authorization values from the MCP Server created in the App Connect Dashboard. <br>

![alt text](./images/image-27.png)

![alt text](./images/image-28.png)

Now, save and close mcp.json. <br>

Notice that customer-databasev-v3 is connected to the MCP server. <br>

![alt text](./images/image-29.png)


## 5. Prompts <a name="prompts"></a>


![alt text](./images/image-30.png)

Click on Approve. <br>

![alt text](./images/image-31.png)

Notice that Bob called the backend MCP server and the REST API and retrived list of customers. <br>

![alt text](./images/image-32.png)

Let's add few Customers using below prompt. <br>
```
add customer, firstname Joe, lastname Jodl, address 144 marina drive, edison, nj, zip code 11111-1111
```
Notice that Bob automatically formed the JSON payload for addCustomer operation. <br>
![alt text](./images/image-33.png)

Click "Approve Once". <br>

Notice that Customer 11 was created Successfully.
![alt text](./images/image-34.png)

## 6. Summary <a name="summary"></a>

Congratulations! You have exposed an APP Connect REST API as an MCP server into IBM Bob, and ran prompts to retrieve and add new customers through Natural Language prompts using IBM Bob. <br>
<br>

[Return to ACE lab page](../index.md)