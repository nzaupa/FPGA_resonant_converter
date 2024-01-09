# ModelSim

To simulate Verilog code you have to write another program which will run the TOP block (or any other block you wish to simulate).

These kind of files are called test-bench.


important parts in the code which defines the length of a clock cycles

```verilog
`timescale 1 ns / 1 ps
```

Generate a clock signal if needed

```verilog
always begin //100MHz @ 1ns scale
   CLK = 1'b1;
   #5       // number of clock cycles to wait
   CLK = 1'b0;
   #5;
end
```



If you have a signal step by step do like:
```verilog
initial begin
   a = 4'b0000;
   b = 4'b0000;
   #20
   a = 4'b1111;
   b = 4'b0101;
   #20
   a = 4'b1100;
   b = 4'b1111;
   #20
   a = 4'b1100;
   b = 4'b0011;
   #20
   a = 4'b1100;
   b = 4'b1010;
   #20
   $finish;
end
```

## How to run a Simulation
once you have the test-bench file.

1. open ModelSim
2. create a project
3. select the files to add
4. compile the files
5. start the simulation: select the folder (usually `work`) and then the `tb` file
6. then select the signals to analyze 
7. run the simulation in order to see the signals

NOTE: signals can be grouped, showed in analog way like waveform, as buses, ...
