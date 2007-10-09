/*
 * @(#)Vjde.java 1.0 05/05/29
 *
 * You can modify the template of this file in the
 * directory ..\JCreator\Templates\Template_1\Project_Name.java
 *
 * You can also create your own project template by making a new
 * folder in the directory ..\JCreator\Template\. Use the other
 * templates as examples.
 *
 */
package myprojects.vjde;

import java.awt.*;
import java.awt.event.*;

class Vjde extends Frame {
	
	public Vjde() {
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				dispose();
				System.exit(0);
			}
		});
	}

	public static void main(String args[]) {
		System.out.println("Starting Vjde...");
		Vjde mainFrame = new Vjde();
		mainFrame.setSize(400, 400);
		mainFrame.setTitle("Vjde");
		mainFrame.setVisible(true);
	}
}
