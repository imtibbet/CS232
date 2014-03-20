'''
Created on Feb 7, 2014
top_half_on
top_half_off
bottom_half_on
bottom_half_off

rotate_right
rotate_left
bottom_half_rotate_right
bottom_half_rotate_left

shift_left
shift_right
bottom_half_shift_left
bottom_half_shift_right
@author: tibbi_000
'''
import sys
#found this implementation at 
#http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python
def enum(*sequential, **named):
    enums = dict(zip(sequential, range(len(sequential))), **named)
    return type('Enum', (), enums)

class myCompiler:
    def __init__(self):
        self.state = enum("START",
                          "LOOP",
                          "ERROR")
        
        self.keywords = ["ON","OFF","SHIFT_LEFT","SHIFT_RIGHT",
                         "ROTATE_LEFT","ROTATE_RIGHT","INVERT"]
        self.keywordDefinitions = ("keywords:\n" +
                                   "Do_# - begin a loop that iterates # times\n" +
                                   "Loop - end a loop\n" +
                                   "On - turn all 8 lights on\n" +
                                   "Off - turn all 8 lights off\n" +
                                   "Shift_Left - shift 8 lights left by one\n" +
                                   "Shift_Right - shift 8 lights right by one\n" +
                                   "Rotate_Left - rotate rightmost of 8 lights to the leftmost\n" +
                                   "Rotate_Right - rotate leftmost of 8 lights to the rightmost\n" +
                                   "Invert - flip all on lights to off and visa versa")
        self.setBits = ""
        self.errorMessage = ""
        self.startLoopAddr = 0
        self.address = 0
        self.addrLength = 8
        self.instrLength = 10
        self.loopCount = 0
    
    def parseSource(self,sourceText):
        outputStr = "data <= \n"
        curState = self.state.START
        for word in sourceText.split():
            word = word.upper()
            stateStr = self.getStateStr(curState)
            print("In state: {}".format(stateStr),end=" ")
            nextState = self.getNextState(word, curState)
            stateStr = self.getStateStr(nextState)
            print("read word: \"" + word +
                  "\" moved to state: {}".format(stateStr))
            if nextState == self.state.ERROR:
                return ""
            else:
                outputStr += self.getMachineInstructions(word)
            curState = nextState
            
        outputStr += self.getMachineInstructions("")
        return outputStr
          
    def getMachineInstructions(self,word):
        instrList = []
        instructions = "-- " + word + "\n"
        if word.split("_")[0] == "DO":
            instructions += self.storeLoopCount()
            self.startLoopAddr = self.address
        elif word == "LOOP":
            instructions += self.subOneFromLOOP()
            branchZWhenAddr = self.getNewAddress()
            branchUWhenAddr = self.getNewAddress()
            branchZToAddr = self.getNewAddress()
            instructions += ("\"11" + branchZToAddr + "\"" + 
                             " when addr = \"" + 
                             branchZWhenAddr +
                             "\" else -- " +
                             "break when LOOP is zero\n")
            instructions += ("\"00" + self.getStartLoopAddr() + "\""
                             " when addr = \"" + 
                             branchUWhenAddr +
                             "\" else -- " +
                             "branch unconditional to top of loop otherwise\n")
        elif word == "ON":
            instrList += ["\"0001110000\""]
        elif word == "OFF":
            instrList += ["\"0000110000\""]
            instrList += ["\"0110011000\""]
            instrList += ["\"0001000000\""]
        elif word == "SHIFT_LEFT":
            instrList += ["\"0000010000\""]
            instrList += ["\"0101000000\""]
            instrList += ["\"0001000000\""]
        elif word == "SHIFT_RIGHT":
            instrList += ["\"0000010000\""]
            instrList += ["\"0101100000\""]
            instrList += ["\"0001000000\""]
        elif word == "ROTATE_LEFT":
            instrList += ["\"0000010000\""]
            instrList += ["\"0111000000\""]
            instrList += ["\"0001000000\""]
        elif word == "ROTATE_RIGHT":
            instrList += ["\"0000010000\""]
            instrList += ["\"0111100000\""]
            instrList += ["\"0001000000\""]
        elif word == "INVERT":
            instrList += ["\"0000010000\""]
            instrList += ["\"0110011000\""]
            instrList += ["\"0001000000\""]
        elif word.split("_")[0] == "SET":
            instrList += ["\"001010" + self.setBits[4:8] + "\""]
            instrList += ["\"001110" + self.setBits[0:4] + "\""]
            instrList += ["\"0001000000\""]
        else:
            return ("\"1000000000\"; \n")
        for instr in instrList:
            newAddr = self.getNewAddress()
            instructions += (instr + 
                             " when addr = \"" + 
                             newAddr +
                              "\" else -- " +
                              word + "\n")
        return instructions
    
    def getNextState(self,word, curState):
        if curState == self.state.START:
            if word.split("_")[0] == "DO":
                if word.split("_")[-1].isdigit():
                    self.loopCount = int(word.split("_")[-1])
                    curState = self.state.LOOP
                else:
                    self.errorMessage += ("Error: DO_# - Do must have number after an _\n")
                    curState = self.state.ERROR
            elif word == "LOOP":
                self.errorMessage += ("Error: \"Loop\" without \"Do\"\n")
                curState = self.state.ERROR
            elif word.split("_")[0] == "SET":
                if word.split("_")[-1].isdigit():
                    bitCount = 0
                    for bit in word.split("_")[-1]:
                        if not(bit == "0" or bit == "1"):
                            self.errorMessage += ("Error: SET_######## - bit {} is invalid\n".format(bit))
                        bitCount += 1
                    if bitCount != 8:
                        self.errorMessage += ("Error: SET_######## - Do must 8 0's or 1's after an _\n")
                    self.setBits = word.split("_")[-1]
                    curState = self.state.START
                else:
                    self.errorMessage += ("Error: SET_######## - Do must 8 0's or 1's after an _\n")
                    curState = self.state.ERROR
            elif self.keywords.count(word):
                curState = self.state.START
            else:
                self.errorMessage += ("Error: word \"{}\" not recognized" + 
                                      " only use {}\n"
                                      ).format(word,
                                               self.keywordDefinitions)
                curState = self.state.ERROR
                
        elif curState == self.state.LOOP:
            if word.split("_")[0] == "DO":
                self.errorMessage = ("Error: \"Do\" inside loop.\n" +
                                     " do note support nested loops.\n")
                curState = self.state.ERROR
            elif word == "LOOP":
                curState = self.state.START
            elif word.split("_")[0] == "SET":
                if word.split("_")[-1].isdigit():
                    bitCount = 0
                    for bit in word.split("_")[-1]:
                        if not(bit == "0" or bit == "1"):
                            self.errorMessage += ("Error: SET_######## - bit {} is invalid\n".format(bit))
                        bitCount += 1
                    if bitCount != 8:
                        self.errorMessage += ("Error: SET_######## - Do must 8 0's or 1's after an _\n")
                    self.setBits = word.split("_")[-1]
                    curState = self.state.LOOP
                else:
                    self.errorMessage += ("Error: SET_######## - Do must 8 0's or 1's after an _\n")
                    curState = self.state.ERROR
            elif self.keywords.count(word):
                curState = self.state.LOOP
            else:
                self.errorMessage += ("Error: word \"{}\" not recognized" + 
                                      " only use {}\n"
                                      ).format(word,
                                              self.keywordDefinitions)
                curState = self.state.ERROR
        else: #state.ERROR
            curState = self.state.ERROR
            
        return curState
                
    def getStateStr(self,curState):
        if curState == self.state.START:
            return "START"
        elif curState == self.state.LOOP:
            return "LOOP"
        else: #ERROR
            return "ERROR"
   
    def storeLoopCount(self):
        tmpInstrList = ""
        powerOfTwoList = [64,32,16,8,4,2,1]
        if self.loopCount < 128:
            tmpInstrList += self.shiftLOOPLeft()
        else:
            self.errorMessage += ("Error: can't have loop greater than 127.\n")
        for powerOfTwo in powerOfTwoList:
            if self.loopCount < powerOfTwo:
                tmpInstrList += self.shiftLOOPLeft()
            else:
                tmpInstrList += self.shiftLOOPLeft()
                tmpInstrList += self.addOneToLOOP()
                self.loopCount -= powerOfTwo
        return tmpInstrList
        
    def shiftLOOPLeft(self):
        return ("\"0101000100\"" + 
                " when addr = \"" + 
                self.getNewAddress() +
                "\" else -- " +
                "shift left loop register\n")
        
    def addOneToLOOP(self):
        return ("\"0100010101\"" + 
                " when addr = \"" + 
                self.getNewAddress() +
                "\" else -- " +
                "increment loop register by 1\n")
            
    def subOneFromLOOP(self):
        return ("\"0100110101\"" + 
                " when addr = \"" + 
                self.getNewAddress() +
                "\" else -- " +
                "decrement loop register by 1\n")
        
    def getNewAddress(self):
        newAddr = "{0:b}".format(self.address)
        if len(newAddr) > self.addrLength:
            self.errorMessage += ("Error: new address exceeds give address length" +
                                  " of {}\n".format(self.addrLength))
        while len(newAddr) < self.addrLength:
            newAddr = "0" + newAddr
        self.address += 1
        return newAddr
    
    def getStartLoopAddr(self):
        startAddr = "{0:b}".format(self.startLoopAddr)
        if len(startAddr) > self.addrLength:
            self.errorMessage += ("Error: start address exceeds give address length" +
                                  " of {}\n".format(self.addrLength))
        while len(startAddr) < self.addrLength:
            startAddr = "0" + startAddr
        self.address += 1
        return startAddr
        
