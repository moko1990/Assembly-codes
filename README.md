# BCD Addition Program - Assembly x86 16-bit

This program is an assembly program for the 16-bit x86 processor that receives two 10-digit BCD numbers (received as two ASCII strings), converts them to BCD and adds them, then displays the result on the console.

## Features

- Receives two 10-digit ASCII strings from the user
- Converts two ASCII strings to BCD
- Apply the BCD addition algorithm
- Converts two BCD numbers to ASCII strings
- Display the result on the console
- Error handling for invalid inputs
- Full comments for learning

## How to compile and run

### Method 1: Manual compilation with MASM
```cmd
masm bcd_addition.asm;
link bcd_addition.obj;
bcd_addition.exe
```

### Method 2: Compile with EMU8086

## How to use

1. Run the program
2. Enter the first BCD number (10 digits)
3. Enter the second BCD number (10 digits)
4. The addition result is displayed on the screen

## Example

```
Enter first 10-digit BCD number: 1234567890
Enter second 10-digit BCD number: 9876543210
Result: 11111111100
```

## Technical description

### BCD addition algorithm
- Addition starts from the right (least significant digit)
- If the sum is greater than 9, 10 is subtracted from it and the carry digit is moved to the next digit
- This process is repeated for all 10 digits

### Structure Data
- `bcd1`: Store the first BCD digit
- `bcd2`: Store the second BCD digit
- `result`: Store the result (11 digits for portability)
- `temp_buffer`: Temporary buffer for input/output

### Main functions
- `GET_BCD_INPUT`: Get BCD input from the user
- `BCD_ADDITION`: Apply the BCD addition algorithm
- `DISPLAY_RESULT`: Display the result on the console

## Requirements

- MASM assembler
- DOS operating system or DOS emulator environment such as: DOSBox-X or emu8086
- 16-bit x86 processor

## Tutorial notes

This program is designed to teach the following concepts:
- Working with strings in assembly
- Computational algorithms
- Input/output management
- Working with memory and registers
- Assembly programming structure