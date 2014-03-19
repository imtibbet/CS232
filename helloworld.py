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
    
        self.keywordDefinitions = ("keywords:\n" +
                                   "Do_# - begin a loop that iterates # times\n" +
                                   "Loop - end a loop\n" +
                                   "On - turn all 8 lights on\n" +
                                   "Off - turn all 8 lights off\n")
        
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
        else:
            return ("\"0000000000\"; \n")
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
                    self.errorMessage = ("Error: DO_# - Do must have number with an _")
                    curState = self.state.ERROR
            elif word == "LOOP":
                self.errorMessage = ("Error: \"Loop\" without \"Do\"")
                curState = self.state.ERROR
            elif word == "ON":
                curState = self.state.START
            elif word == "OFF":
                curState = self.state.START
            else:
                self.errorMessage = ("Error: word \"{}\" not recognized" + 
                                     " only use {}"
                                      ).format(word,
                                               self.keywordDefinitions)
                curState = self.state.ERROR
                
        elif curState == self.state.LOOP:
            if word.split("_")[0] == "DO":
                self.errorMessage = ("Error: \"Do\" inside loop.\n" +
                                     " do note support nested loops.")
                curState = self.state.ERROR
            elif word == "ON":
                curState = self.state.LOOP
            elif word == "OFF":
                curState = self.state.LOOP
            elif word == "LOOP":
                curState = self.state.START
            else:
                self.errorMessage = ("Error: word \"{}\" not recognized" + 
                                     " only use {}"
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
            print("Error: can't have loop greater than 127.\n")
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
            print("Error: address exceeds give address length" +
                  " of {}".format(self.addrLength))
        while len(newAddr) < self.addrLength:
            newAddr = "0" + newAddr
        self.address += 1
        return newAddr
    
    def getStartLoopAddr(self):
        startAddr = "{0:b}".format(self.startLoopAddr)
        if len(startAddr) > self.addrLength:
            print("Error: address exceeds give address length" +
                  " of {}".format(self.addrLength))
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
        if not outputStr: #empty string
            print("Error occurred: {}".format(myC.errorMessage))
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