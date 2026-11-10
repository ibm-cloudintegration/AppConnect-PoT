import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.CommonClientConfigs;

import java.io.IOException;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;

public class AsyncApi_Consume_Flight_Landing_Events {
	public static final void main(String args[]) {
		Properties props = new Properties();

//		props.put("bootstrap.servers",
//				"eventstreams-kafka-bootstrap-cp4i-es.ocp-dev-290268003089a11bfac4ffe6a9d666b7-0000.us-east.containers.appdomain.cloud:443");
	   // props.put("bootstrap.servers", "apis-minim-a2901f0b-event-gw-client-cp4i-apic.ocp-dev-290268003089a11bfac4ffe6a9d666b7-0000.us-east.containers.appdomain.cloud:443");
		 props.put("bootstrap.servers", "apis-egw-event-gw-client-cp4i-apic.ocp-dev-e8d7fad266f3d495445c089746d902f0-0000.us-east.containers.appdomain.cloud:443");

		props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
		props.put("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer");

		props.put("group.id", "2");
	    props.put("client.id", "166ac2ec-60dc-46ed-a3de-6122c855e9e7");

		props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");

		props.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
	    props.put(SaslConfigs.SASL_JAAS_CONFIG,
	    	      "org.apache.kafka.common.security.plain.PlainLoginModule required " +
	    	      "username=\"a92312d5d4628cdd48fddb98f8c5a6aa\" " +
	    	      "password=\"02ea1de5b06de5d1fcffe108df50c576\";");

	    // The Kafka cluster may have encryption enabled. Contact the API owner for the appropriate TrustStore configuration.
	    props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "/Users/sbodapati/xibm_ts/sb_demos/eventstreams/eventgateway/egw-cert.jks");
	    props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "passw0rd");
	    props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "JKS");
	    props.put(SslConfigs.SSL_ENDPOINT_IDENTIFICATION_ALGORITHM_CONFIG, "");

		KafkaConsumer<String, byte[]> consumer = new KafkaConsumer<String, byte[]>(props);
		consumer.subscribe(Collections.singletonList("STUDENT00.FLIGHT.LANDINGS"));
		//try {
			while (true) {
				ConsumerRecords<String, byte[]> records = consumer.poll(Duration.ofSeconds(10));
				for (ConsumerRecord<String, byte[]> record : records) {
					byte[] value = record.value();
					String key = record.key();
					ObjectMapper om = new ObjectMapper();
					JsonNode jsonNode;
					try {
						jsonNode = om.readTree(value);
					
					// Do something with your JSON data
						
					String flightNumber = jsonNode.get("flight").asText();
					String terminal = jsonNode.get("terminal").asText();
					String numPassengers = jsonNode.get("passengers").asText();
			
					System.out.println("DEBUG: A FLIGHT HAS LANDED!");
					System.out.println("           time landed: " + jsonNode.get("timestamp").asText());
					System.out.println("              location: " + jsonNode.get("location").asText());
					System.out.println("               airport: " + jsonNode.get("airport").asText());
					System.out.println("               airline: " + jsonNode.get("airline").asText());
					System.out.println("         flight number: " + flightNumber);
					System.out.println("              terminal: " + terminal);
					System.out.println("                  gate: " + jsonNode.get("gate").asText());
					System.out.println("  number of passengers: " + numPassengers);
					
					System.out.println("  ");

					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			}
	}
}