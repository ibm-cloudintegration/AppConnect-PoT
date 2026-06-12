# DFDL Message Modeling and using Mapping Node to insert records into DB2

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment ](#lab-env)
- [3. DB2 setup](#db2-setup)
- [4. Download and Import Project Interchange ](#pi)
- [5. App Connect Toolkit](#ace-toolkit)
	* [5a. Import Project Interchange](#pi-import)
	* [5b. Create Message Model](#dfdl-model)
  * [5c. Parse or validate Model](#parse-model)  
- [6. Create Database Definition to MYDB](#db-definition)
- [7. Build Message Flow](#build-msgflow)
	* [7a. Create Application ](#create-app)
	* [7b. Create Message Flow ](#create-msgflow)
  * [7c. Configure FileInput Node](#configure-fileinput)
  * [7d. Add Project References](#project-references)  
  * [7e. Configure Mapping Node](#configure-mapping)
- [8. Deployment](#deploy)
	* [8a. Create Integration Server](#is-create)
	* [8b. Deploy Projects ](#deploy-projects)
- [9. Testing](#testing)
- [10. Summary](#summary)

---

<br>

# 1. Introduction <a name="introduction"></a>

In this lab, you will acquire the skills necessary to develop a DFDL message model for parsing Meteorological Tab delimited records. Meteorological data is provided in a file that includes a Summary record, a Header record containing field names, and numerous data records. You will create a Data Format Definition Language (DFDL) Message Model to interpret and process the data records using a Mapping node, and insert records in a DB2 database table using JDBC. <br>

The Meteorological data is a sample data about atmospheric conditions, including measurements like temperature, wind speed/direction, humidity, pressure, precipitation data collected via instruments (thermometers, barometers, weather balloons, satellites) to study weather, forecast, model air quality, understand climate, and plan for energy systems. It describes the state of the atmosphere at specific times and places, forming the basis for weather forecasts and climate analysis.
<br>

**Note:** Note that this pattern can be used for any industry data such as Healthcare, Retail, Financial, Manufacturing, ...etc. <br>

The Meteorological data will be received as a file containing Report Summary line, Meteorologica Header fields line, then several Meteorologica Records as below. The header fields, and Meteorologica Records fields are sepearated by a TAB delimeter. <br>
We need to create our Message Model in App Connect Toolkit, so that it can parse the given structure. <br>

**Sample data file.** <br>
```
Local time for generation forecasts. Info in kW. Forecast on 2023-10-16 18:19:11 UTC
WindFa	InsCap	yyyy-mm-dd	hh	cat	perc10	perc25	perc75	perc90	cat-wo	windsp	winddir	temp	pot	cat-fa	pot-fa	cat-wofa
AGR_BA_Wind	1839950	2023-10-16	12	44489	4746	19652	150924	214785	137840				137840	44514	138161	138161
AGR_BA_Wind	1839950	2023-10-16	13	109700	4742	44102	218780	284227	174943				174943	109899	175334	175334
```

Notice that, <br> 
The first line containing "Local time for ...." is a single record. <br>
The second line containing "WindFa	InsCap	...." are field names separated by TAB character. <br>
The Third, 4th, ....etc are the actual data records seperated by TAB character. <br>

We need to build our Message Model to parse the data formateed as above. <br>

Lab Diagram: <br>
![alt text](./images/lab-diagram.png)

<br>

# 2. Workshop Environment <a name="lab-env"></a>

![alt text](./images/env.png)

You will be doing this lab from the Windows VM. You will be using App Connect Enterprise Toolkit from the Windows VM, then you will setup DB2 on acemq3 RHEL VM. <br>

<br>


# 3. DB2 Setup  <a name="db2-setup"></a>

Let's use **acemq3** so that you don't have to make much changes to the lab. <br>

Use the Putty program, and open **acemq3** RHEL Virtual Machine and login as **ibmuser/engageibm** credentials. <br>

Run the following commands, to start db2 as a container. <br>

```
docker start db2server

docker ps
```

![alt text](./images/image.png)

<br>


## 3a. Create tables/indexes  <a name="db2-table"></a>

Run the following commands on acemq3. <br>

```
docker exec -it db2server bash -c "su - db2inst1"
```
![alt text](./images/image-1.png)

Enter into db2 command shell. <br>
```
db2
```
![alt text](./images/image-2.png)

```
connect to MYDB

CREATE TABLE METEOROLOGICA ( SITE char(8) NOT NULL, DATE_DELIVERED timestamp(0) NOT NULL, DATE_FORECAST timestamp(0) NOT NULL, HOUR_ENDING int NOT NULL, POWER decimal(6,2) NOT NULL, PERC10 decimal(6,2) NOT NULL, PERC25 decimal(6,2) NOT NULL, PERC75 decimal(6,2) NOT NULL, PERC90 decimal(6,2) NOT NULL, POWER_WO decimal(6,2) DEFAULT NULL, WIND_SPEED decimal(4,1) DEFAULT NULL, WIND_DIRECTION decimal(3,0) DEFAULT NULL, TEMPERATURE decimal(4,1) DEFAULT NULL, FORECAST_HORIZON_HOURS decimal(5) DEFAULT NULL, FILE_ID decimal(19) NOT NULL, POWER_POT decimal(6,2) DEFAULT NULL, POWER_NO_OUTAGES decimal(6,2) DEFAULT NULL, POWER_PG_NO_OUTAGES decimal(6,2) DEFAULT NULL, POWER_WO_NO_OUTAGES decimal(6,2) DEFAULT NULL, PRIMARY KEY (SITE,DATE_DELIVERED,DATE_FORECAST,HOUR_ENDING));

COMMENT ON TABLE METEOROLOGICA IS 'Date Delivered is UTC, Date Forecast is local time';

COMMENT ON COLUMN METEOROLOGICA.POWER_POT IS 'power based on potential gen';
COMMENT ON COLUMN METEOROLOGICA.POWER_NO_OUTAGES IS 'Power ignoring outages';
COMMENT ON COLUMN METEOROLOGICA.POWER_PG_NO_OUTAGES IS 'Power using pot gen, ignoring outages';
COMMENT ON COLUMN METEOROLOGICA.POWER_WO_NO_OUTAGES IS 'Power without obs, not outages';

CREATE INDEX Date_of_delivery ON METEOROLOGICA (DATE_DELIVERED);

CREATE INDEX FILE_NAME ON METEOROLOGICA (FILE_ID);

CREATE INDEX FORECAST_DATE_SITE ON METEOROLOGICA (DATE_FORECAST,SITE);
```


<br>



# 4. Download and import Project Interchange  <a name="pi"></a>

**Download Project Interchange** from [<b><u>HERE</u></b>](./resources/MappingNode-to-DB2-Template-PI.zip)
<br>

Project Interchange template file contains DefaultPolicies, Sample Data files, shared-classes folder containing db2jcc4.jar jdbc driver, and a very simple CommonESQL function that rounds up values to decimals. <br><br>


# 5. App Connect Toolkit  <a name="ace-toolkit"></a>

Open App Connect Enterprise Toolkit from Windows Taskbar or from the Windows Desktop. <br>

![alt text](./images/image-34.png)


Let's use workspace name as meteorological_file_to_db2. <br>
C:\Users\techzone\IBM\ACET13\workspace\meteorological_file_to_db2 <br>

![alt text](./images/image-3.png)


## 5a. Import Project Interchange <a name="pi-import"></a>

Import Project Interchange file. The PI contains an Application with two simple message flows, and an MQ Policy Project. <br> 

**Import procedure:** <br>
Navigate File Menu > Import > IBM Integration > Project Interchange, then select the PI downloaded above. <br>


Select both projects, and click \<Finish\>. <br>


## 5b. Create Message Model <a name="dfdl-model"></a>


**Create "New Library".** <br>

![alt text](./images/image-4.png)

Name it "Meteorological_Library". <br>

![alt text](./images/image-5.png)

**Create New "Message Model".** <br>

![alt text](./images/image-6.png)

Select "Record oriented text". <br>

![alt text](./images/image-7.png)

Select "Create an empty DFDL schema file, I will model my data using the DFDL schema editor". <br>

![alt text](./images/image-8.png)

Enter DFDL schema file name as "Meteorologica", then click <\Finish\>. <br>

![alt text](./images/image-9.png)

You will be greeted with blank Data Format Definition Language (DFDL) Editor. <br>

![alt text](./images/image-10.png)



**Build the model structure** <br>

**First - Create a Message called Meteorolica<br>

![alt text](./images/image-11.png)

![alt text](./images/image-12.png)

![alt text](./images/image-13.png)

Click on "Sequence", then change Seperator from Comma (,) to No seperator. <br>

![alt text](./images/image-42.png)

<br>

**Build the first segment which is the Summary (or) the Report Header** 

Click on "Sequence", then click on "Add a local element with a simple type". <br>

![alt text](./images/image-14.png)

![alt text](./images/image-15.png)

Rename "field1" as "Summary", then click on "String" and change to "Anonymous". <br>

![alt text](./images/image-16.png)

![alt text](./images/image-17.png)

Set the Terminator as "%CR;%LF;%WSP*;" (Without the double quotes). <br>

![alt text](./images/image-19.png)


Click on "Summary", then click on "Add a local element with a simple type". <br>

![alt text](./images/image-18.png)

Set the Seperator as "%CR;%LF;%WSP*;" (Without the double quotes). <br>

![alt text](./images/image-20.png)


<br>

**Second - build the Header fields segment** <br>

Click on "Sequence", then click on "Add a local element with a simple type". <br>

![alt text](./images/image-21.png)

![alt text](./images/image-22.png)

Rename "field1" to "Header", then replace "String" with "Anonymous". <br>

![alt text](./images/image-23.png)

Set the Terminator as "%CR;%LF;%WSP*;" (Without double quotes). <br>

![alt text](./images/image-24.png)

Click on Header segment, then click on "Add a local element with a simple type". <br>

![alt text](./images/image-25.png)

![alt text](./images/image-26.png)

Now, click on "Sequence", then set the Seperator as "%HT;" (Hotizontal tab). <br>

![alt text](./images/image-27.png)

Now, let's add 16 more header fields (1 - 17), 17 total fields. <br>

Click on Header "Sequence", and then click on "Add a local element with a simple type". <br>

![alt text](./images/image-28.png)

It should look like this after adding 17 header fields. <br>
![alt text](./images/image-29.png)

<br>

**Third - build the Record data segment** <br>

Click on "Sequence", then click on "Add a local element with a simple type". <br>

![alt text](./images/image-30.png)

"field1", will be created. <br>
![alt text](./images/image-31.png)

Rename "field1" as "Record", then change type from from "String" to "Anonymous". <br>
![alt text](./images/image-32.png)

There will be many records, so let's change Record segment as "Unbounded". <br>

![alt text](./images/image-33.png)

![alt text](./images/image-35.png)

Set the "Record" Terminator as "%CR;%LF;%WSP*;". <br>

![alt text](./images/image-36.png)

Click on Record segment, then click on "Add a local element with a simple type". <br>

![alt text](./images/image-37.png)

Now, click on "Sequence", then set the Terminator as "%HT;". <br>

![alt text](./images/image-38.png)

Now, add 16 more fields just like the Header fields. Click on Record "Sequence", then click on "Add a local element with a simple type". <br>

![alt text](./images/image-39.png)

Let's rename the Record segment field names as below, also change the types as in the picture below. <br>

field1, to field17 as below. <br>
WindFa <br>
InsCap <br>
Date <br>
Hours <br>
Cat <br>
Perc10 <br>
Perc25 <br>
Perc75 <br>
Perc90 <br>
Cat-wo <br>
WindSp <br>
WindDir <br>
Temp <br>
Pot <br>
Cat-fa <br>
Pot-fa <br>
Cat-wofa <br>


![alt text](./images/image-40.png)

Some of the fields has blank or null values, hence change MinOccurs to be 0. <br>

![alt text](./images/image-41.png)

HIT Control+s to save the Model. <br>



## 5c. Parse or validate Model <a name="parse-model"></a>

Let's make sure our Model is defined properly by validating with the sample data. Click "Test Parse Model". <br>

![alt text](./images/image-43.png)

Click Browse to select the sample data file. <br>

![alt text](./images/image-44.png)

Select smaller file. <br>

![alt text](./images/image-45.png)

Click \<Ok\>. <br>
![alt text](./images/image-46.png)

![alt text](./images/image-47.png)

If our model is defined properly, then the parsing should be successful. <br>

![alt text](./images/image-48.png)

Expand the parsed data on top right to see the values. <br>

![alt text](./images/image-49.png)

<br>


# 6. Create Database Definition to MYDB  <a name="db-definition"></a>


File > New > Database Definition. <br>

![alt text](./images/image-59.png)

Click "New" to create new "Data Design Project". <br>

![alt text](./images/image-60.png)

Enter "MYDB_DB2_Project". <br>

![alt text](./images/image-61.png)

Select Version v11.1. <br>

![alt text](./images/image-62.png)

Click "New" to create a new Database Connection. <br>

![alt text](./images/image-63.png)

![alt text](./images/image-64.png)

![alt text](./images/image-65.png)

![alt text](./images/image-66.png)

Select DB2INST1 Schema. <br>

![alt text](./images/image-67.png)

Click \<Finish\>. <br>

![alt text](./images/image-68.png)

<br>


# 7. Build Message Flow  <a name="build-msgflow"></a>

## 7a. Create Application <a name="create-app"></a>

Create a new Application, name it "Meteorologica_Application" <br>

![alt text](./images/image-50.png)

Select Meteorological_Library. <br>

![alt text](./images/image-51.png)


## 7b. Create Message Flow <a name="create-msgflow"></a>

Create New Message Flow. <br>

![alt text](./images/image-52.png)

Name the Message Flow **"Meteorologica_file_db2_sync"**. <br>

![alt text](./images/image-53.png)


Drag FileInput and Mapping Nodes into the canvas, then wire them as below. <br>

![alt text](./images/image-54.png)



## 7c. Configure FileInput Node <a name="configure-fileinput"></a>

![alt text](./images/image-55.png)

Click "Input Message Parsing" Tab. <br>
Select Message Domain as DFDL, then click Browse to select the Message Model. <br>

![alt text](./images/image-56.png)

Select "Meteorological_Library" for the Message Model, and Meteologica as the Message. <br>

![alt text](./images/image-57.png)

It should look like this. <br>

![alt text](./images/image-58.png)




## 7d. Add Project References <a name="project-references"></a>

![alt text](./images/image-69.png)

## 7e. Configure Mapping Node <a name="configure-mapping"></a>

Double click on Mapping Node. <br>

![alt text](./images/image-70.png)

![alt text](./images/image-71.png)


![alt text](./images/image-72.png)

Now, let's implement target mapping to the MYDB / METEOROLOGICA table. <br>

![alt text](./images/image-73.png)

Click "Add Database". <br>

![alt text](./images/image-83.png)


Select MYDB_DB2_Project, and click "Make Available", then click \<Ok\>. <br>

![alt text](./images/image-84.png)

Click \<Ok\>. <br>

![alt text](./images/image-74.png)

Hit Control + s, to save the Map. <br>


Right click and delete the "Insert, Return" box in the middle. <br>

![alt text](./images/image-75.png)


Drag Record to METEROLOGICA table definition. <br>

![alt text](./images/image-76.png)

Click on "Create Insert inside a ForEach". <br>

![alt text](./images/image-77.png)

A "For each" transform should be wired as below. <br>


Click on "For each" transform. <br>


![alt text](./images/image-78.png)

Now click on Insert transform. <br>

![alt text](./images/image-79.png)

Let's try "Auto Mapping" feature and map similar name fields. <br>

![alt text](./images/image-80.png)

Keep the default settings, and click \<Finish\>.

![alt text](./images/image-81.png)

Notice that it has mapped to it's best by the matching field names. <br>
![alt text](./images/image-82.png)

Now, let's map the remaining fields with custom transformations. <br>


Drag WindFa to Site as below. <br>

![alt text](./images/image-85.png)


Click on Move transform, and change it to a substring transform. <br>

![alt text](./images/image-86.png)

![alt text](./images/image-87.png)

Expand "String Functions", then select "fn:substring" transform. <br>

![alt text](./images/image-88.png)

Set startLocation to be 1. Click on startLocation, then click \<Edit\>.  <br>

![alt text](./images/image-89.png)

Click \<Ok\>.  <br>

![alt text](./images/image-90.png)

Click \<Add\>, to add length. <br>

![alt text](./images/image-91.png)


Click on length, and then click \<Edit\>, then set to 8 just as above. <br>

![alt text](./images/image-92.png)


Finally, the substring transform should look like this. <br>

![alt text](./images/image-85.png)


Set DATE_DELIVERED to be current timestamp. Drag DATA_DELIVERED to the map canvas. An Assign transform will be created. <br>

![alt text](./images/image-93.png)

Click on Assign's dropdown, then change to fn:current-dateTime by clicking on .

![alt text](./images/image-94.png)

Map Date to DATE_FORCAST, and Hours to HOUR_ENDING as below. <br>

![alt text](./images/image-95.png)

MAP "Cat" to "POWER", a Move transform will be created. Let's change from Move transform to a CustomESQL transform. <br>

![alt text](./images/image-96.png)

Select "Custom ESQL" under "Custom Transforms". <br>

![alt text](./images/image-97.png)

Select CommonESQL/CommonFunctions.esql as below. <br>

![alt text](./images/image-98.png)

Click on Routines dropdown, then select roundDecimals_2 function. <br>

![alt text](./images/image-100.png)

Similarly, transform perc10, perc25, perc75, perc90 fields to CustomESQL/roundDecimals_2 transform. <br>

![alt text](./images/image-100.png)

Now, for Cat-wo to POWER_WO, and WindSp to WIND_SPEED, select CustomESQL/roundDecimals_1 transform. <br>

![alt text](./images/image-101.png)


Map, WindDir to WIND_DIRECTION, Temp to TEMPERATURE as Move transform. <br>

For FILE_ID, create Assign transform and set value to "12345". <br>


Now, map Pot --> POWER_POT, Cat-fa --> POWER_NO_OUTAGES, Pot-fa --> POT_PG_NO_OUTAGES, Cat-wofa --> POWER_WO_NO_OUTAGES, then change from Move transform to CustomESQL/roundDecimals_2 transform. <br>

![alt text](./images/image-102.png)


<br> <br>



# 8. Deployment  <a name="deploy"></a>


## 8a. Create Integration Server <a name="is-create"></a>

Create Local Integration Server TEST_SERVER (Integration Explorer pane in the bottom left of the Toolkit). <br>

![alt text](./images/image-103.png)


Enter Vault password as passw0rd. <br>

![alt text](./images/image-104.png)

Click \<Finish\>. <br>


### 5b. Update TEST_SERVER/overrides/server.conf.yaml  <a name="override-serverconf"></a>


Edit server.conf.yaml under the overrides folder. Add the below lines as in the picture. <br>

```
Defaults:
  policyProject: 'DefaultPolicies'
```

![alt text](./images/image-107.png)

Save and Close server.conf.yaml. <br>

**RESTART TEST_SERVER.** <br>

![alt text](./images/image-108.png)

<br>


### 5c. Create JDBC Credential <a name="create-odbc-cred"></a>

Right click and create JDBC type credential as below. <br>

![alt text](./images/image-105.png)

Credential Name: mydb <br>
Username: db2inst1 <br>
Password: engageibm <br>

![alt text](./images/image-106.png)

<br>



## 8b. Deploy Projects <a name="deploy-projects"></a>

Drag-n-drop the MyPolicies Policy Project into TEST_SERVER. <br>

![alt text](./images/image-109.png)


Similarly, deploy CommonESQL, Meteorological_Library, and finally Meteologica_Application into TEST_SERVER. <br>

![alt text](./images/image-110.png)

<br>



# 9. Testing  <a name="testing"></a>

Open Windows Explorer, and locate C:\workshop\ace\file_to_db2 folder. <br>

From the Toolkit, copy & paste Sample_data_10_lines.dat to Windows file_to_db2 folder. <br>

![alt text](./images/image-115.png)

Paste to file_to_db2 folder. <br>

![alt text](./images/image-111.png)

The Message flow should pick up the file and process it. If processing is successful, you should see a file in the mqsiarchive folder. <br>

![alt text](./images/image-112.png)

Now, let's check the records in DB2, Schema DB2INST1, and the table METEOROLOGICA. <br>

Logon back to acemq3, and get into db2 command shell (if not already there). <br>

```
docker exec -it db2server bash -c "su - db2inst1"
```

Connect to MYDB, and run select query. <br>

```
db2
connect to mydb
select * from meteorologica
```

![alt text](./images/image-114.png)


# 10. Summary <a name="summary"></a>

Congratulations! You have successfully learned how to utilize the IBM App Connect Toolkit to create a Message Model from the ground up to parse tab-delimited records. Subsequently, you configured the FileInput Node to read files from a specified directory, followed by setting up the Mapping Node to map each field, and finally, you inserted each mapped record into the database table.

<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)



