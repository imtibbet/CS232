'''
CS232 Project 8
Due on Apr 21, 2014
@author: Ian Tibbetts and Ryan Newell
'''
import sys
import assembler

class AssemblyCompiler:
    def __init__(self, lexer):
        self.lexer = lexer
        self.nextFreeAddress = 0
        self.errorMessage = ""
        self.keywordDictionary = {"LOAD" : " D A    Load from address A (0..255) to register D\n",
                                   "LOADA" : " D A    Load from address [A + RE] to register D\n",
                                   "STORE" : " S A    Store the value in register S to address A (0..255)\n",
                                   "STOREA" : " S A    Store the value in register S to address [A + RE]\n",
                                   "BRA" : " L    Unconditional branch to label L\n",
                                   "BRAZ" : " L    Branch to label L if the CR zero flag is set\n",
                                   "BRAN" : " L    Branch to label L if the CR negative flag is set\n",
                                   "BRAO" : " L    Branch to label L if the CR overflow flag is set\n",
                                   "BRAC" : " L    Branch to label L if the CR carry flag is set\n",
                                   "CALL" : " L    Call the routine at label L\n",
                                   "RETURN" : "    return from a routine\n",
                                   "HALT" : "    execute the halt/exit instruction\n",
                                   "PUSH" : " S    Push register S onto the stack and increment SP\n",
                                   "POP" : " S    Decrement SP and put the top value on the stack into register S\n",
                                   "OPORT" : " S    Send register S to the output port\n",
                                   "IPORT" : " D    Assign to register D the value of the input port\n",
                                   "ADD" : " A B C    Execute C <= A + B, where A, B, C are registers\n",
                                   "SUB" : " A B C    Execute C <= A - B, where A, B, C are registers\n",
                                   "AND" : " A B C    Execute C <= A and B, bitwise, where A, B, C are registers\n",
                                   "OR" : " A B C    Execute C <= A or B, bitwise, where A, B, C are registers\n",
                                   "XOR" : " A B C    Execute C <= A xor B, bitwise, where A, B, C are registers\n",
                                   "SHIFTL" : " A C    Execute C <= A shifted left by 1, where A, C are registers\n",
                                   "SHIFTR" : " A C    Execute C <= A shifted right by 1, where A, C are registers\n", 
                                   "ROTL" : " A C    Execute C <= A rotated left by 1, where A, C are registers\n", 
                                   "ROTR" : " A C    Execute C <= A rotated right by 1, where A, C are registers\n", 
                                   "MOVE" : " A C    Execute C <= A where A and C are registers\n", 
                                   "MOVEI" : " A C    Execute C <= A where A is a value (-127..127) value and C is a register\n"}
        
    def pass1(self, tokens):
        self.labels = dict()
        self.nextFreeAddress = 0;
        newTokens = []
        for token in tokens:
            # if label
            if token[0][-1] == ":":
                self.labels.update({token[0][-1]:self.nextFreeAddress})
            else:
                token.insert(0,self.getNewAddress())
                newTokens += [token]
        return newTokens
    
    def pass2(self, newTokens):
        outputStr = "-- program memory file\n"
        outputStr += "DEPTH = 256;\n"
        outputStr += "WIDTH = 16;\n"
        outputStr += "ADDRESS_RADIX = DEC;\n"
        outputStr += "DATA_RADIX = BIN;\n"
        outputStr += "CONTENT\n"
        outputStr += "BEGIN\n"
        for token in newTokens:
            outputStr += self.getMachineInstructions(token)
            
        outputStr += self.getMachineInstructions(["[" + str(self.nextFreeAddress) + 
                                                  "..255]","HALT"])
        outputStr += "END"
        return outputStr
          
    def getMachineInstructions(self,token):
        instruction = ""
        operation = token[1]
        if operation == "LOAD":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "0000" + "0"
            destReg = self.getTableB(token[2])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[2] + " is an illegal value\n")
            srcAddress = self.lexer.dec2bin8(int(token[3]))
            if not srcAddress:
                self.errorMessage += ("at address " + token[0] + 
                                      " the source address " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += destReg + srcAddress
            instruction += ("; -- LOAD D A " +
                             "Load from address " + token[3] + 
                             " to register " + token[2] + "\n")
        elif operation == "LOADA":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "0000" + "1"
            destReg = self.getTableB(token[2])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[2] + " is an illegal value\n")
            srcAddress = self.lexer.dec2bin8(int(token[3]))
            if not srcAddress:
                self.errorMessage += ("at address " + token[0] + 
                                      " the source address " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += destReg + srcAddress
            instruction += ("; -- LOAD D A " +
                             "Load from address [" + token[3] + 
                             " + RE] to register " + token[2] + "\n")
        elif operation == "STORE":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "0001" + "0"
            srcReg = self.getTableB(token[2])
            if not srcReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the src reg " + token[2] + " is an illegal value\n")
            destAddress = self.lexer.dec2bin8(int(token[3]))
            if not destAddress:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcReg + destAddress
            instruction += ("; -- STORE S A " + 
                             "Store the value in register " + token[2] + 
                             " to address " + token[3] + "\n")
        elif operation == "STOREA":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "0001" + "1"
            srcReg = self.getTableB(token[2])
            if not srcReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the src reg " + token[2] + " is an illegal value\n")
            destAddress = self.lexer.dec2bin8(int(token[3]))
            if not destAddress:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcReg + destAddress
            instruction += ("; -- STOREA S A " + 
                             "Store the value in register " + token[2] + 
                             " to address [" + token[3] + " + RE]\n")
        elif operation == "BRA":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0010" + "0000"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- BRA L " + 
                             "Unconditional branch to address " + 
                             str(self.labels.get(token[2])) + "\n")
        elif operation == "BRAZ":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0011" + "00" + "00"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- BRAZ L " + 
                             "Branch to address " + str(self.labels.get(token[2])) + 
                             " if the CR zero flag is set\n")
        elif operation == "BRAN":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0011" + "00" + "10"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- BRAN L " +  
                             "Branch to address " + str(self.labels.get(token[2])) + 
                             " if the CR negative flag is set\n")
        elif operation == "BRAO":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0011" + "00" + "01"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- BRAO L " +  
                             "Branch to address " + str(self.labels.get(token[2])) + 
                             " if the CR overflow flag is set\n")
        elif operation == "BRAC":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0011" + "00" + "11"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- BRAC L " +  
                             "Branch to address " + str(self.labels.get(token[2])) + 
                             " if the CR carry flag is set\n")
        elif operation == "CALL":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0011" + "01" + "00"
            destAddress = self.labels.get(token[2])
            if destAddress == None:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest address " + token[2] + " is an illegal label\n")
                destAddress = "0"
            destAddress = self.lexer.dec2bin8(int(destAddress))
            instruction += token[0] + " : " + opCode
            instruction += destAddress
            instruction += ("; -- CALL L " + 
                             "Call the routine at address " + 
                             str(self.labels.get(token[2])) + "\n")
        elif operation == "RETURN":
            if len(token) != 2:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 0\n")
                token = [token[0],"ERROR"]
            opCode = "0011" + "10" + "00" + "00000000"
            instruction += token[0] + " : " + opCode
            instruction += ("; -- RETURN " + 
                             "return from a routine\n")
        elif operation == "HALT":
            if len(token) != 2:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 0\n")
                token = [token[0],"ERROR"]
            opCode = "0011" + "11" + "00" + "00000000"
            instruction += token[0] + " : " + opCode
            instruction += ("; -- HALT " + 
                             "execute the halt/exit instruction\n")
        elif operation == "PUSH":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0100"
            srcReg = self.getTableC(token[2])
            if not srcReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the src reg " + token[2] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcReg + "000000000"
            instruction += ("; -- PUSH S " + 
                             "Push register " + token[2] + " onto the stack and increment SP\n")
        elif operation == "POP":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0101"
            destReg = self.getTableC(token[2])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[2] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += destReg + "000000000"
            instruction += ("; -- POP S " + 
                             "Decrement SP and put the top value on the stack into register " +
                             token[2] + "\n")
        elif operation == "OPORT":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0110"
            srcReg = self.getTableD(token[2])
            if not srcReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the src reg " + token[2] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcReg + "000000000"
            instruction += ("; -- OPORT S " + 
                             "Send register " + token[2] + " to the output port\n")
        elif operation == "IPORT":
            if len(token) != 3:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 1\n")
                token = [token[0],"ERROR","ERROR"]
            opCode = "0111"
            destReg = self.getTableB(token[2])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[2] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += destReg + "000000000"
            instruction += ("; -- IPORT D " + 
                             "Assign to register " + token[2] + " the value of the input port\n")
        elif operation == "ADD":
            if len(token) != 5:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 3\n")
                token = [token[0],"ERROR","ERROR","ERROR","ERROR"]
            opCode = "1000"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            srcBReg = self.getTableE(token[3])
            if not srcBReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcB reg " + token[3] + " is an illegal value\n")
            destReg = self.getTableB(token[4])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[4] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + srcBReg + "000" + destReg
            instruction += ("; -- ADD A B C " + 
                             "Execute " + token[4] + " <= " + 
                             token[2] + " + " + token[3] + "\n")
        elif operation == "SUB":
            if len(token) != 5:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 3\n")
                token = [token[0],"ERROR","ERROR","ERROR","ERROR"]
            opCode = "1001"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            srcBReg = self.getTableE(token[3])
            if not srcBReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcB reg " + token[3] + " is an illegal value\n")
            destReg = self.getTableB(token[4])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[4] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + srcBReg + "000" + destReg
            instruction += ("; -- SUB A B C " + 
                             "Execute " + token[4] + " <= " + 
                             token[2] + " - " + token[3] + "\n")
        elif operation == "AND":
            if len(token) != 5:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 3\n")
                token = [token[0],"ERROR","ERROR","ERROR","ERROR"]
            opCode = "1010"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            srcBReg = self.getTableE(token[3])
            if not srcBReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcB reg " + token[3] + " is an illegal value\n")
            destReg = self.getTableB(token[4])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[4] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + srcBReg + "000" + destReg
            instruction += ("; -- AND A B C " + 
                             "Execute " + token[4] + " <= " + 
                             token[2] + " and " + token[3] + "\n")
        elif operation == "OR":
            if len(token) != 5:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 3\n")
                token = [token[0],"ERROR","ERROR","ERROR","ERROR"]
            opCode = "1011"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            srcBReg = self.getTableE(token[3])
            if not srcBReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcB reg " + token[3] + " is an illegal value\n")
            destReg = self.getTableB(token[4])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[4] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + srcBReg + "000" + destReg
            instruction += ("; -- OR A B C " + 
                             "Execute " + token[4] + " <= " + 
                             token[2] + " or " + token[3] + "\n")
        elif operation == "XOR":
            if len(token) != 5:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 3\n")
                token = [token[0],"ERROR","ERROR","ERROR","ERROR"]
            opCode = "1100"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            srcBReg = self.getTableE(token[3])
            if not srcBReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcB reg " + token[3] + " is an illegal value\n")
            destReg = self.getTableB(token[4])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[4] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + srcBReg + "000" + destReg
            instruction += ("; -- XOR A B C " + 
                             "Execute " + token[4] + " <= " + 
                             token[2] + " xor " + token[3] + "\n")
        elif operation == "SHIFTL":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "1101" +"0"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + "00000" + destReg
            instruction += ("; -- SHIFTL A C " + 
                             "Execute " + token[3] + " <= " + 
                             token[2] + ", shifted left by 1\n")
        elif operation == "SHIFTR":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "1101" +"1"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + "00000" + destReg
            instruction += ("; -- SHIFTR A C " + 
                             "Execute " + token[3] + " <= " + 
                             token[2] + ", shifted right by 1\n")
        elif operation == "ROTL":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "1110" +"0"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + "00000" + destReg
            instruction += ("; -- ROTL A C " + 
                             "Execute " + token[3] + " <= " + 
                             token[2] + ", rotated left by 1\n")
        elif operation == "ROTR":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "1110" +"1"
            srcAReg = self.getTableE(token[2])
            if not srcAReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the srcA reg " + token[2] + " is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += token[0] + " : " + opCode
            instruction += srcAReg + "00000" + destReg
            instruction += ("; -- ROTR A C " + 
                             "Execute " + token[3] + " <= " + 
                             token[2] + ", rotated right by 1\n")
        elif operation == "MOVE":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "11110"
            instruction += token[0] + " : " + opCode
            srcReg = self.getTableD(token[2])
            if not srcReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the src reg " + token[2] + " is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += srcReg + "00000" + destReg
            instruction += ("; -- MOVE A C " + 
                             "Execute " + token[3] + " <= " + 
                             token[2] + "\n")
        elif operation == "MOVEI":
            if len(token) != 4:
                self.errorMessage += ("at address " + token[0] + 
                                      " incorrect number of parameters, expected 2\n")
                token = [token[0],"ERROR","ERROR","ERROR"]
            opCode = "11111"
            instruction += token[0] + " : " + opCode
            immediate = self.lexer.dec2comp8(int(token[2]))
            if not immediate:
                self.errorMessage += ("at address " + token[0] + 
                                      " the immediate " + immediate + " given is an illegal value\n")
            destReg = self.getTableB(token[3])
            if not destReg:
                self.errorMessage += ("at address " + token[0] + 
                                      " the dest reg " + token[3] + " is an illegal value\n")
            instruction += immediate + destReg
            instruction += ("; -- MOVEI A C " +
                             "Execute " + token[3] + " <= " + 
                             token[2] + "\n")
        else:
            self.errorMessage += "The opcode " + operation + " is not part of our assembly language!\n"
        return instruction
    
    def getTableB(self, regName):
        if regName == "RA":
            regBits = "000"
        elif regName == "RB":
            regBits = "001"
        elif regName == "RC":
            regBits = "010"
        elif regName == "RD":
            regBits = "011"
        elif regName == "RE":
            regBits = "100"
        elif regName == "SP":
            regBits = "101"
        else:
            regBits = ""
        return regBits
  
    def getTableC(self, regName):
        if regName == "RA":
            regBits = "000"
        elif regName == "RB":
            regBits = "001"
        elif regName == "RC":
            regBits = "010"
        elif regName == "RD":
            regBits = "011"
        elif regName == "RE":
            regBits = "100"
        elif regName == "SP":
            regBits = "101"
        elif regName == "PC":
            regBits = "110"
        elif regName == "CR":
            regBits = "111"
        else:
            regBits = ""
        return regBits
      
    def getTableD(self, regName):
        if regName == "RA":
            regBits = "000"
        elif regName == "RB":
            regBits = "001"
        elif regName == "RC":
            regBits = "010"
        elif regName == "RD":
            regBits = "011"
        elif regName == "RE":
            regBits = "100"
        elif regName == "SP":
            regBits = "101"
        elif regName == "PC":
            regBits = "110"
        elif regName == "IR":
            regBits = "111"
        else:
            regBits = ""
        return regBits
    
    def getTableE(self, regName):
        if regName == "RA":
            regBits = "000"
        elif regName == "RB":
            regBits = "001"
        elif regName == "RC":
            regBits = "010"
        elif regName == "RD":
            regBits = "011"
        elif regName == "RE":
            regBits = "100"
        elif regName == "SP":
            regBits = "101"
        elif regName == "ZEROS":
            regBits = "110"
        elif regName == "ONES":
            regBits = "111"
        else:
            regBits = ""
        return regBits
    
    def getNewAddress(self):
        newAddr = self.nextFreeAddress
        self.nextFreeAddress += 1
        return str(newAddr)
    
    def getKeywordDefinitions(self):
        resultStr = ""
        for operation, definition in self.keywordDictionary.items():
            resultStr += operation + definition
        return resultStr
    
    def getKeywordDefinition(self, operation):
        definition = self.keywordDictionary.get(operation)
        if not definition:
            return operation + " Not a legal operation in our assembly language!"
        else:
            return operation + definition
        
