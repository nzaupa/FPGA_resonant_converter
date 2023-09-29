# Verilog coding

## Coding
Type of signal:
- `wire` can used with assign: `assign a = b & c`
- `reg`: values can be assigned with procedural blocks (`always`, `initial` : `<=`) but not with continuous (`assign`). Because `reg` is capable of storing and does not require to be driven continuously.

Initialize a variable
- at declaration: `reg [31:0] data = 32’hdead_cafe;`
- in initial begin: `data = 32’hdead_cafe;`
- can also initialize `wire`

Avoid to do it both, since is not sure which is executed first. Underscores '`_`' are not counted as bytes, their are
useful to separate long numbers.

> Could be interesting `assign-deassign` and `force-release`.


Structure for the loop `always`



### Operators

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