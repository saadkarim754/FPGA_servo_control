# FPGA Servo Control

This repository contains Verilog HDL, Python, and UCF files for controlling servo motors using an FPGA (Spartan-3E) with UART and button-based interfaces. It includes both single-axis and dual-axis servo control, with GUI tools for UART communication.

---

## Directory Structure

```
.
├── servo_v5.py
├── servo_v5.ucf
├── servo_v5.v
├── v1_control_with_button.v
├── v1.ucf
└── version2/
    ├── top.v
    ├── uart.py
    └── uuccff.ucf
```

---

## Project Overview

### 1. Single-Axis Servo Control (Button-based)
- **File:** `v1_control_with_button.v`
- **UCF:** `v1.ucf`
- **Description:**  
  - Controls a servo using two buttons (increase/decrease).
  - Provides LED feedback for direction.
  - Generates PWM for servo position.
  - Designed for Spartan-3E FPGA.

### 2. Dual-Axis Servo Control with UART
- **File:** `servo_v5.v`
- **UCF:** `servo_v5.ucf`
- **Description:**  
  - Controls two servo axes (X and Y) via UART.
  - Receives position data over UART, smooths transitions, and outputs PWM.
  - Pin mapping for X and Y axes is provided in the UCF.

### 3. Python GUI for UART Control
- **File:** `servo_v5.py`
- **Description:**  
  - Tkinter-based GUI to send position commands over UART.
  - Slider maps GUI values to UART byte range.
  - Requires `pyserial` and `tkinter`.

### 4. Version 2 (Refined Dual-Axis UART)
- **Folder:** `version2/`
  - **top.v:**  
    - Improved dual-axis servo controller with UART.
    - Alternates incoming UART bytes between X and Y.
    - Smooths servo movement.
  - **uart.py:**  
    - Updated Python GUI for UART control (uses COM3).
  - **uuccff.ucf:**  
    - Pin constraints for version 2.

---

## Usage

### FPGA
1. Synthesize the desired Verilog file (`v1_control_with_button.v`, `servo_v5.v`, or `version2/top.v`) using your FPGA toolchain.
2. Use the corresponding `.ucf` file for pin constraints.
3. Program the bitstream to your Spartan-3E FPGA board.

### Python GUI
1. Install dependencies:
   ```bash
   pip install pyserial
   ```
2. Run the GUI:
   ```bash
   python servo_v5.py
   # or for version2
   python version2/uart.py
   ```
3. Adjust the serial port (`COM2` or `COM3`) as needed for your system.

---

## File Descriptions

- **`.v` files:** Verilog HDL modules for servo control.
- **`.ucf` files:** Xilinx User Constraint Files for pin mapping.
- **`.py` files:** Python GUIs for sending UART commands to the FPGA.

---

## Notes

- The UART protocol expects alternating bytes for X and Y positions.
- The GUI maps slider values to the expected UART byte range.
- Make sure to match the serial port in the Python script to your hardware setup.

---

## License

MIT License (add your license if different).
## Authors
Laraib Fatima , Mian saad karim
