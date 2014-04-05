'''
CS232 Project 6 extension
Due on Apr 5, 2014
@author: Ian Tibbetts and Ryan Newell
'''
import sys
import math
#found this implementation at 
#http://stackoverflow.com/questions/36932/how-can-i-represent-an-enum-in-python
def enum(*sequential, **named):
    enums = dict(zip(sequential, range(len(sequential))), **named)
    return type('Enum', (), enums)

class vhdlCompiler:
    def __init__(self):
        self.state = enum("START",
                          "LOOP",
                          "ERROR")
        
        self.keywords = ["ON","OFF","SHIFT_LEFT","SHIFT_RIGHT",
                         "ROTATE_LEFT","ROTATE_RIGHT","INVERT"]
        self.keywordDefinitions = ("keywords:\n" +
                                   "Do_# - begin a loop that iterates # times\n" +
                                   "Loop - end a loop\n" +
                                   "Set_######## - sets each of the 8 lights to their #, either 1 or 0.\n" +
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
        self.prevLR = ""
        self.loopInstrs = ""
    
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
            
        outputStr += self.getMachineInstructions("get the terminating instruction")
        return outputStr
          
    def getMachineInstructions(self,word):
        instructions = "-- " + word + "\n"
        if word.split("_")[0] == "DO":
            self.loopCount = int(word.split("_")[1])
            self.loopInstrs = ""
        elif word == "LOOP":
            oldLoopInstrs = self.loopInstrs
            newLoopInstrs = ""
            for _ in range(self.loopCount):
                for line in oldLoopInstrs.splitlines(True):
                    line = line.lstrip()
                    if line[0:2] == "--":
                        line = self.getMachineInstructions(line.rstrip('\n').split()[1])
                        newLoopInstrs = line
                instructions += newLoopInstrs
            self.loopInstrs = ""
        elif word == "ON":
            self.prevLR = "11111111"
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "OFF":
            self.prevLR = "00000000"
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "SHIFT_LEFT":
            self.prevLR = self.prevLR[1:7] + "0"
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "SHIFT_RIGHT":
            self.prevLR = "0" + self.prevLR[0:6]
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "ROTATE_LEFT":
            self.prevLR = self.prevLR[1:7] + self.prevLR[0]
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "ROTATE_RIGHT":
            self.prevLR = self.prevLR[0] + self.prevLR[0:6]
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word == "INVERT":
            invertedLR = ""
            for bit in self.prevLR:
                invertedLR += str(int(not(int(bit))))
            self.prevLR = invertedLR
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        elif word.split("_")[0] == "SET":
            self.prevLR = self.setBits
            instructions += self.getNewAddress() + " : " + self.prevLR + ";\n"
            self.loopInstrs += instructions
        else:
            instructions = ""
            twosExp = math.log2(self.address)
            if not int(twosExp) == twosExp:
                instructions += ("[" + str(self.address) + 
                                 ":" + str(int(math.pow(2,math.ceil(twosExp)))-1) + 
                                 "] : 11111111; --Fill remaining with all 1s\n")
            instructions += "END"
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
        
    def getNewAddress(self):
        newAddr = self.address
        self.address += 1
        return str(newAddr)
        
if __name__ == "__main__":
    print(sys.argv)
    print(len(sys.argv))
    compiler = vhdlCompiler()
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("usage: expect input file name as command line input.\n" +
              "Output file is an optional second parameter.\n" +
              "Input file should be program instruction written in" +
              " plain english using {}".format(compiler.keywordDefinitions))
    else:
        print("input file is " + sys.argv[1])
        sourceFile = open(sys.argv[1], encoding ="utf-8")
        sourceText = sourceFile.read()
        sourceFile.close()
        print("Input File Contents:\n" + sourceText)
        print(sourceText.split())
        
        parseResult = compiler.parseSource(sourceText)
        if compiler.errorMessage:#if there is an error string
            print(parseResult)
            print("Error(s) occurred:\n{}".format(compiler.errorMessage))
        else:
            print(parseResult)
            if len(sys.argv) == 2:
                listOutputPath = sys.argv[0].split("\\")[:-1]
                listOutputFile = listOutputPath + ["outputMIF.mif"]
                print("output file is " + 
                      "\\".join(listOutputFile))
                outputFile = open("\\".join(listOutputFile), mode="w", encoding ="utf-8")
            elif len(sys.argv) == 3:
                print("output file is " + sys.argv[2])
                outputFileName = sys.argv[2].split("\\")[-1].split(".")[0]
                outputFile = open(sys.argv[2], mode="w", encoding ="utf-8")
            else:
                print("usage: expect input file name as command line input.\n" +
                      "Output file is an optional second parameter.\n" +
                      "Input file should be program instruction written in" +
                      " plain english using {}".format(compiler.keywordDefinitions))
                      
            outputStr = "-- program memory file\n"
            outputStr += "DEPTH = " + str(compiler.address) + ";\n"
            outputStr += "WIDTH = 8;\n"
            outputStr += "ADDRESS_RADIX = DEC;\n"
            outputStr += "DATA_RADIX = BIN;\n"
            outputStr += "CONTENT\n"
            outputStr += "BEGIN\n"
            outputStr += parseResult
            outputFile.write(outputStr)
            outputFile.close()