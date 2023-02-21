# COEN-174
Project for COEN 174 Winter 2022
_Before building or running the code, please note that you need a Mac running Xcode 14 and iOS 16 simulators
For now, the app has been tested on the iPhone 14 Pro and 14 Pro Max, but it should run fine on any supported Apple platform._

###Running the App
Clone the front-end repo from: https://github.com/gryder8/COEN-174  

_You should be able to do this from the Xcode launch screen, but you can clone it normally and simply open it in Xcode as well_
_Make sure you have the iOS 16 Simulator installed, it should come default with Xcode 14_
Press CMD+B to build, CMD+R to run on the simulator
If you like, you may run it on your iPhone after enabling developer mode
Note that it often takes a little bit when you first run it to attach to the simulator
If the build or run fails and gives you an error, change the development team by going to the project definition (top tab), clicking signing and capabilities and changing the team to your personal team `COEN 174 > Signing & Capabilities > Team`
Select `Automatically Manage Signing` if not selected already
The app should then launch and call the API to query data from

###Running Unit Tests
_Make sure the above steps for running the app are completed_
Locate the `COEN 174Tests` and `COEN 174UITests` folders in Xcode
These folders contain the unit tests, which you run from Xcode 
Inside these files, you should see unit and UI unit tests with run buttons next to them in the line number side ribbon
You should be able to run all the main unit tests by clicking the play button next to the `COEN174_Tests` class declaration
Running the app does not run these tests
Running unit tests involves attaching to the simulator, so it can take some time initially
UI Unit Tests are in the `COEN 174UITests` folder and must be run separately
