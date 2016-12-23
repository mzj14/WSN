/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA,
 * 94704.  Attention:  Intel License Inquiry.
 */

import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;

/* The "Oscilloscope" demo app. Displays graphs showing data received from
   the Oscilloscope mote application, and allows the user to:
   - zoom in or out on the X axis
   - set the scale on the Y axis
   - change the sampling period
   - change the color of each mote's graph
   - clear all data

   This application is in three parts:
   - the Node and Data objects store data received from the motes and support
     simple queries
   - the Window and Graph and miscellaneous support objects implement the
     GUI and graph drawing
   - the Oscilloscope object talks to the motes and coordinates the other
     objects

   Synchronization is handled through the Oscilloscope object. Any operation
   that reads or writes the mote data must be synchronized on Oscilloscope.
   Note that the messageReceived method below is synchronized, so no further
   synchronization is needed when updating state based on received messages.
*/
public class Oscilloscope implements MessageListener
{
    MoteIF mote;

    // BufferedWriter bufferedWriter;
    // File file = new File("result.txt");
    File file = new File("result.txt");
    //
    // /* The current sampling period. If we receive a message from a mote
    //    with a newer version, we update our interval. If we receive a message
    //    with an older version, we broadcast a message with the current interval
    //    and version. If the user changes the interval, we increment the
    //    version and broadcast the new interval and version. */
    //
    // /* Main entry point */
    void run() {
       System.out.println("PC File application run");
       mote = new MoteIF(PrintStreamMessenger.err);
       mote.registerListener(new OscilloscopeMsg(), this);
    }

    void outputMsg(OscilloscopeMsg omsg) {
        try {
            FileWriter fileWiter = new FileWriter(file, true);
            BufferedWriter bufferedWriter = new BufferedWriter(fileWiter);

            bufferedWriter.write(omsg.get_id() + " ");
            bufferedWriter.write(omsg.get_count() + " ");
            bufferedWriter.write(omsg.get_temperature() + " ");
            bufferedWriter.write(omsg.get_humidity() + " ");
            bufferedWriter.write(omsg.get_light() + " ");
            bufferedWriter.write(omsg.get_current_time() + " ");
            bufferedWriter.newLine();
            bufferedWriter.close();
            fileWiter.close();
        } catch (IOException e) {
            System.out.println(e);
        }

        System.out.print("version = " + omsg.get_version());
        System.out.print("interval = " + omsg.get_interval());
        System.out.print("id = " + omsg.get_id());
        System.out.print("count = " + omsg.get_count());
        System.out.print("temperature = " + omsg.get_temperature());
        System.out.print("humidity = " + omsg.get_humidity());
        System.out.print("light = " + omsg.get_light());
        System.out.print("current_time = " + omsg.get_current_time());
        System.out.print("token = " + omsg.get_token());
        System.out.print("\n");
        
    }

    public synchronized void messageReceived(int dest_addr,
            Message msg) {
    if (msg instanceof OscilloscopeMsg) {
        OscilloscopeMsg omsg = (OscilloscopeMsg)msg;
        outputMsg(omsg);
    }
    }
    public static void main(String[] args) {
    Oscilloscope me = new Oscilloscope();
    /*
    try {
        file = new File("result.txt");
    } catch (IOException e) {
        System.out.println(e);
    }
    */

    // FileWriter fileWiter = new FileWiter(file);
    // bufferedWriter = new BufferedWriter(fileWiter);
    me.run();
    }

}
