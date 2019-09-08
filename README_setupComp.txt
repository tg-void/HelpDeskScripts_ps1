1. Make sure special Ethernet adapter is plugged in.
2. Run Powershell as Administrator.
3. Type 'set-executionpolicy unrestricted' and hit enter.
4. Type '& "D:\setupComp.ps1"' where D is the driver letter of the USB.
5. Enter information as appropriate, decide which software to install, and accept every other choice confirmation question. One of the choice confirmation requests has no as the default answer, so be sure to enter 'y' for that one to accept it.
6. A popup box will appear; enter your NetID@tamu.edu and password for domain approval. At this point, allow the computer time to install the software requested. If you requested that all the baseline software be installed, it will take about 30-45 minutes.
7. When the script completes, make sure to tell [boss] the name of the computer so it is put in the Group Policy Folder and, if it is brand new, give [boss] the MAC address so that the device can be registered.
8. Restart the computer and make sure all settings are correct.




Initial Design and Brainstorming:

SetupComp.exe is designed for USB usage by copying the program onto a new Windows 10 computer from the USB and executing from there.
I would love for there to be a loading bar for the entire program, but that is optional and should only be done after the program is completely operational.
Need error detection with list of errors to output in an array probably.
After this program, the last thing the user will need to do is "gpupdate /force" following restart.


ASK FOR COMPUTER INFO
-set all user info request to easily identifiable vars
	-ask for new admin password
		-turn into fnctn that compares two pass entries
		-forces a retry if they don't match
		-proceeds as normal if they do match
	-ask for computer name in form of "GroupAdvisor-RoomNumber"
	-ask for NetID@tamu.edu and NetID pass for adding to the domain
	-verify baseline software to be installed
		-probably best to list software that will be installed and opt out of installing specific software by typing the name case-insensitive or preferably 		  unchecking a box

COMPUTER MANAGEMENT
	-use admin pass var to set pass of local administrator account
	-change local administrator account properties to uncheck "Password never expires" and "Account is disabled"

CHANGE NETWORK DNS SETTINGS
	-Network and Internet Settings > Network and Sharing Center > Change adapter settings > Ethernet Properties (thru right-click on Ethernet) > Internet 	  Protocol Version 4 (TCP/IPv4)
	-add 5 DNS servers under the "Advanced" tab
		-165.91.176.17
		-165.91.176.18
		-165.91.176.19
		-128.194.254.1
		-128.194.254.2

ADD COMPUTER TO CHEMISTRY DOMAIN
	-change computer name to compName var from user info request
	-add computer to chem.tamu.edu domain
	-use netid@tamu.edu and netid pass vars to verify access to the domain
	-continue without restarting

INSTALL BASELINE PROGRAMS
	-assess if computer is 64bit or 32bit and install programs accordingly
	-baseline programs include:
		-Google Chrome
		-Firefox
		-Microsoft Office 2019 (verify that internet connection is working before allowing the user to attempt this)
		-Symantec
		-Adobe? which version?
		-Spirion?
	-2 ways to go about it:
		-have user individually verify each software program thru PowerShell lines by hitting enter a bunch of times (opt-in)
		-have user enter names of software programs, case insensitive, to not install (opt-out)
			-can also be done by oferring a popup that has all boxes checked and you uncheck boxes of software you do not want installed
	-set a variable to true or false (initially true or false depending on opt-in or opt-out design) based on user input of whether or not they want that software
	-for each software, if statement that triggers install if software var is true

NOTIFY USER TO ADD TO GROUP POLICY FOLDER
	-trigger Windows Update
	-after Windows Update starts and is going, THEN notify the user to add comp to group policy folder with a pop up
	-when Windows Update is finished, notify the user to restart the computer (preferably with a popup button)
