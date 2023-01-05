# redpitaya_guide

To use `start_project.tcl`, first set a base path (folder where the downloaded git repository is).
If you want your base path (places where your project files will be saved), `cfg`, `cores`, etc must be placed there.
This is done in the default TCL console.
```verilog
set base_path C:/Users/ehussain/Desktop/Projects/qmi-redpitaya-starting
```

Also choose a project name:
```verilog
set project_name led_switch_interface
```

Run source and the project will appear in the specified base_path
```verilog
source $base_path/start_project.tcl
```

```verilog
cat /root/BitstreamName.bit > /dev/xdevcfg
```

