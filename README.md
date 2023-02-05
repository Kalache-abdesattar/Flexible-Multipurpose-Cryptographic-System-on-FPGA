# Flexible-Multipurpose-Cryptographic-System-on-FPGA
Design and Implementation of a multipurpose cryptographic accelerator in VHDL
For detailed information, read our [publication](https://ijeces.ferit.hr/index.php/ijeces/article/view/1445)

**The proposed design is a GALS architecture (Globally asynchronous locally synchronous) featuring :**
* a Tunable Keccak Core
* High Speed Fully Pipelined 128-bit AES Core operating in CTR mode
* ADC Controller

**The core system can perform:**
* Block Cipher Symmetric Encryption (128-bits)
* All SHA-3 Variants
* Pseudo-random Number Number Generator with tunable Security/performance ratio
* Post-processing Unit for True Random Number Generation
* Key Derivation Function

# Lorenz System Analogue Representation 
# Circuit Diagram 
![lorenz-diagram-multisim](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/lorenz_circuit.PNG)


# Circuit Implementation

**Components :**
* Differential Amplifier [LM358P](https://datasheet.octopart.com/LM358P-Texas-Instruments-datasheet-8220297.pdf)
* Analog Multiplier [AD633](https://www.analog.com/media/en/technical-documentation/data-sheets/ad633.pdf)
* Ceramic Capacitors (50nF)
* Resistors


![lorenz-implementation](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/lorenzCircuit.jpg)

# Circuit Behaviour 

### Theoretical Lorenz System Behaviour

#### Phase Space Visualization

![lorenz-attractor-phase-space](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/lorenz-theoretical.PNG)

#### Time Dependant Visualization

![lorenz-time](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/lorenz-time.png)

### Experimental Lorenz System Behaviour

#### Phase Space Visualization

[![IMAGE ALT TEXT HERE](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/oscillo.jpg)](https://youtu.be/wafvf3TThYw)

#### Time Dependant Visualization

[![IMAGE ALT TEXT HERE](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/Lorenz-system-time-dependant.jpg)](https://youtu.be/dwXIzn29e0U)
