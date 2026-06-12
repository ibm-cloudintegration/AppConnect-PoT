# How to use a Change Data Capture node in IBM App Connect to stream changes from a Postgres Database.

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Postgres - create database and sample data ](#postgres-db)
- [3. App Connect Toolkit](#toolkit)
  * [3a. Open Workspace](#open-workspace)
  * [3b. Create Vault, Credential](#create-vault)
  * [3c. Start Integration Server demo-postgres](#start-is)
  * [3d. Create Message Flow](#message-flow)
- [4. Deployment](#deployment)
  * [4a. Connect to Integration Server ](#integration-server)
  * [4b. Deploy Policy, Application](#deploy)
- [5. Testing](#testing)
  * [5a. Insert new record ](#testing-new-record)
  * [5b. Update record ](#testing-update-record)
- [6. Summary ](#summary)
- [7. Miscellaneous ](#misc)
  * [7a. Postgres installation on RHEL ](#postgres-install)
- [8. References ](#references)

---

<br>

## 1. Introduction <a name="introduction"></a>
In this lab, you will explore the Change Data Capture (CDC) Node of the App Connect Enterprise (ACE) Toolkit to capture records in real-time from a Postgres database table. <br>


Diagram: <br>
![alt text](./images/lab-diagram.png)


Workshop environment. <br>
![alt text](./images/image-0.png)

You will be doing this lab from the Windows VM. <br>
<br>


## 2. Postgres - create database and sample data <a name="postgres-db"></a>

Let's create Postgres database called demo. <br>

From the Windows VM, open Putty program. Open "ibmace1" RHEL VM. <br>

Login as "ibmuser" and enter the following commands. <br>

```
sudo –u postgres psql

postgres=# CREATE DATABASE demo;

postgres=# \c demo

demo=# \d

demo=# CREATE table pirates(
id INT NOT NULL, 
name VARCHAR (30),
power VARCHAR(30),
PRIMARY KEY (id));

demo=# \d pirates

demo=# INSERT INTO pirates(id, name, power) VALUES(1, 'luffy', 'rubber');
INSERT INTO pirates(id, name, power) VALUES(2, 'zoro', '3 swords');
INSERT INTO pirates(id, name, power) VALUES(3, 'nami', 'navigator');
INSERT INTO pirates(id, name, power) VALUES(4, 'usopp', 'lying');
INSERT INTO pirates(id, name, power) VALUES(5, 'buggy', 'chop-chop');
INSERT INTO pirates(id, name, power) VALUES(6, 'sanji', 'chef kicks');
INSERT INTO pirates(id, name, power) VALUES(7, 'chopper', 'doctor reindeer');

demo=# \d pirates

demo=# select * from pirates;

### Lets not to use postgres user in ACE flow, lets setup a new user for ACE message flow.
demo=# CREATE ROLE dbz REPLICATION LOGIN PASSWORD 'dbz123';

### grant create previlage on the demo database
demo=# GRANT CREATE ON DATABASE demo TO dbz;

### swap owner from postgres to dbz
demo=# ALTER TABLE pirates OWNER TO dbz;

### grant dbz role to postgres 
demo=# GRANT dbz TO postgres;


## quit postgres user
demo=# \q

## now lets login as dbz user
[ibmuser@ibmace1 ~]$ psql -U dbz -h 127.0.0.1 -d demo
password: dbz123

demo=# \d pirates

## create publication 
demo=# CREATE PUBLICATION dbz_pub FOR TABLE public.pirates;

## see Publication
demo=# \d pirates
demo=# \q
```
<br>


## 3. App Connect Toolkit <a name="toolkit"></a>

From the Windows VM, open IBM App Connect Enterprise Toolkit from the desktop. <br>

### 3a. Open Workspace <a name="open-workspace"></a>

Workspace: C:\Users\techzone\IBM\ACET13\workspace\cdc-demo <br>
![alt text](./images/image-4.png)

Close the welcome page. <br>

Navigate menu, Window > Show view > Other > search for Terminal > select Terminal and click Open button. <br>

![alt text](./images/image-5.png)

Click the "Launch Terminal" button. <br>
![alt text](./images/image-6.png)

Click Ok. <br>
![alt text](./images/image-7.png)

A local Terminal will be added as below. <br>
![alt text](./images/image-8.png)



### 3b. Create Vault, Credential <a name="create-vault"></a>

Create a work directory, and Vault to store credentials. <br>

From the Terminal pane, run the below commands. <br>
```
mqsicreateworkdir ./demo-postgres
```
![alt text](./images/image-9.png)

Create Vault. <br>
```
mqsivault --create --vault-key cdcVaultKey --work-dir ./demo-postgres
```
![alt text](./images/image-10.png)

Create Credential to access demo postgres database. <br>
```
mqsicredentials --create --credential-name cdcPostgres --credential-type cdc --username dbz --password dbz123 --work-dir ./demo-postgres --vault-key cdcVaultKey
```
![alt text](./images/image-11.png)

Set JRE version to the latest. <br>
```
ibmint display supported-jre-versions  
ibmint specify jre --version  17 --work-dir ./demo-postgres 
```
![alt text](./images/image-12.png)





### 3c. Start Integration Server demo-postgres <a name="start-is"></a>

Lets start the integration server demo-postgres from the Terminal view of the Toolkit. <br>
```
IntegrationServer --work-dir ./demo-postgres --vault-key cdcVaultKey
```
if prompted to allow access to the Virtual Machine, then click Allow. <br><br>

### 3d. Create Message Flow <a name="message-flow"></a>

Navigate menu, File > New > Application. <br>
![alt text](./images/image-13.png)

Click New > Message Flow. <br>
![alt text](./images/image-14.png)

Call if "Simple_CDC_MsgFlow", and click Finish. <br>
![alt text](./images/image-15.png)

Drag "Change Data Capture" node into the Message Flow Canvas. <br>
![alt text](./images/image-16.png)


Drag a Trace node into the canvas. <br>
![alt text](./images/image-17.png)

Also, drag a FileOutput Node into the Canvas. <br>
![alt text](./images/image-18.png)

Now, lets wire the nodes as below. <br>
![alt text](./images/image-19.png)


Configure each Node. <br>
Click on "Change Data Capture" Node. Check the Properties view. <br>

![alt text](./images/image-19a.png)

Click, Create a policy link. <br>
![alt text](./images/image-22.png)

Create a new Policy project. <br>
![alt text](./images/image-23.png)

Name it "MyPolicies" and click Finish. <br>
![alt text](./images/image-24.png)


Enter Policy name as "Postgres". <br>
![alt text](./images/image-25.png)

Select Template as PostgreSQL. <br>
![alt text](./images/image-26.png)

Confirm to switch policy or template ... click OK. <br>
![alt text](./images/image-27.png)

Now, enter Connection details in the Policy configuration. <br>
Host name: 10.0.0.1 <br>
Port number: 5432 <br>
Security identity (DSN): cdcPostgres <br>
![alt text](./images/image-28.png)


<br>
Hit Control or Command+s to save the policy xml. <br>

Click on the Message flow, and Basic tab. <br>
Add public.pirates table. Click  <br>
![alt text](./images/image-29.png)

![alt text](./images/image-30.png)

Hit Control or Command+s to save the policy xml. <br>


**Configure Trace node.** <br>
Destination: File <br>
File path: C:\temp\cdc_trace.txt <br>
Pattern: (copy/paste the below <br>
```
======= START ${CURRENT_TIMESTAMP} =======
--------------------------------
${Root}
--------------------------------
${Body}

```
![alt text](./images/image-21.png)

**Configure FileOutput node** directory, and filename. <br>
Directory: C:\temp <br>
File name or pattern: cdc_events.txt <br>
![alt text](./images/image-20.png)

<br>


## 4. Deployment  <a name="deployment"></a>

Lets deploy the Policy project and the Application into the Integration Server you have created and started in above. <br><br>

### 4a. Connect to Integration Server <a name="integration-server"></a>

Connect to the Integration Server as below. <br>
![alt text](./images/image-31.png)

![alt text](./images/image-31a.png)

Trust the certificate. <br>
![alt text](./images/image-32.png)


### 4b. Deploy Policy, Application <a name="deploy"></a>


Now, drag and drop the Policy Project and CdcDemoApp into the Integration server demo-postgres. <br>

![alt text](./images/image-33.png)


## 5. Testing <a name="testing"></a>

You should see two files under C:\temp folder. Open each of them and check the data. <br> 
Note that, we are not stripping any segments that is coming out of the CDC connector. <br>
![alt text](./images/image-34.png)

<br>

### 5a. Insert new record <a name="testing-new-record"></a>

Lets add one new record into the demo database. <br>

Logon to ibmace1 VM again as ibmuser, and run the below commands. <br>

```
[ibmuser@ibmace1 ~]$ psql -U dbz -h 127.0.0.1 -d demo
password: dbz123

demo==> INSERT INTO pirates(id, name, power) VALUES(8, 'harry', 'potter');

demo==> select * from pirates;
```

Now, switch back to Windows VM, and check cdc_events.txt file. You should see the new record. <br>

![alt text](./images/image-35.png)
<br>

### 5b. Update record <a name="testing-update-record"></a>
Switch back to ibmace1 VM again as ibmuser, and run the below commands. <br>
```
[ibmuser@ibmace1 ~]$ psql -U dbz -h 127.0.0.1 -d demo
password: dbz123

demo==> UPDATE pirates SET name='Ron', power='magic' where id=8;

demo==> select * from pirates;
```
![alt text](./images/image-36.png)

![alt text](./images/image-37.png)


### 5c. Optional - check cdc_trace.txt <a name="testing-cdc--trace"></a>

Optionally, open C:\temp\cdc_trace.txt file using Notepad++.
<br><br> 

## 6. Summary <a name="summary"></a>

Congratulations! You have successfully generated records in PostgreSQL database and received the records as events using APP Connect Change Data Capture connector.

<br><br><br>







## 7. MISCELLANEOUS <a name="misc"></a>



## 7a. Postgres installation on RHEL <a name="postgres-install"></a>

```
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

sudo dnf -qy module disable postgresql

sudo dnf install -y postgresql18-server

sudo /usr/pgsql-18/bin/postgresql-18-setup initdb

sudo systemctl enable postgresql-18

sudo systemctl start postgresql-18
```

```
sudo vi /var/lib/pgsql/18/data/pg_hba.conf
```
![alt text](./images/image.png)

```
sudo vi /var/lib/pgsql/data/postgresql.conf
```
![alt text](./images/image-1.png)

![alt text](./images/image-2.png)

![alt text](./images/image-3.png)

```
sudo systemctl restart postgresql-18
```



## 8. References <a name="references"></a>
Youtube: <br>
How to use a Change Data Capture node in IBM App Connect to stream changes from a Postgres Database.<br>
<a href="https://www.youtube.com/watch?v=wCFOYXELXaE&list=PL_4RxtD-BL5tKxx9GiR2BH146ZUC21cOp&index=35"  target="_blank">https://www.youtube.com/watch?v=wCFOYXELXaE&list=PL_4RxtD-BL5tKxx9GiR2BH146ZUC21cOp&index=35</a>

Downloading PostgreSQL Connector Archive: <br>
<a href="https://debezium.io/documentation/reference/3.4/connectors/postgresql.html#postgresql-deployment" target="_blank">https://debezium.io/documentation/reference/3.4/connectors/postgresql.html#postgresql-deployment</a>

After downloadging, unpacked the connector binaries files to C:\Program Files\IBM\ACE\13.0.5.0\server\cdc folder. <br>

![alt text](./images/image-38.png)


<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)

