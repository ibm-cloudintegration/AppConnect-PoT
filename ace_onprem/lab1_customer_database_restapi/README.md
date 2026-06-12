# Customer Database REST API (OpenAPI 3.0)

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. App Connect Toolkit - Prepare API](#toolkit-prepare-api)
	* [2a. Import CustomerDatabaseJava.zip](#import-cdb-java)
	* [2b. Create CustomerDatabaseV2 REST OpenAPI 3](#create-openapi)
- [3. App Connect Toolkit - Implement API](#toolkit-implement-api)
	* [3a. Implement getCustomers subflow](#get_customers)
	* [3b. Implement addCustomer subflow](#add_customer)
	* [3c. Implement getCustomer subflow](#get_customer)
	* [3d. Implement updateCustomer subflow](#update_customer)
	* [3e. Implement deleteCustomer subflow](#delete_c_ustomer)
- [4. Deploy](#deploy)
- [5. Test the API](#testing)
- [6. Summary](#summary)

---

# 1. Introduction <a name="introduction"></a>
In this lab, you will build Customer Database REST API using IBM App Connect Enterprise (ACE) Toolkit. You will implement CRUD operations along with the GET Operations.<br>

# 2. App Connect Toolkit - Prepare API <a name="toolkit-prepare-api"></a>

Open ACE Toolkit, and create workspace for lab1.<br>

![alt text](./images/image-1.png)


## 2a. Import CustomerDatabaseJava.zip <a name="import-cdb-java"></a>

**Download CustomerDatabaseJava.zip** from [<b><u>HERE</u></b>](./resources/CustomerDatabaseJava.zip)</b>

**Download openapi.json** from [<b><u>HERE</u></b>](./resources/openapi.json)</b>

Import CustomerDatabaseJava.zip into the Toolkit.<br>

![alt text](./images/image-1a.png)

![alt text](./images/image-1b.png)

![alt text](./images/image-1c.png)


## 2b. Create CustomerDatabaseV2 REST OpenAPI 3   <a name="create-openapi"></a>

![alt text](./images/image-2.png)

Type CustomerDatabaseV2 and click Finish.<br>

![alt text](./images/image-3.png)

![alt text](./images/image-100.png)

![alt text](./images/image-101.png)

Click \<Finish\>. <br>

**Set CustomerDatabaseJava as a referenced Project**
<br>
Right click on CustomerDatabaseV2 > Properties > Project References > Check mark "CustomerDatabaseJava" project. <br>

![alt text](./images/image-136.png)
<br><br>
<br>




# 3. App Connect Toolkit - Implement API <a name="toolkit-implement-api"></a>

## 3a. Implement getCustomers subflow <a name="get_customers"></a>

![alt text](./images/image-66.png)

![alt text](./images/image-20.png)

Drag and drop Compute Node from the Transformation pallete.<br>
![alt text](./images/image-21.png)

Double click on the Compute Node to open an ESQL Editor.<br>

Copy and paste the below PROCEDURE in the top.<br>
```
CREATE PROCEDURE getAllCustomers ( IN max INTEGER, INOUT output REFERENCE )
LANGUAGE JAVA
EXTERNAL NAME "CustomerDatabase.getAllCustomers";
```

![alt text](./images/image-22.png)

Copy and paste the below code between the BEGIN and END of the Main() function.
```
		-- Copy the headers over, but do not copy any message body.
		CALL CopyMessageHeaders();
		-- Process the 'max' parameter from the inbound request.
		-- If it is not specified, then default to -1 (all of the customers).
		DECLARE max INTEGER -1;
		IF FIELDTYPE(InputLocalEnvironment.REST.Input.Parameters.max) IS NOT NULL THEN
			-- Set up a handler for cast exceptions, and then attempt to cast the parameter to an integer.
			DECLARE EXIT HANDLER FOR SQLSTATE LIKE '%'
			BEGIN
				SET OutputLocalEnvironment.Destination.HTTP.ReplyStatusCode = 400;
				SET OutputRoot.JSON.Data.error = 'The value provided for the ''max'' parameter is not a valid integer.';
				RETURN TRUE;
			END;
			SET max = CAST(InputLocalEnvironment.REST.Input.Parameters.max AS INTEGER);

		END IF;
		-- Create a top level JSON array that will hold the customer records.
		CREATE LASTCHILD OF OutputRoot DOMAIN('JSON');
		SET OutputRoot.JSON.Data TYPE = JSON.Array;
		DECLARE output REFERENCE TO OutputRoot.JSON.Data;
		-- Retrieve the customer records by calling Java code.
		CALL getAllCustomers(max, output);
		RETURN TRUE;
```
Right click and click "Format" to format the ESQL code. <br>
Save (Control + s), and close the ESQL editor. <br>

Now, connect the nodes. <br>
![alt text](./images/image-23.png)

![alt text](./images/image-24.png)

Hit Control+s to save the flow. <br><br>






## 3b. Implement addCustomer subflow <a name="add_customer"></a>

![alt text](./images/image-67.png)

Drag and drop a mapping node into the canvas.<br>

![alt text](./images/image-25.png)

Double click on the mapping node.<br>

![alt text](./images/image-26.png)

![alt text](./images/image-68.png)

![alt text](./images/image-69.png)

Expand JSON domains on both Input and Output Assemblies. <br>
![alt text](./images/image-27.png)


Now we are going add User-Defined elements firstname, lastname, and address. <br>

Hover over on any field to popup "Add userdefined element" icon.<br>
![alt text](./images/image-137.png)

![alt text](./images/image-29.png)

Replace element1 with firstname.<br>
![alt text](./images/image-30.png)

Repeat the above and add two more UserDefined fields lastname, and address. <br>

![alt text](./images/image-31.png)

Connect Input JSONObject to Output JSONObject as shown below.<br>
![alt text](./images/image-32.png)

Replace Move Transform with CustomJava Transform. Click on the Move dropdown icon as below.<br>
![alt text](./images/image-33.png)

Now Expand Custom Transform, and select Custom Java Transform function.<br>
![alt text](./images/image-34.png)

Click on <b>Custom Java</b> and select Browse to select CustomerDtaabase Java Class, and for the Method select addCustomer.<br>

![alt text](./images/image-35.png)

Browse and type Customer to view Customer* classes. Select CustomerDatabase.java.<br>
![alt text](./images/image-28.png)

Now, assign payload data firstname, lastname, address data to the CustomerDatabase/addCustomer method parameters.<br>
Click Value column of the firstname and select "Edit Custom XPath expression.".<br>
![alt text](./images/image-70.png)

Custom XPath Builder opens.<br>
![alt text](./images/image-72.png)


Hit Control+Spacebar to view the suggested fields.<br>
Expand $Data (Input JSONObject), and select firstname.<br>
![alt text](./images/image-71.png)

Similarly, assign lastname, address fields as below.<br>
![alt text](./images/image-73.png)

Hit Control + S to save, and close the map. <br>

Now wire the Input Node > Mapping Node In Terminal, and Mapping Node Out Terminal > Output Node In Terminal as below.<br>

![alt text](./images/image-36.png)

Hit Control + S to save, and close the subflow. <br>
<br>




## 3c. Implement getCustomer subflow <a name="get_customer"></a>

![alt text](./images/image-74.png)

Drag and drop Mapping Node from the Tranformation pallete. <br>

![alt text](./images/image-37.png)

Select map type. <br>
![alt text](./images/image-38.png)

Select map inputs and outputs.<br>
![alt text](./images/image-39.png)

Select the domain to create the output.<br>
![alt text](./images/image-40.png)

Now your map look like this (default).<br>
![alt text](./images/image-41.png)

Add or remove headers and folders. Right click in the middle of the Message Assembly on left of the map.<br>
![alt text](./images/image-42.png)

Add LocalEnvironment header, and remove Properties header.<br>
![alt text](./images/image-43.png)

Similarly, repeat the above step on the Output Message Assembly.<br>
![alt text](./images/image-44.png)

Remove \"Move\" Operation.<br>
![alt text](./images/image-45.png)

Add CustomerDatabase JavaImport as below.<br>
![alt text](./images/image-138.png)

![alt text](./images/image-139.png)

Add \"User Defined\" variable as described below. <br>
In the input message assemtbly, expand LocalEnvironment Segment.<br>
Navigate to the REST > Input > Parameters section.<br>

Click 1:1 of \"any\" variable and hover over 1:1 to see two small icons and click on the first one which is "Add User-defined".<br>
![alt text](./images/image-46.png)

"element1" will be added.<br>
![alt text](./images/image-47.png)

Rename "element1" to "customerId".<br>
![alt text](./images/image-48.png)

<br>
<b>Lets create a if/else condition.</b>

Drag customerId to Message Asseembly. This will create <b>\"For Each\"</b>, but we will change it <b>\"if\"</b>, then to <b>Condition</b> section.<br>

![alt text](./images/image-49.png)

![alt text](./images/image-50.png)

Click on the dropdown/twisty to select \"if\". <br>
![alt text](./images/image-51.png)

Hover over \"if\" to see \"Add Else\" icon.<br>
![alt text](./images/image-52.png)

if/else condition section.<br>
![alt text](./images/image-53.png)


Implement if Condition. <br>
![alt text](./images/image-77.png)

Type customer in the blank area and select CustomerDatabase:customerExists(int) method.<br>

![alt text](./images/image-78.png)

Pick the customerId field which is being passed. You can use Control + Space as below<br>
![alt text](./images/image-79.png)

The condition should look like this.<br>
![alt text](./images/image-80.png)

Hit Control + s, to save the map. <br>
<br>

Click the <b>Edit</b> icon to implement the if condition.<br>
![alt text](./images/image-102.png)

![alt text](./images/image-56.png)

Replace "For Each" with "Custom Java". <br>
![alt text](./images/image-57.png)

Click on "Custom Java", and click the Properties tab in the bottom pane.<br>
![alt text](./images/image-140.png)

Browse and select "CustomerDatabase" and getCustomer(int id) method.<br>

Under the Parameters section, under Value for id click the blank area and select "customerId".<br>

![alt text](./images/image-55.png)




Now, <br>
a) wire "Custom Java" to Data segment of the JSON Output as below.<br>
b) Add error "User-defined" variable as you have done earlier.<br>

![alt text](./images/image-59.png)

Implement Else. Wire the Else to the Message Assembly.<br>
![alt text](./images/image-84.png)

![alt text](./images/image-85.png)

Now click on Else to Assign Output values.<br>
![alt text](./images/image-86.png)

Expand LocalEnvironment tree. <br>
Expand Destination > HTTP. Drag ReplyStatusCode to the left and release. That action will generate "Assign" transform.<br>
In the bottom Properties tab, assgin value 404 as below.<br>
![alt text](./images/image-87.png)

Collapse LocalEnvironment and expand JSON tree.<br>

Assign **"A customer with the specified ID does not exist in the Customer Database".**<br>

![alt text](./images/image-88.png)

Hit Control + S to save the map and close the map and click Ok if asked the map to be saved.<br>
<br>
Wire the Input Node > Mapping Node and Mapping Node's Out > Output Node's In Terminal. <br>

![alt text](./images/image-60.png)

Save and close the subflow and the map. <br>
<br>



## 3d. Implement updateCustomer subflow <a name="update_customer"></a>

![alt text](./images/image-89.png)

Drag and drop Mapping Node. <br>

![alt text](./images/image-90.png)

Wire Input, Mapping, and Output Nodes as below.<br>
![alt text](./images/image-61.png)

**Implement map:** Double click on the mapping node.<br>

Select type of map, Change the name to "updateCustomer_Mapping". <br>
![alt text](./images/image-91.png)

\<Next\><br>

Select map input, and output to be JSON Object.<br>
![alt text](./images/image-68.png)

Select the JSON Domain.<br>
![alt text](./images/image-69.png)

\<Finish\> <br>

![alt text](./images/image-63.png)

Delete the \"Move\" connection. <br>
![alt text](image-64.png)


<br>

**Add or remove headers folders.**<br>

Hover over on the "Message Assembly" on left to view square box. Click on the square box to see the Message Assembly popup.<br>
![alt text](./images/image-94.png)

Click on "Header Properties". <br>
Uncheck "Properties", and check "LocalEnvironment". <br>
![alt text](./images/image-95.png)

Repeat the same on the right side Message Assembly. <br>
![alt text](./images/image-96.png)

Expand "LocalEnvironment", navigate to REST Segment > Input > Parameters section.<br>

Add "User Defined" variable. Click 1:1 of "any" variable and hover over 1:1 to see two small icons and click on the first one which is "Add User-defined".<br>

Rename "element1" to "customerId".
![alt text](./images/image-97.png)

Expand JSON Domain and add 3 User-defined fields as below.<br>
![alt text](./images/image-107.png)



Add "CustomerDatabase" Java Import.<br>
![alt text](./images/image-103.png)

![alt text](./images/image-54.png)


![alt text](./images/image-104.png)


**Lets create a if/else condition.**<br>

Connect Input Message Assembly to the Output Message Asseembly. This will create "Submap" Transform. Change "Submap" to "If" Transform <br>

![alt text](./images/image-98.png)


Add an "Else" Condition.<br>
![alt text](./images/image-141.png)

Now, click on "if" condition and check the Properties tab.<br>
Click on "Condition" tab, and Control+Spacebar to select CustomerDatabase:customerExists() method.<br>
![alt text](./images/image-105.png)

Now, use Control+Spacebar and select $MessageAssembly/LocalEnvironment/REST/Input/Parameters/customerId as below.
![alt text](./images/image-142.png)

Hit Control+s and save the map. <br>

Implement "If" condition, if the customerExists() is true.<br>
![alt text](./images/image-108.png)


Add User-Defined variable called "error".<br>
![alt text](./images/image-110.png)

![alt text](./images/image-111.png)

Add "Custom Java" Connection on "Data" JSONObject .<br>

![alt text](./images/image-113.png)
id: $MessageAssembly/LocalEnvironment/REST/Input/Parameters/customerId<br>
firstname: $MessageAssembly/io:JSON/Data/firstname<br>
lastname: firstname: $MessageAssembly/io:JSON/Data/lastname<br>
address: firstname: $MessageAssembly/io:JSON/Data/address<br>

Save and close the Map, and the Subflow.
<br><br>




## 3d. Implement deleteCustomer subflow <a name="delete_customer"></a>

![alt text](./images/image-114.png)

Drag and drop a JavaCompute Node. <br>
![alt text](./images/image-115.png)

Connect the Nodes as below. <br>
![alt text](./images/image-116.png)


<br>

![alt text](./images/image-122.png)

<br>

![alt text](./images/image-123.png)

Save and close the Subflow.<br>
<br>
<br>



# 4. Deploy <a name="deploy"></a>


**Create BAR (Broker Archite) file.**

Right click on CustomerDatabaseV2 project, and select "New" > select "BAR file".<br>
![alt text](./images/image-119.png)

Select the REST API.<br>
![alt text](./images/image-120.png)


![alt text](./images/image-121.png)


**Deploy BAR (Broker Archite) file.**

Create a Local Integration Server.<br>
![alt text](image-117.png)

Keep the default name "TEST_SERVER", and click "Finish".<br>

Drag and drop the cdb.bar file into the TEST_SERVER as below.<br>
![alt text](image-118.png)

![alt text](image-124.png)


# 5. Testing <a name="testing"></a>

**Take a small break!!!**


Start Web User Interface. <br>
![alt text](./images/image-125.png)

![alt text](./images/image-126.png)


![alt text](./images/image-127.png)



![alt text](./images/image-128.png)

Lets run some simple tests from the Terminal.<br>

### GET /customers
curl -H "Content-Type: application/json" --request GET --url http://localhost:7800/customerdb/v2/customers

![alt text](./images/image-129.png)

### POST /customers
```
curl -H "Content-Type: application/json" --request POST --url http://localhost:7800/customerdb/v2/customers --data "{\"firstname\": \"Sudhakar\", \"lastname\": \"Bodapati\", \"address\": \"123 Drexel Hill, Mullica Hill, NJ\"}"
```
![alt text](./images/image-106.png)


Now, run GET /customers to see if the new Customer added.<br>
```
curl -H "Content-Type: application/json" --request GET --url http://localhost:7800/customerdb/v2/customers
```
![alt text](./images/image-130.png)


### GET /customers/{customerId}
```
curl -H "Content-Type: application/json" --request GET --url http://localhost:7800/customerdb/v2/customers/9
```
![alt text](./images/image-131.png)


### PUT /customers/{customerId} - Update Customer address
```
curl -H "Content-Type: application/json" --request PUT --url http://localhost:7800/customerdb/v2/customers/9 --data "{\"firstname\": \"Sudhakar\", \"lastname\": \"Bodapati\", \"address\": \"123 Drexel Hill Drive, Mullica Hill, NJ\"}"
```
![alt text](./images/image-132.png)

-- GET /customers/9
```
curl -H "Content-Type: application/json" --request GET --url http://localhost:7800/customerdb/v2/customers/9
```

![alt text](./images/image-133.png)



### DELETE /customers/{customerId}
```
curl -H "Content-Type: application/json" --request DELETE --url http://localhost:7800/customerdb/v2/customers/9
```

![alt text](./images/image-134.png)

-- GET /customers/9
```
curl -H "Content-Type: application/json" --request GET --url http://localhost:7800/customerdb/v2/customers/9
```
![alt text](./images/image-135.png)



# 5. Summary <a name="summary"></a>


Congratulations! You have successfully created a REST OpenAPI 3.0 using IBM App Connect Toolkit.

<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)

<br>