if __name__ == "__main__":
    lexer = assembler.Assembler()
    compiler = AssemblyCompiler(lexer)
    usageStr = ("usage: expect input file name as first command line input.\n" +
                      "Output file is an optional second parameter.\n" +
                      "OR\n" +
                      "help as first command line input.\n" +
                      "specific command to get help for is an optional second parameter.\n")
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print(usageStr)
        exit();
        
    if sys.argv[1] == "help" and len(sys.argv) == 2:
        print("help: assembly operations are:\n{}".format(compiler.getKeywordDefinitions()))
        exit();
    
    if sys.argv[1].lower() == "help" and len(sys.argv) == 3:
        print("help: assembly operation is:\n{}".format(compiler.getKeywordDefinition(sys.argv[2].upper())))
        exit();
        
    print("input file is " + sys.argv[1])
    try:
        sourceFile = open(sys.argv[1], encoding ="utf-8")
    except:
        print("failed to open first parameter input as source file.\n" + 
              "verify that " + sys.argv[1] + " is a fully qualified path and text filename that exists.")
        exit()
    '''
    tokens is a list of tokens, each token is a list of strings
    the token strings are either just a label,
    or an assembly language operation and subsequent parameters
    '''
    tokens = lexer.tokenize( sourceFile )
    sourceFile.close()
    '''
    labels is a dictionary of label names to memory address
    pass1 stores labels as a field of lexer and updates
    tokens to include the memory address of each token
    '''
    tokens = compiler.pass1(tokens)
    '''
    pass 2 generates the mif code from the tokens and labels
    '''
    parseResult = compiler.pass2(tokens)
    print(parseResult)
    
    if compiler.errorMessage:#if there is an error string
        print("use only legal assembly operations:\n{}".format(compiler.getKeywordDefinitions()))
        print("Error(s) occurred:\n{}".format(compiler.errorMessage))
    else:
        if len(sys.argv) == 2:
            listOutputPath = sys.argv[0].split("\\")[:-1]
            listOutputFile = listOutputPath + ["outputMIF.mif"]
            print("output file is " + 
                  "\\".join(listOutputFile))
            outputFile = open("\\".join(listOutputFile), mode="w", encoding ="utf-8")
        elif len(sys.argv) == 3:
            print("output file is " + sys.argv[2])
            outputFileName = sys.argv[2].split("\\")[-1].split(".")[0]
            try:
                outputFile = open(sys.argv[2], mode="w", encoding ="utf-8")
            except:
                print("failed to open second parameter input as destination file.\n" + 
                      "verify that " + sys.argv[2] + " is a fully qualified path and filename that exists.")
                exit()
        else:
            print(usageStr)
            exit();
            
        outputFile.write(parseResult)
        outputFile.close()
