# HDL Environment

> Create two chapter:
> one dealing with the `fixed` stuff like hardware, Quartus, Verilog
> 
> and the create another chapter for programming> 
> then go to the actual block-programming philosophy


For this project we decided to use Verilog as hardware language. A reason is that its extended version System Verilog is used in companies for programming.

The board that we use it the DE....

The FPGA is the EX...

- BOARD: DE4 Stratix IV Development BOARD
- CORE: Stratix IV GX
- CHIP: EP4SGX230KF40C2
- LANGUAGE: Verilog


## Quartus

To program the FPGA we used the software Quartus 21.1 (latest version at the moment). Indeed, we are using it only to compile and load the code into the hardware, we are not using it as developing interface.



> THESE TWO NEXT SECTIONS NEED TO BE MERGED SINCE THE AIM IS THE SAME: EXPLAIN THE COMPILING ENVIRONMENT AND POSSIBLE PROBLEMS THAT CAN RISE

### Version 1 from docx

WHAT IS NEEDED TO WORK
Quartus Prime
 - Download software from [Intel software platform](https://fpgasoftware.intel.com/?edition=standard)
   1. Download Quartus Prime software, and any other software products you want to install, into a temporary directory.
   2. Download device support files into the same directory as the Quartus Prime software installation file.
   3. If you want to use add-on software, download the files from the Additional Software tab. Save the files to the same temporary directory as the Quartus Prime software installation file.
   4. Run the QuartusSetup-21.1.0.169-windows.exe file.
   > All software and components downloaded into the same temporary directory are automatically installed; however, stand-alone software must be installed separately.
   > Download file size is independent of installation size. You must have space for both download files and software installation. Download files may be deleted after the installation completes.
   - Quartus Prime (includes Nios II EDS) [QuartusSetup-21.1.0.842-windows.exe]
   - Stratix IV device support (chose support device) [stratixiv-21.1.0.842.qdz]
   - Questa - Intel FPGA Edition(includes Starter Edition) (new name for Modelsim – now require license, there is also a free license)
 - Install the software
   - Lunch the installer (if the device file *.qdz is in the same folder is automatically selected)
   - Install in a folder near the root C:\mynameFPGA [there should be less problem when programming avoiding long path and special characters]
   - Allow the installation of the USB driver Altera
 - LICENSE (how to manage the license)
 - ModelSim


### Version 2 from tex

#### Installing

Some notes about installing the necessary softwares.
LICENSE
1. go to [https://licensing.intel.com/psg/s/](https://licensing.intel.com/psg/s/) and access with the credential already linked to the device.
2. go to *Computers and License Files* to create a new license (licenses are linked to the PC and also to the
ethernet network (MAC address)
3. add a new Computer (*New*)
   - Computer name: right click on `start` and then *System* $\rightarrow$ *Device name*
   - Computer Type: NIC ID, go to Command Line in Win “`cmd`” and type `ipconfig/all`. Find the Physical Adress of the interface (connection) that you are using (you also find the host name) [probably other interfaces on the same PC can be added]
4. go to *Licenses-All Licenses* and choose the one related to the product you need to activate
5. *Generate License* $\rightarrow$ *Assign an Existing Computer* [you should be able to rehost. . . otherwise you’re . . . ]
6. Choose the computer
7.

#### Quartus

- go to the RTL1 view
- assign the PIN (use csv file to define the connection)
  
##### NEW PROJECT
1. File $\rightarrow$ New Project Wizard
2. Select/Create the folder for the project
3. Give a name to the project and select/create the TOP file of the code
4. Select `Empty Project`
5. In case select existing files (blocks), then `Next`
6. Select the device on the board
7. If necessary link simulation programs or others
8. Finish

##### PIN ASSIGNEMENT
1. *Assignments*
2. *Import Assignment*
3. Select the `*.csv` file, then *Ok*

Press the button play to compile the code

##### LOAD the CODE
1. Open the Programmer [small image]
2. Press on `Hardware Setup`
3. On *Currently selected hardware* select `USB-Blaster [USB-0]`. If not present maybe is necessary to update the driver of the USB blaster (on your PC go to device-Select the USB-Update Driver-Make windows search
in the installation folder of Quartus)
4. Press `Start` to load the code [A blue led should be ON on the board]

##### POSSIBLE PROBLEMS


```{important}

Error: `Error: Can’t open project -- you do not have permission to write to all the files or
create new files in the project’s database directory` $\rightarrow$ look at [this link](https://www.intel.com/content/www/us/en/support/programmable/articles/000084612.html)

**Description**

You may get this error when you open a project in the Nios(R) II IDE.

The problem is that the write protection bits to several files and directories has been set.

You can check this by pointing to your project directory (Example: *C:\Projects*) and right-clicking on your mouse button over the bar where Name, Size, Type and Date Modified columns are shown. Select the Attributes field. If an `R` is shown for any of the files or directories in your project directory, then you have this problem.

To solve this:

1. Open a command shell (*Start menu $\rightarrow$ Run... -> Enter cmd* and press *OK*).

2. Change to the project directory, i.e. `cd <project path>` and press Enter.

3. Run the one of the following commands:

   `attrib -R /S /D *`

   or

   `attrib -R /S /D .`


This should clear the write protection flags for all the files and subdirectories in this project directory.

It is not necessary to delete or reinstall any files or directories.
```





#### Simulation
Describe how to setup a simulation in Modelsim (Questasim)
$\rightarrow$ it is possible to generate a file `*.do` to lunch for the simulation (should simplify the steps).


## Visual Studio Code

VScode usage with plugins for linting of Verilog (need model sim on the path)


In VSC, put the ctags under admin folder so that antivirus don’t block it (`ctags.exe`)

