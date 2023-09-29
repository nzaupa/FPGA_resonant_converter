# Verilog coding

Some useful page

[Verilog in a nutshell](https://www.chipverify.com/verilog/verilog-in-a-nutshell)


<https://www.chipverify.com/>

<https://nandland.com/learn-verilog/>



## Data types

### Variable values

|  |                    |
|--|--------------------|
|0 |logic zero / false  |
|1 |logic one / true    |
|x |unknown (0 or 1)    |
|z |high-impedance state |


### Nets and Variables

**Nets**: 

a net is created with the command `wire` (there should be other type...). It is use to connect *hardware* entities, therefore, it does not store any value. i.e. like a copper wire.

> `wire` can used with assign: `assign a = b & c`

**Variables**:

a variable is an abstraction of a data storage. It is declared using `reg`. It stores values and che hold them. A physical example is a flip-flop.

> - `reg`: values can be assigned with procedural blocks (`always`, `initial` : `<=`) but not with continuous (`assign`). Because `reg` is capable of storing and does not require to be driven continuously.


Initialize a variable
- at declaration: `reg [31:0] data = 32’hdead_cafe;`
- in initial begin: `data = 32’hdead_cafe;`
- can also initialize `wire`

Avoid to do it both, since is not sure which is executed first. Underscores '`_`' are not counted as bytes, their are
useful to separate long numbers.


**Others**:

- `integer` general purpose variable of 32-bit. Limit to positive value (?)
- `time` (? never used)
- `real` (not always supported, depends on the FPGA architecture)


### Access

A net or variable can have a different range. Default is one `wire a`, if a 4-bit is need `wire [3:0] a`

```verilog
wire a         // 1-bit
wire [3:0] a   // 4-bit
```

more advanced selection (never tested - not totally sure) `[<data_start> +: <width>]`
```verilog
data[8 +: 4]  <==>  data[11:4]
data[8 -: 4]  <==>  data[8:5]
```

the `width` need to be constant while the `data_start` could be a variable.

### Array

Can define array of variable
> `wire [3:0] y [0:1]` it's an array with 2 locations and 4-bit elements

```{warning}
take care of the order of the number in selection and definitions!
```

Can construct memory with 1-D array

---
## sth

> Could be interesting `assign-deassign` and `force-release`.


Structure for the loop `always`


---

## Operators

|       |      |     | | | |      |     | | | |       |                           |
|-------|------|-----|-|-|-|------|-----|-|-|-|-------|-------------------------- |
|`&&`   | `&`  | and | | | | `*`  | mul | | | | `===` | equal, including x and z  |
|`\|\|` | `\|` | or  | | | | `/`  | div | | | | `!==` | not equal, including x and z |
|`!`    | `~`  | not | | | | `%`  | mod | | | | `==`  | equal, can be unknown     |
|       | `^`  | xor | | | | `**` | pow | | | | `!=`  | not equal, can be unknown |

### Shift

- Logical shift `<<` `>>` add zeros
- Arithmetic shift `<<<` `>>>` keep the sign bit (not sure about <<<)

| | | |
|-|-|-|
| `data = 00101` | $\rightarrow$ | `data << 1 = 01010`  |
|                |               | `data << 2 = 10100`  |
|                |               | `data <<< 1 = 01011` |


**Conditional operator**: `assign out = condition ? true : false`

**Concatenation**: use the curly brackets `{ }` $\rightarrow$ `{a, b, c [1 : 0] , 2′b00, {2{a}}}`

**Replication**: `{y, y, y} = {3{y}}`, it can be nested.