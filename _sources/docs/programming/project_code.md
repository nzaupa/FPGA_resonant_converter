# Project Code

Chapter where the implementation of the various control il proposed.

```{important} Driver bootstrap
It is important to charge the bootstrap capacitors of the drivers in order to have the proper switching conditions. The risk is that the MOSFETs are not commuting if the capacitors are discharged.
```



```{error} 
Take care that there is a real mess with the identification of the MOSFET in the bridge. A different numeration has been used in the: PCBs, schematics, and programming.

In the last version is

| FPGA    | PIN    |SCHEM| |PCB|LEG|SIDE|
|---------|--------|-----|-|---|---|----|
|Q[0] - Q1|PIN_AJ10|D24  | |Q3 |1 +|HIGH|
|Q[1] - Q2|PIN_AH8 |D26  | |Q1 |2 -|HIGH|
|Q[2] - Q3|PIN_AF13|D30  | |Q4 |1 +|LOW |
|Q[3] - Q4|PIN_AG12|D28  | |Q2 |2 -|LOW |

```
