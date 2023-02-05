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

![lorenz-implementation](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/lorenzCircuit.jpg)

# Circuit Behaviour 

## Theoretical Lorenz System Behaviour

### Phase Space Visualization

![lorenz-attractor-phase-space](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/lorenz-theoretical.PNG)

### Time Dependant Visualization

![lorenz-time](https://github.com/Kalache-abdesattar/Flexible-Multipurpose-Cryptographic-System-on-FPGA/blob/main/Analog%20Lorenz%20System/lorenz-time.png)
