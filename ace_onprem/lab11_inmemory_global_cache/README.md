# Introduction to In-memory Global Cache

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment](#lab-env)
- [3. App Connect Toolkit](#ace-toolkit)
	* [3a. Create Integration Servers](#is-create)
	* [3b. Update overrides/server.conf.yaml](#server-conf)
	* [3c. Restart Integration Servers](#is-restart)
- [4. Build DemoCacheWrite Message Flow](#build-cachewrite-msgflow)
- [5. Build DemoCacheRead Message Flow](#build-cacheread-msgflow)
- [6. Testing](#testing)
	* [6a. Verify Maps (Cache Records)](#check-cache)
	* [6b. Populate Cache - DemoCacheWrite](#populate-cache)
  * [6c. Read Cache - DemoCacheRead](#read-cache)
- [7. Summary](#summary)
- [8. References](#references)
- [9. Project Interchange](#pi)

---

# 1. Introduction <a name="introduction"></a>

In this laboratory, you will investigate the procedures necessary to activate the in-memory global cache feature of IBM App Connect Enterprise. Furthermore, you will develop a Message Flow to both write to and read from the in-memory global cache data.
<br>

The embedded global cache is a built-in caching mechanism that is introduced in IBM App Connect Enterprise version 13.0.3.0. The embedded global cache replaces the deprecated embedded WebSphere® eXtreme Scale (WXS) grid (formerly known as the WXS embedded cache).
<br>

Use the embedded global cache that is supplied with IBM® App Connect Enterprise to store data that you want to reuse.
<br>
Reference: <a href>https://www.ibm.com/docs/en/app-connect/13.0.x?topic=overview-embedded-global-cache</href>
<br>

Lab diagram<br>

![alt text](./images/image.png)
<br><br>


# 2. Workshop Environment <a name="lab-env"></a>

You will be doing this lab from the Windows VM. <br>

![alt text](./images/env.png)

<br>

# 3. App Connect Toolkit  <a name="ace-toolkit"></a>

Open IBM App Connect Toolkit, and workspace C:\Users\techzone\IBM\ACET13\workspace\ace-workshop. <br>

![alt text](./images/image-1.png)

If are greeted with Welcome page, then close it. <br>
<br>



## 3a. Create Integration Servers <a name="is-create"></a>

Create a local integration servers DEMOCACHE_SERVER1 through DEMOCACHE_SERVER4. <br>

![alt text](./images/image-2.png)

![alt text](./images/image-3.png)

If not started already, the right click, and then start DEMOCACHE_SERVER1 through DEMOCACHE_SERVER4. <br>

![alt text](./images/image-4.png)


## 3b. Update overrides/server.conf.yaml <a name="server-conf"></a>


**DEMOCACHE_SERVER1** <br>
Open overrides/server.conf.yaml of each DEMOCACHE_SERVER1, set RestAdminListener port to 7601, HTTP ListenerPort to 7801, and GlobalCache section as below.<br>

```
  GlobalCache:
    replicateWritesTo: 'DEMOCACHE_SERVER2,DEMOCACHE_SERVER3'
    ReplicationServers:
      DEMOCACHE_SERVER2:
        Hostname: 'localhost'
        Port: 7902
        EnableTLS: false
      DEMOCACHE_SERVER3:
        Hostname: 'localhost'
        Port: 7903
        EnableTLS: false
      ReplicationListener:
        StartListener: true
        ListenerPort: 7901
        EnableTLS: false
```
![alt text](./images/image-5.png)


Save and close. <br>
<br>

**DEMOCACHE_SERVER2** <br>
Open overrides/server.conf.yaml of each DEMOCACHE_SERVER2, set RestAdminListener port to 7602, HTTP ListenerPort to 7802, and GlobalCache section as below. <br>

```
  GlobalCache:
    ReplicationListener:
      StartListener: true
      ListenerPort: 7902
      EnableTLS: false
```
![alt text](./images/image-6.png)

Save and close. <br>

**DEMOCACHE_SERVER3** <br>
Open overrides/server.conf.yaml of each DEMOCACHE_SERVER3, set RestAdminListener port to 7603, HTTP ListenerPort to 7803, and GlobalCache section as below.
<br>

```
  GlobalCache:
    ReplicationListener:
      StartListener: true
      ListenerPort: 7903
      EnableTLS: false
```
![alt text](./images/image-7.png)

Save and close. <br>

**DEMOCACHE_SERVER4** <br>
Open overrides/server.conf.yaml of each DEMOCACHE_SERVER4, set RestAdminListener port to 7604, HTTP ListenerPort to 7804, and GlobalCache section as below. <br>

```
  GlobalCache:
    replicateReadsFrom: 'DEMOCACHE_SERVER2,DEMOCACHE_SERVER3'
    ReplicationServers:
      DEMOCACHE_SERVER2:
        Hostname: 'localhost'
        Port: 7902
        EnableTLS: false
      DEMOCACHE_SERVER3:
        Hostname: 'localhost'
        Port: 7903
        EnableTLS: false
    ReplicationListener:
      StartListener: true
      ListenerPort: 7904
      EnableTLS: false
```

![alt text](./images/image-8.png)


Save and close. <br>


## 3c. Restart Integration Servers <a name="is-restart"></a>

![alt text](./images/image-9.png)

<br>


# 4. Build DemoCacheWrite Message Flow <a name="build-cachewrite-msgflow"></a>

Create New Application, name it "DemoCacheWrite_App". <br>
![alt text](./images/image-10.png)

Create New Message Flow, name it "DemoCacheWrite". <br>
![alt text](./images/image-11.png)

![alt text](./images/image-12.png)


Drag and drop "HTTP Input, HTTP Reply, Java Compute" nodes into the message flow canvas, and wire them as below. <br>

![alt text](./images/image-13.png)

**HTTP Input** Configuration: <br>

![alt text](./images/image-14.png)

![alt text](./images/image-15.png)


**Java Compute** Configuration: <br>
Double click on "Java Compute" node, then click \<Finish\> <br>
![alt text](./images/image-16.png)

Add the below code in between "user code" section. <br>
![alt text](./images/image-17.png)

```
// Add user code below

outMessage.getRootElement().getFirstElementByPath("JSON/Data").createElementAsLastChild(MbElement.TYPE_NAME, "Message", "Cache has been updated");
String name = (String) inMessage.getRootElement().getFirstElementByPath("JSON/Data/Person/Name").getValue();
int age = (int) inMessage.getRootElement().getFirstElementByPath("JSON/Data/Person/Age").getValue();
MbGlobalMap personMap = MbGlobalMap.getGlobalMap("personMap");
personMap.put(name, age);

// End of user code
```
Save and close Java code window. <br>

<br>



# 5. Build DemoCacheRead Message Flow <a name="build-cacheread-msgflow"></a>

Create New Application, name it "DemoCacheRead_App". <br>

![alt text](./images/image-18.png)

Create New Message Flow, name it "DemoCacheRead. <br>

![alt text](./images/image-19.png)

![alt text](./images/image-20.png)

Drag and drop, "HTTP Input, HTTP Reply, Mapping" nodes into the Message Flow canvas, and write them as below. <br>

![alt text](./images/image-21.png)

**HTTP Input** Configuration: <br>

![alt text](./images/image-22.png)

![alt text](./images/image-23.png)
<br>

**Mapping** Configuration: <br>
Double click on the "Mapping" node, and follow the arrows in the screens below. <br>

![alt text](./images/image-24.png)

![alt text](./images/image-25.png)

![alt text](./images/image-26.png)

Expand JSON Segment on both source, and target. <br>

![alt text](./images/image-27.png)


On the **source (left)**, right click on "any" to add an "User defined" variable. <br>

![alt text](./images/image-28.png)

![alt text](./images/image-29.png)

Replace "element1" to "Person", type to "Anonymous". Replace element1 to Name as below. <br>

![alt text](./images/image-30.png)

Add "Age" element as below. Right click on "Person" Object, then click "Add Child Element". <br>

![alt text](./images/image-31.png)

![alt text](./images/image-32.png)

On the **target (right)**, right click on "any" to add an "User defined" variable. <br>

![alt text](./images/image-33.png)

Replace "element1" with "Person" and hit ENTER. It should automatically fetch the "Person" object and its fields. <br>

![alt text](./images/image-34.png)

<br>
**Retrieve Cache record**. <br>

Click on "Get a key-value pair from global cache" icon. <br>

![alt text](./images/image-35.png)

![alt text](./images/image-36.png)

Drag "Name" field to "Cache Get" as below. <br>

![alt text](./images/image-37.png)

![alt text](./images/image-38.png)


Now, drag "Cache Return" to "Age" field. <br>

![alt text](./images/image-39.png)

![alt text](./images/image-40.png)


Click on "Cache Get". <br>
![alt text](./images/image-42.png)

![alt text](./images/image-43.png)

Wire "Name" to "Key". <br>
![alt text](./images/image-44.png)

Hit Control+s to save the map. <br>

Now, click on the main map. <br>
![alt text](./images/image-45.png)


Now, click on "Cache Return". <br>
![alt text](./images/image-46.png)

![alt text](./images/image-47.png)

Wire "Value" to "Age" as below. <br>

![alt text](./images/image-48.png)

**Save** the map (Control+s). <br>

Click on the main map. <br>


Now, drag "Name" to "Name" as below. <br>
![alt text](./images/image-41.png)

Your final map should look like this. <br>

![alt text](./images/image-49.png)

Make sure you **SAVE** the map. <br><br>



# 6. Testing <a name="testing"></a>


## 6a. Verify Maps (Cache Records) <a name="check-cache"></a>

```
ibmint display cache --admin-host localhost --admin-port 7601 --all-maps

ibmint display cache --admin-host localhost --admin-port 7602 --all-maps

ibmint display cache --admin-host localhost --admin-port 7603 --all-maps

ibmint display cache --admin-host localhost --admin-port 7604 --all-maps
```
![alt text](./images/image-55.png)

As observed, the Integration Servers doesn't have any Cache records. <br>



## 6b. Populate Cache - DemoCacheWrite <a name="populate-cache"></a>

Let's use "Flow Exerciser" to send a "Person" record. <br>

Open "DemoCacheWrite" message flow, then click on "Flow Exerciser" icon as below. <br>

![alt text](./images/image-50.png)

Select "DEMOCACHE_SERVER1" Integration Server. <br>
![alt text](./images/image-51.png)

![alt text](./images/image-52.png)


Now, click on "Send a message to the flow" icon. <br>
![alt text](./images/image-53.png)

Click on "New Message" icon. <br>
![alt text](./images/image-54.png)

Enter the following "Person" JSON payload. 
```
{
  "Person": 
  {
    "Name": "Sudhakar",
    "Age": 41
  }
}
```

![alt text](./images/image-56.png)

Output below. <br> 
![alt text](./images/image-57.png)


Now, let's verify the in-memory cache is populated into the personMap. <br>


```
ibmint display cache --admin-host localhost --admin-port 7601 --all-maps

ibmint display cache --admin-host localhost --admin-port 7602 --all-maps

ibmint display cache --admin-host localhost --admin-port 7603 --all-maps

ibmint display cache --admin-host localhost --admin-port 7604 --all-maps
```

As expected, Integration Servers 1,2,3 have the in-memory cache, however server4 isn't. Server4 should receive in-memory cache as soon DemoCacheRead Message Flow is used. <br>

![alt text](./images/image-63.png)

End the "Flow Exerciser" for the DemoCacheWrite. <br><br>



## 6c. Read Cache - DemoCacheRead <a name="read-cache"></a>

Let's use "Flow Exerciser" to read "Person" record. <br>

Open DemoCacheRead Message Flow, <br> 

![alt text](./images/image-58.png)

Deploy DemoCacheRead to DEMOCACHE_SERVER4 per the lab diagram. <br>
![alt text](./images/image-59.png)

Click "Send a message to the flow" icon. <br>
![alt text](./images/image-60.png)

Click "New Message" icon, and paste below JSON. <br>
```
{
  "Person": 
  {
    "Name": "Sudhakar"
  }
}
```

![alt text](./images/image-61.png)

Check the Output. <br>

![alt text](./images/image-62.png)

As expected, DemoCacheRead Mapping Node's "Cache Get" function retrieved personMap from DEMOCACHE_SERVER2 or DEMOCACHE_SERVER3. 

<br>
DEMOCACHE_SERVER4 now have personMap in-memory cache as well. <br>
![alt text](./images/image-64.png)

<br>


# 7. Summary <a name="summary"></a>

Congratulations! You have successfully explored IBM App Connect's in-memory Global Cache feature to store and retrieve key/value records. <br>



# 8. References <a name="references"></a>

The new Embedded Global Cache in IBM App Connect Enterprise 13.0.3.0: <br>
<a href="https://community.ibm.com/community/user/blogs/aaron-gashi/2025/03/27/the-new-embedded-global-cache-in-ace-13-0-3-0" target="_blank">https://community.ibm.com/community/user/blogs/aaron-gashi/2025/03/27/the-new-embedded-global-cache-in-ace-13-0-3-0 </a>

Configuring Embedded Global Cache: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=caching-configuring-embedded-global-cache" target="_blank"> https://www.ibm.com/docs/en/app-connect/13.0.x?topic=caching-configuring-embedded-global-cache </a>

Global cache scenario: Storing state for integrations: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=overview-global-cache-scenario-storing-state-integrations" target="_blank">https://www.ibm.com/docs/en/app-connect/13.0.x?topic=overview-global-cache-scenario-storing-state-integrations</a>

<br>

# 9. Project Interchange <a name="pi"></a>
**Project Interchange** from [<b><u>here</u></b>](./resources/DemoGlobalCache.zip)</b>
<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)