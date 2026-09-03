package com.ibm.esb.common;

import java.net.InetAddress;
import java.util.Random;


public class StaticMethods {

	public static String getHostName() {
		String hostname = null;
		try {
			hostname = InetAddress.getLocalHost().getHostName();
			// System.out.println("Hostname: " + hostname);
		} catch (Exception e) {
			;
		}
		return hostname;
	}

	public static Long randomNumberBetweenMinAndMax1(Long min, Long max) {
		long rand = (long) (Math.random() * (max - min + 1) + min);
		return rand;
	}


}
