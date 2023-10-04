# Project Code

Chapter where the implementation of the various control il proposed.

```{important} Driver bootstrap
It is important to charge the bootstrap capacitors of the drivers in order to have the proper switching conditions. The risk is that the MOSFETs are not commuting if the capacitors are discharged.
```



```{caution} 
Take care that there is a real mess with the identification of the MOSFET in the bridge. A different numeration has been used in the: PCBs, schematics, and programming.

In the last version is

|FPGA code| PIN    |SCHEM FPGA| |PCB|LEG|SIDE|
|---------|--------|----------|-|---|---|----|
|Q[0] - Q1|PIN_AJ10|D24       | |Q3 |1 +|HIGH|
|Q[1] - Q2|PIN_AH8 |D26       | |Q1 |2 -|HIGH|
|Q[2] - Q3|PIN_AF13|D30       | |Q4 |1 +|LOW |
|Q[3] - Q4|PIN_AG12|D28       | |Q2 |2 -|LOW |

```



---

## Crush course on how to get an run the program

i.e.

1. `pull` from github *give the command to clone the repository*
2. identify the working folder
3. launch quartus (need to be installed <link>)
4. compile
5. launch the programmer
6. do modifications
7. `commit`
8. `push` to github