if __name__ == "__main__":
    print(sys.argv)
    print(len(sys.argv))
    myC = myCompiler()
    if len(sys.argv) < 2:
        print("usage: expect input file name as command line input.\n" +
              "Output file is an optional second parameter.\n" +
              "Input file should be program instruction written in" +
              " plain english using {}".format(myC.keywordDefinitions))
    else:
        print("input file is " + sys.argv[1])
        sourceFile = open(sys.argv[1], encoding ="utf-8")
        sourceText = sourceFile.read()
        sourceFile.close()
        print("Input File Contents:\n" + sourceText)
        print(sourceText.split())
        
        outputStr = "-- Ian Tibbetts and Ryan Newell\n"
        outputStr += "-- Project 5 Generated ROM\n"
        outputStr += "-- Due: Mar 21, 2014\n"
        outputStr += "library ieee;\n"
        outputStr += "use ieee.std_logic_1164.all;\n"
        outputStr += "use ieee.numeric_std.all;\n"
        outputStr += "\n"
        outputStr += "entity outputROM is\n"
        outputStr += "  port (\n"
        outputStr += "    addr : in std_logic_vector (7 downto 0);\n"
        outputStr += "    data : out std_logic_vector (9 downto 0));\n"
        outputStr += "end entity;\n"
        outputStr += "\n"
        outputStr += "architecture rtl of outputROM is\n"
        outputStr += "\n"
        outputStr += "begin\n"
        outputStr += "\n"
        outputStr += myC.parseSource(sourceText)
        outputStr += "\n"
        outputStr += "end rtl;\n"
        if myC.errorMessage:#if there is an error string
            print(outputStr)
            print("Error(s) occurred:\n{}".format(myC.errorMessage))
        else:
            print(outputStr)
            if len(sys.argv) == 2:
                listOutputPath = sys.argv[0].split("\\")[:-1]
                listOutputFile = listOutputPath + ["outputROM.vhd"]
                print("output file is " + 
                      "\\".join(listOutputFile))
                outputFile = open("\\".join(listOutputFile), mode="w", encoding ="utf-8")
            elif len(sys.argv) == 3:
                print("output file is " + sys.argv[2])
                outputFile = open(sys.argv[2], mode="w", encoding ="utf-8")
            else:
                print("usage: expect input file name as command line input.\n" +
                      "Output file is an optional second parameter.\n" +
                      "Input file should be program instruction written in" +
                      " plain english using {}").format(myC.keywordDefinitions)
            outputFile.write(outputStr)
            outputFile.close()