# App Connect Designer ServiceNow Smart Connector

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment](#workshop-env)
- [3. Live Environment Setup](#live-setup)
- [4. Connect to the ServiceNow with Smart connector](#smart-connector)
- [5. Build a Designer API](#designer)
  * [5a. Test Designer API operation](#designer1)
  * [5b. Add another Designer API operation](designer3)
  * [5c. Test new Operation API](designer4)
- [6. Summary ](#summary)

---

<br>

## 1. Introduction <a name="introduction"></a>

In this lab, we will show the new Designer Flow capability in the (software based) Designer Flow Editor in v13.
In this lab you will create a Designer API flow to get ServiceNow Incidents.

 ![alt text](images/Designer_lab2.png)

## 2. Workshop Environments  <a name="workshop-env"></a>

The reserved Techzone environment which will have 6 RHEL VMs, and 1 WIndows VM. <br>
For this lab we will be using only the windows vm image.  <br>

Click on the Windows image console to open it.

   ![alt text](images/image.png)

<br>


## 3. Live Environment Setup <a name="live-setup"></a>

1. From the Windows console click on the **CAD** to get to the login page.  Click on OK for the Business Use Notice

   ![alt text](images/win1.png)

1. Login to the windows using techzone/IBMDem0s

   ![alt text](images/win2.png)

1. Click on the **1 ACE Designer** icon on the desktop. <br><br>At first you will see a window launched which looks a bit like an **2 ACE Command Console**. This window initials the Designer process, which actually also involves creating a runtime integration server which will be used whenever you want to test out a message flow. <br><br>   After a few seconds, the Designer process will be ready and a **3 web browser tab** will be opened ready for you to use. As you use Designer to create message flows, we will be connecting to various applications and third party systems, so Designer requires a means of safely storing the credentials and secrets which are used to access them securely. ACE uses its vault technology for this purpose. When first used, a vault key must be entered (and then repeated for confirmation). Use the value **passw0rd** and then click the Create vault button:


   ![alt text](images/design1.png)

You will be doing this lab from the Windows VM. <br>
## 4. Connect to the ServiceNow with Smart connector <a name="smart-connector"></a>


1. We will first connect to the ServiceNow account from the Smart connector.  <br> From the home page click the **Connect** and select the *Applications and APIs*

   We will from the Search enter ServiceNow.
 ![alt text](images/config1.png)

1. We will now select the **Connect** button.  
   ![alt text](images/config2.png)

1. Next fill in the form with the following info and Click **Connect**

   ```Account Name: mySNow
      endpoint url: https://dev274093.service-now.com
      username: admin
      password: SNow-PoT-June2025!
      clientId: 542ddf82bd75221091cb43eeda47a1ef
      clientSecret: 2g(j[0Raho
   ```
   ![alt text](images/config3.png)



1. It should show connected.   Now select **Home** on left menu. 
   ![alt text](images/config4.png)


## 5. Build a Desiger API <a name="designer1"></a>

1. You will now be back on the Designer landing page.  You will notice that you can select to **Create an event-driven flow or Import a existing flow**

   For this lab we will be **Create flows for an API**

   Click on that tile.

   ![alt text](./images/design2.png)

1. First thing we will do is create the model for are API. We will call the model **SNowIncidents**. Also in the upper left, we will change the Name from Untitled to **SNowRetrieveIncidents**.

   Click Create model.

   ![alt text](./images/design3.png)

1.  We will now add the following properties which are all data type String.

      Use the Add property + to add more fields to your model.

      You can also set  the data type to Number for properties containing numerical integer values if it is needed. For this they will all be strings.

      ```
      IncidentNumber
      OpenDate
      Descripton
      State
      Priority
      Category
      ```
      When you have defined the properties in our API model definition, we can implement a flow by clicking on the **Operations tab**
   
      ![alt text](./images/design4.png)

1. From the Operations drop-down menu **"Select an operation to add"**, select **Add a Custom Operation**. Here we will customize the operation that we want our API to perform. 

1. Customize the details of your API operation. 

   ```
    * Display Name: **Retrieve Incidents**
    * HTTP Verb: **GET** 
    * Operation Name: **incidents**
        * Note: The operation name will be a part of your API Endpoint URL and is therefore consumer-facing.
    * Response body: **SNowIncidents**
   ```
      When ready Click the **Implement flow**

   ![alt text](./images/design5.png)


1. This will take us to the App Connect Designer flow. This is where we can insert Smart Connectors to communicate with a variety of external applications as well as implement conditional logic and callable flows. 

   ![alt text](./images/design6.png)

1. You will now have a *Request* and *Response* nodes for your API.  
   Click on the **+**

   That will open a new panel with the smart connectors.   You will see the ServiceNow connector on top since we already connected to it. 

   Click on the icon on the right side to move that panel to the right for easier viewing.

      ![alt text](./images/design7.png)



1. You will now see the ServiceNow account connected.   Select the **Incident** and select the **Retrieve Incidents**

   ![alt text](./images/design8.png)

1. Change the maximum number to say 5 and instead of throwing an error process 5 items. 

   Next a key features is that as you build flows you can test them as you go.  Click on the **Test action**

   ![alt text](./images/design9.png)

1. Will will see a window asking if you what to Try this action.  Click **Continue**

   You should see a Test result of 200 OK.   Click on the **View details**

   ![alt text](./images/design10.png)
  
  
 1.  You will see the test results (only for 3 items) and can open them and see live data that was retrieved from ServiceNow for the test. 

      Once done close the Test results window. 

      ![alt text](./images/design11.png)

1. We will now populate the response for this request. <br> Click on the **Response icon**.

   We will only what to get the Incident numbers for this request since it will return 5 of them. <br> Click on the mapping icon for **IncidentNumber** and under the Retrieve incidents select number.

    ![alt text](./images/design12.png)

1. You should see the **Number** in the Response body.   

   Click **Done**
    ![alt text](./images/design13.png)

### 5a. Test Desiger API operation <a name="designer2"></a>

1. We will now test the first operation.   Click on the **Test API**

   ![alt text](./images/design14.png)

1. Window will open click the **Don't show...** checkbox.<br> Click **Test**

   ![alt text](./images/design15.png)

1. Click the **Test** on menu bar  
   
   ![alt text](./images/design16.png)

1. You will now be on the API page.   We only have one operation right now.  Select the incidnets operation. <br> Select **Try it** <br> Click on **Send** 
    
   ![alt text](./images/design17.png)
    
1.   You Can see the Request that was sent as the Reponse should show a 201. The body will contain the first 5 incidents numbers.

      Click **Stop test**

      ![alt text](./images/design18.png)

### 5b. Add another Desiger API operation <a name="designer3"></a>

1. From the Operations drop-down menu **"Select an operation to add"**, select **Retrieve SNowIncidents by ID**. 

   ![alt text](./images/designID1.png)

1. You will now see the new Operation and When ready Click the **Implement flow**

   ![alt text](./images/designID2.png)

1. You will now have a *Request* and *Response* nodes for your API.  
   Click on the **+**

   That will open a new panel with the smart connectors.   You will see the ServiceNow connector on top since we already connected to it. 

   Click on the icon on the right side to move that panel to the right for easier viewing.

      ![alt text](./images/designID3.png)

1. You will now see the ServiceNow account connected.   Select the **Incident** and select the **Retrieve Incidents**

   ![alt text](./images/designID4.png)

1. We will now select a **Add condition** for this operation.

   ![alt text](./images/designID5.png)

1. Now for the *Where* condition we will select **Number**

   ![alt text](./images/designID6.png)
  
  
 1.  To complete the *Where clause* we will need what the number will equal.  
 
      Click on the **Mapping icon**

      For the Available mappings we will use the **Request URL parameter** and select the **IncidentNumber**

      ![alt text](./images/designID7.png)
     
      It should look like this. 
      ![alt text](./images/designID8.png)

1. We will now populate the response for this request. <br> Click on the **Response icon**.

   For the response we will populate the *Response body* 
   
   Click on the *mapping icon** and you can scroll down to see all data sent back from the *ServiceNow* connector.  
   Here we are selecting **Number** for the **IncidentNumber**.  

    ![alt text](./images/designID9.png)

1. We will want to map all the fields in the Response body.

      Another way to find the field is to start typing what you are looking for when you see it you can **Click** on it. 
      
      Continue till you have all filled in.

      ![alt text](./images/designID10.png) 
1. When done it should look similar to this.  
   Click **Done**

   ![alt text](./images/designID11.png)

### 5c. Test new Operation API  <a name="designer4"></a>

1. We will now test the new operation for getting a single item.  Click on **Test API** in the upper right corner of the screen and you will see the  **Test** show up on the menu.   Click on that.   

   ![alt text](./images/testapi1.png)

1. You will now be on the *API test page*.

   Click on the *Get by IncidentNumber* operator.

   ![alt text](./images/testapi2.png)

1. Click the **Try it** on menu bar.
   You will see a spot to enter an *Incident Number*
   You can use the following for the test 
   
   ```
   INC0000011
   ```

   Click on the **Send** button.  
   
   ![alt text](./images/testapi3.png)

1. You will see the request sent with the Incident number.

   In the Response you will see the results returned from ServiceNow.    
    
   ![alt text](./images/testapi4.png)
    
1.   You can test the first operation to get the first 5 incidents numbers.  And use different numbers for get results for different numbers with the *Get by IncidentNumber* operator

      When done Click **Stop test** in the upper right corner. 

1.  Now we will go to the **Designer** screen
   ![alt text](./images/testapi7.png)


## 6. Summary <a name="summary"></a>

Congratulations! You have successfully explored Salesforce Discovery Connector from IBM App Connect Designer.  This is used to create API and Event-driven flows.   

Once you completed building and testing them in Designer you can then export them and deploy them into an App Connect Runtime for realtime use. 

You can click on the 3-dots and select Export.  
   ![alt text](./images/testapi5.png)

Then select the **Runtime flow asset (BAR)**
This is a *Broker Archive file*  that can be used to deploy your integration to a App Connect Runtime. 

   ![alt text](./images/testapi6.png)
<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)