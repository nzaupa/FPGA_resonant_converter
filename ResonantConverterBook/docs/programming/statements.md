# Statements and Blocks

## assign

`assign` is used for net type signals (e.g. `wire`)

> `assign <net_name> = [drive_strength] [delay] <expression or constant>`

an example can be
```verilog
assign ON = cnt_startup > 8'd10;   
assign STAT = data; 
```

Moreover, it can be explicit or implicit

```verilog
wire [1:0] a;
assign a = x & y;

or

wire [1:0] a = x & y;
```

## always

can write `{count,sum} = a + b + cin`

`always` can be used for both combinatorial and sequential logic.

combinatorial with `always` is the same as assign.

A `always` block is executed avery time a variable/net in the sensitivity list changes value. The general structure is

>`always @(<sensitivity list>)`

It is more interesting to see it applied to sequential logic. In this case, it is used to enforce an asynchronous behavior.

In the *sensitivity list* some attribute can be specified: `posedge` and `negedge`



## initial


