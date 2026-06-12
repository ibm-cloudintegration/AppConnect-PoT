# Debugging a message flow in App Connect Toolkit

[Return to App Connect labs page](../../index.md)

---

# Table of Contents
- [1. Introduction](#introduction)
- [2. Workshop Environment](#workshop-env)
- [3. App Connect Toolkit](#toolkit)
- [4. Flow Exerciser](#flow)
- [5. Debug Perspective ](#debug)
- [6. Trace Nodes ](#trace)
- [7. Summary ](#summary)
- [8. References ](#references)

---
<br>

# 1. Introduction <a name="introduction"></a>

This lab focuses on exploring and practicing various techniques for debugging message flows during development in an integration environment for IBM App Connect Enterprise.
The primary objective is to understand and apply three distinct debugging approaches to effectively identify and resolve issues in message flows:

[Flow Exerciser](#flow)<br>
A tool that allows developers to test and exercise message flows in a controlled manner without requiring external systems or live connections. It enables simulation of input messages, stepping through the flow, and inspection of message content at various points.

[Debug Perspective](#debug) <br>
Utilizes the integrated debugger within the development toolkit. This method provides a full-featured debugging experience, including setting breakpoints, stepping through nodes, inspecting variables and message trees, and monitoring execution in real-time.

[Trace Nodes](#trace) <br>
Involves inserting dedicated trace nodes into the message flow to log specific information (such as message content, properties, or custom text) at key points. These traces are typically written to files or user traces for later analysis, making it suitable for debugging in both development and production-like environments.

By working through these three methods, participants gain hands-on experience with different debugging strategies, ranging from interactive real-time debugging to non-intrusive tracing, enabling them to choose the most appropriate technique based on the scenario.

<br>



# 2. Workshop Environment <a name="workshop-env"></a>

![alt text](./images/env.png)

You will be doing the lab from the Windows Virtual Machine. <br>
<br>

<!--

# 2. PreRequisites <a name="prereq"></a>
- IBM App Connect Enterprise 13.x in Windows VM
	- You can download it from [here](https://www.ibm.com/docs/en/app-connect/13.0.x?topic=gsace-download-app-connect-enterprise-evaluation-edition-get-started) 
- Access to CMD (Windows) 

<br>

<hr>
-->



<!--
# 3. Prepare Environment  <a name="env"></a>
-->

# 3. App Connect Toolkit <a name="toolkit"></a>

- Start IBM App Connect Enterprise Toolkit in a new workspace <br><br>
![alt text](./images/1.jpg)

- Download Lab files
	- [Project Interchange](./downloads/ProjectInterchange.zip)
	- [LabFiles](./downloads/TransformationMapDebug.zip)

- Unzip TransformationMapDebug.zip in the C:\> directory <br><br>
![alt text](./images/2.jpg)

- Import Project Interchange to the toolkit
	- Right click in the project view and select Import...<br>
	- Select Project Interchange and click Next> <br><br>
	![alt text](./images/3.jpg) <br><br>
	- Browse and select the ProjectInterchange.zip, select the project Transformation_Map and click Finish <br><br>
	![alt text](./images/4.jpg) <br><br>
	- You should see the project in the Application Development View <br><br>
	![alt text](./images/5.jpg)

- Create a new Integration Server for Testing
	- Right click Integration Servers and select <b> Create a local Integration Server</b> <br><br>
	![alt text](./images/6.png) <br><br>
	- Leave everything by default and click Finish</b> <br><br>
	![alt text](./images/7.png) <br><br>
	- Right click the new Integration Server and select <b>Start</b></b> <br><br>
	![alt text](./images/8.png) <br><br>
	- After some time you should see the server was started. Click OK<br><br>
	![alt text](./images/9.png) <br><br>
	- To deploy the application, drag and drop the project called Transformation_Map into the TEST_SERVER. After a few seconds you will see a successful message.<br><br>
	![alt text](./images/10.png)

- Test the application
	- Open a Windows CMD(Command Prompt)
	- Execute the following commands:
      ```cmd
		cd C:\TransformationMapDebug
		curl -X POST http://localhost:7800/Transformation_Map -d @input.xml
		```
	- You should see a response XML from the service <br><br>
	![alt text](./images/11.png)

[Go to Top](#introduction)
<br>
<hr>



# 4. Flow Exerciser  <a name="flow"></a>
To check that a message flow or integration service is processing messages as expected, you can send messages to the flow by using the Flow Exerciser or an external client. You can then use the Flow Exerciser to show the path that each message took. You can also view the structure and content of the message assembly at any point in a message flow. 

- Double click the integration flow to open the editor<br><br>
![alt text](./images/12.png)

- The canvas will show the message flow that routes 3 separate paths depending on the received input<br><br>
![alt text](./images/13.png)

- Click on the record icon from the message flow<br><br>
![alt text](./images/14.png)

- Click on Yes to confirm the re-deploy of the flow<br><br>
![alt text](./images/15.png)

- Wait for the flow to be deployed and click OK<br><br>
![alt text](./images/16.png)

- You will see the <b>Ready to record message</b>, select the <b>Do not show this message again</b> and click <b>Close</b><br><br>
![alt text](./images/17.png)

- Click the <b> Send a message to the flow</b> icon<br><br>
![alt text](./images/18.png)

- Select input1 for the Input Messages and click Send<br><br>
![alt text](./images/19.png)

- The message was sent to the flow. Click Close to view the results<br><br>
![alt text](./images/20.png)

- You will see the path the message took highlighted in blue <br><br>
![alt text](./images/21.png)

- You can also click the little message icon to see the message content in any point<br><br>
![alt text](./images/22.png)

- When clicked, the Message Assembly is open so you can browse the message content. Click Save if you want to save the message for future analysis.<br><br>
![alt text](./images/23.png)

- Click on the <b>Clear recorded messages</B> icon<br><br>
![alt text](./images/24.png)

- Select input2 for the Input Messages and click Send<br><br>
![alt text](./images/25.png)

- This time you will see a different path the message took highlighted in blue<br><br>
![alt text](./images/26.png)

- If you run the flow again using input3 you should see the remaining path was executed<br><br>
![alt text](./images/27.png)

- Once finished click on the <b>Return flow to edit mode</b> icon <br><br>
![alt text](./images/28.png)

- Click Yes to return to edit mode<br><br>
![alt text](./images/29.png)

- This concludes the section for Flow Exerciser <br><br>


[Go to Top](#introduction)
<br>
<hr>


# 5. Debug Perspective  <a name="debug"></a>
The Debug perspective is where you test and debug a graphical representation of your message flows using the message flow debugger.

- Right click the integration server a click on the <b>Launch Debugger(Port 9997)</b> , port may vary <br><br>
![alt text](./images/30.png)

- A task will appear on the Progress Tab, wait it to finish, at the end you will see a little debug icon in your integration server <br><br>
![alt text](./images/31.png)

- Right click each link to add Breakpoints(5) according to the flow diagram <br><br>
![alt text](./images/32.png)


- Test the application
	- Open a Windows CMD(Command Prompt)
	- Execute the following commands:
      ```cmd
		cd C:\TransformationMapDebug
		curl -X POST http://localhost:7800/Transformation_Map -d @input.xml
		```

- Back in the Integration Designer toolkit you will see a dialog to confirm switching to the debug perspective. Click Switch <br><br>
![alt text](./images/33.png)

- The debugger will stop in the first breakpoint<br><br>
![alt text](./images/34.png)

- In the right window you can explore the Variables(Message Content), Breakpoints and Expressions <br><br>
![alt text](./images/35.png)

- In the left window you can explore the stack trace associated with the execution <br><br>
![alt text](./images/36.png)

- Click the Resume icon to let the execution continue <br><br>
![alt text](./images/46.png)

- The next breakpoint according to the flow is reached, you can explore the state of the variables at this point <br><br>
![alt text](./images/37.png)

- If you click Resume again you will reach the final breakpoint, you can explore the state of the variables at this point <br><br>
![alt text](./images/38.png)

- If you click Resume again you can go back to the CMD to validate the response was obtained<br><br>
![alt text](./images/39.png)

- Test the application one more time using input3 as the payload
	- Open a Windows CMD(Command Prompt)
	- Execute the following commands:
      ```cmd
		cd C:\TransformationMapDebug
		curl -X POST http://localhost:7800/Transformation_Map -d @input3.xml
		```

- The debugger will stop in the first breakpoint <br><br>
![alt text](./images/40.png)

- If you click Resume you will see that this time the flow took a different path, according to the payload <br><br>
![alt text](./images/41.png)

- If you click Resume again you will reach the final breakpoint, you can explore the state of the variables at this point <br><br>
![alt text](./images/42.png)

- If you click Resume again you can go back to the CMD to validate the response was obtained. Notice that the response XML is different from the first one<br><br>
![alt text](./images/43.png)

- Click on the <b>Integration Development</b> icon to go back to the default perspective <br><br>
![alt text](./images/44.png)

- Right click the Integration Server and click <b>Terminate Debugger(Port 9997)</b> to stop de debugger <br><br>
![alt text](./images/45.png)

- This concludes the section for Debug Perspective <br><br>


[Go to Top](#introduction)
<br>
<hr>


# 6. Trace Nodes  <a name="trace"></a>
Use the Trace node to generate trace records that you can use to monitor the behavior of a message flow.
Trace records can incorporate text, message content, and date and time information, to help you to monitor the behavior of the message flow.

You can write the records to the user trace file, another file, or the local error log

- Notice that the integration flow has <b>Trace Nodes</b> as part of its path. This nodes are used to record important information about the flow.<br><br>
![alt text](./images/47.png)

- In the lower section under Properties to can configure the node behavior. The Destination was configured to <b>File</b>, the file path is using the folder under the C: directory and the pattern is making the node to write all the content of the message including headers and body, that is why is using <b>${Root}</b><br>
The pattern is highly configurable, you can add your own text and specify which exact part of the message you want to write to the file. See [link](https://www.ibm.com/docs/en/app-connect/13.0.x?topic=nodes-trace-node)<br><br>
![alt text](./images/48.png)

- Test the application one more time using input3 as the payload
	- Open a Windows CMD(Command Prompt)
	- Execute the following commands:
      ```cmd
		cd C:\TransformationMapDebug
		curl -X POST http://localhost:7800/Transformation_Map -d @input3.xml
		```

- Using the File Explorer go to the folder TransformationMapDebug > trace. You will see two files, one for each Trace Node that is configured in our project. One input and one output<br><br>
![alt text](./images/49.png)

- The first file shows all the content for the input of the flow (mytrace_input.log)<br><br>
![alt text](./images/50.png)

- The second file shows all the content for the output of the flow (mytrace_output.log)<br><br>
![alt text](./images/51.png)

- You can use this technique to include details and examine the value of variables in a flow execution<br>

- You can use the IBM App Connect Enterprise administration REST API to enable or disable Trace nodes on an integration server, without having to restart the integration server. See [link](https://www.ibm.com/docs/en/app-connect/13.0.x?topic=server-enabling-disabling-trace-nodes)<br>

- You can also enable and disable Trace nodes by setting properties in the server.conf.yaml configuration file. See [link](https://www.ibm.com/docs/en/app-connect/13.0.x?topic=trace-switching-nodes-off)<br><br>

- This concludes the section for Debug Perspective <br><br>

[Go to Top](#introduction)
<br>
<hr>



# 7. Summary <a name="summary"></a>
This lab has provided a comprehensive exploration of three essential debugging techniques for message flows in IBM App Connect Enterprise.

The Flow Exerciser offers a lightweight, interactive way to test flows in isolation, ideal for quick validation and simulation without external dependencies.

The Debug Perspective delivers powerful, real-time debugging capabilities with breakpoints, step-through execution, and detailed message inspection, making it the go-to choice for in-depth troubleshooting during active development.

Trace Nodes provide a flexible, low-overhead method to capture diagnostic information at specific points, suitable for both development and production environments where interactive debugging may not be feasible.

By mastering these approaches, participants are now equipped to select the most effective debugging strategy based on the context—whether rapid iteration, detailed analysis, or non-intrusive monitoring. Combining these techniques will significantly improve troubleshooting efficiency, reduce development time, and lead to more robust and reliable message flows.
Effective debugging is a critical skill in integration development; applying these methods in real-world scenarios will help ensure high-quality, maintainable solutions.



# 8. References <a name="references"></a>

Testing your message flow by using the Flow Exerciser: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=ttmf-testing-your-message-flow-by-using-flow-exerciser" target="_blank"> https://www.ibm.com/docs/en/app-connect/13.0.x?topic=ttmf-testing-your-message-flow-by-using-flow-exerciser</a>

Flow debugger overview: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=debugger-flow-overview" target="_blank">https://www.ibm.com/docs/en/app-connect/13.0.x?topic=debugger-flow-overview</a>

Trace Node: <br>
<a href="https://www.ibm.com/docs/en/app-connect/13.0.x?topic=nodes-trace-node" target="_blank">https://www.ibm.com/docs/en/app-connect/13.0.x?topic=nodes-trace-node</a>


<br>

[Go to Top](#introduction)

<br>

[Return to App Connect labs page](../../index.md)