## Contribution Guidelines

### 1. General Guidelines

- The directory structure of the project must be preserved and should not be changed unless conveyed.
- All the design files which are big (like stages) or which instantiate other standalone modules should go into pak-rv-core/src directory.
- Standalone modules such as alu, register file, pc etc should go to the directory pak-rv-core/sub/src.
- All the verification files (.py) should go to the pak-rv-core/verif/pytests directory.
- Header files like .svh/.vh and packages should go to the include directory. If the header file/package is for big modules (like stages) should go to pak-rv-core/include and the head file/package associated with the standalone modules should go to pak-rv-core/sub/include.

### 2. Coding Guidelines for System Verilog

#### 2.1. File name matching with module
For system Verilog modules, the file name should match with the module name. This is not necessary but it can become a headache for the designer itself in searching and including them in the Makefiles or scripts while simulating.

#### 2.2. Indentation
This is one of the important steps. Please choose indentation using spaces and avoid using tabs. Default indentation for your favourite editor (vscode, emacs, vim, nano etc) can be set to 4 spaces. An example indentation can be seen in the listing below:

```
module my_silly_module # (
    parameter PARAM_1     = 15,
    parameter PARAM_NUM_2 = 16
) (
    input   logic                   clk,
    input   logic                   arst_n,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   valid_in,
    output  logic [DATA_WIDTH-1:0]  data_out,
    output  logic                   valid_out
);
```
This helps others to understand your code quite early and efficiently. 

#### 2.3. Importing Packages
To import packages in a module of System Verilog, please avoid using asterisk (*) notation. Instead specify the name of the function, structure, enum or task your want to import from the package. An example for both right and wrong way of importing packages is shown below:

```
// a bad example of importing packages

module my_silly_module
    import my_package::*;
#(
    parameter PARAM_1     = 15,
    parameter PARAM_NUM_2 = 16
) (
    input   logic                   clk,
    input   logic                   arst_n,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   valid_in,
    output  logic [DATA_WIDTH-1:0]  data_out,
    output  logic                   valid_out
);
```

```
// a good example of importing packages

module my_silly_module
    import my_package::add_op_f;
    import my_package::my_enum_t;
    import my_package::my_task_ts;
    import my_package::my_struct_s;
#(
    parameter PARAM_1     = 15,
    parameter PARAM_NUM_2 = 16
) (
    input   logic                   clk,
    input   logic                   arst_n,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   valid_in,
    output  my_struct_s             data_out,
    output  logic                   valid_out
);
```
#### 2.4. Module header
A header at the start of each module that tells what is the project name, module name, designer name and some description about the module. An examples is shown below:

```
///////////////////////////////////////////////////////////////////////////////////
// Project Name:  Pak-RV-Core
// Module Name:   my_silly_module
// Designer:      some designer
// Description:   Brief description of the module
//////////////////////////////////////////////////////////////////////////////////

module my_silly_module
    import my_package::add_op_f;
    import my_package::my_enum_t;
    import my_package::my_task_ts;
    import my_package::my_struct_s;
#(
    parameter PARAM_1     = 15,
    parameter PARAM_NUM_2 = 16


) (
    input   logic                   clk,
    input   logic                   arst_n,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   valid_in,
    output  my_struct_s             data_out,
    output  logic                   valid_out
);
```
#### 2.5. Generic things inside the module
There are some generic things which need to be cleared. One is we need to declare signals at some specific location inside the module. Similarly, some specific locations for always blocks, functions, parameters/local parameters, instantiations etc. An example code below can explains the fact:

```
///////////////////////////////////////////////////////////////////////////////////
// Project Name:  Pak-RV-Core
// Module Name:   my_silly_module
// Designer:      some designer
// Description:   Brief description of the module
//////////////////////////////////////////////////////////////////////////////////

module my_silly_module
    import my_package::add_op_f;
    import my_package::my_enum_t;
    import my_package::my_task_ts;
    import my_package::my_struct_s;
# (
    parameter PARAM_1     = 15,
    parameter PARAM_NUM_2 = 16
) (
    input   logic                   clk,
    input   logic                   arst_n,
    input   logic [DATA_WIDTH-1:0]  data_in,
    input   logic                   valid_in,
    output  my_struct_s             data_out,
    output  logic                   valid_out
);

    //////////////////////////////////////////////////////////////////////////////////
    // Parameters / Local Parameters
    //////////////////////////////////////////////////////////////////////////////////

    parameter  SOME_PARAMETER       = some_value;
    localparam SOME_LOCAL_PARAMETER = some_value;

    //////////////////////////////////////////////////////////////////////////////////
    // Enums / Structures / Functions
    //////////////////////////////////////////////////////////////////////////////////


    //////////////////////////////////////////////////////////////////////////////////
    // Always Blocks
    //////////////////////////////////////////////////////////////////////////////////


    //////////////////////////////////////////////////////////////////////////////////
    // Assignments
    //////////////////////////////////////////////////////////////////////////////////

     assign valid_out = some_driving_signal;

    //////////////////////////////////////////////////////////////////////////////////
    // Instantiations
    //////////////////////////////////////////////////////////////////////////////////

    some_silly_module #(
        .PARAM_1     ( value_for_PARAM_1     ),
        .PARAM_NUM_2 ( value_for_PARAM_NUM_2 )
    ) i_some_silly_module (
        .clk         ( clk                   ),
        .arst_n      ( arst_n                ),
        .data_in     ( data_in               ),
        .valid_in    ( valid_in              ),
        .data_out    ( data_out              ),
        .valid_out   ( valid_out             )
    );

endmodule: some_silly_module
```
Please note that some sections can come before/after some sections which depend purely on what and which type of design we are doing and we can change the locations accordingly. The purpose behind that is to increase the readability of the code.

### 3. Coding Guidelines for other languages
We have seen in the previous section that our main focus was the readability of the code. Following the same principle, we will write our codes in other languages as well. There are no special guidelines for other languages. All the things we learnt from Coding guidelines for System Verilog to deploy to other languages. Keeping the indentation, meaningful names to the variables, Upper case names for parameter / local parameters / defines / macros and naming different sections of the code can lead to a very beautiful code as well.