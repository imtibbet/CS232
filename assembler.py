# implements a simple assembler for the following assembly language
# 
# - One instruction or label per line.
#
# - Blank lines are ignored.
#
# - Comments start with a # as the first character and all subsequent
# - characters on the line are ignored.
#
# - Spaces delimit instruction elements.
#
# - A label ends with a colon and must be a single symbol on its own line.
#
# - A label can be any single continuous sequence of printable
# - characters; a colon or space terminates the symbol.
#
# - All immediate and address values are given in decimal.
#
# - Address values must be positive
#
# - Negative immediate values must have a preceeding '-' with no space
# - between it and the number.
#

# Language definition:
#
# LOAD D A   - load from address A to destination D
# LOADA D A  - load using the address register from address A + RE to destination D
# STORE S A  - store value in S to address A
# STOREA S A - store using the address register the value in S to address A + RE
# BRA L      - branch to label A
# BRAZ L     - branch to label A if the CR zero flag is set
# BRAN L     - branch to label L if the CR negative flag is set
# BRAO L     - branch to label L if the CR overflow flag is set
# BRAC L     - branch to label L if the CR carry flag is set
# CALL L     - call the routine at label L
# RETURN     - return from a routine
# HALT       - execute the halt/exit instruction
# PUSH S     - push source value S to the stack
# POP D      - pop form the stack and put in destination D
# OPORT S    - output to the global port from source S
# IPORT D    - input from the global port to destination D
# ADD A B C  - execute C <= A + B
# SUB A B C  - execute C <= A - B
# AND A B C  - execute C <= A and B  bitwise
# OR  A B C  - execute C <= A or B   bitwise
# XOR A B C  - execute C <= A xor B  bitwise
# SHIFTL A C - execute C <= A shift left by 1
# SHIFTR A C - execute C <= A shift right by 1
# ROTL A C   - execute C <= A rotate left by 1
# ROTR A C   - execute C <= A rotate right by 1
# MOVE A C   - execute C <= A where A is a source register
# MOVEI V C  - execute C <= value V
#

# 2-pass assembler
# pass 1: read through the instructions and put numbers on each instruction location
#         calculate the label values
#
# pass 2: read through the instructions and build the machine instructions
#

import sys

class Assembler:

    #def __init__(self):
        
            
    # converts d to an 8-bit 2-s complement binary value
    def dec2comp8( self, d ):
        try:
            if d > 0:
                l = d.bit_length()
                v = "00000000"
                v = v[0:8-l] + format( d, 'b')
            elif d < 0:
                dt = 128 + d
                l = dt.bit_length()
                v = "10000000"
                v = v[0:8-l] + format( dt, 'b')[:]
            else:
                v = "00000000"
        except:
            v = ""
    
        return v
    
    # converts d to an 8-bit unsigned binary value
    def dec2bin8( self, d ):
        if d > 0:
            l = d.bit_length()
            v = "00000000"
            v = v[0:8-l] + format( d, 'b' )
        elif d == 0:
            v = "00000000"
        else:
            v = ""
    
        return v
    
    
    # Tokenizes the input data, discarding white space and comments
    # returns the tokens as a list of lists, one list for each line.
    #
    # The tokenizer also converts each character to upper case.
    def tokenize( self, fp ):
        tokens = []
    
        # start of the file
        fp.seek(0)
    
        lines = fp.readlines()
    
        # strip white space and comments from each line
        for line in lines:
            ls = line.strip()
            uls = ''
            for c in ls:
                if c != '#':
                    uls = uls + c
                else:
                    break
    
            # skip blank lines
            if len(uls) == 0:
                continue
    
            # split on white space
            words = uls.split()
    
            newwords = []
            for word in words:
                newwords.append( word.upper() )
    
            tokens.append( newwords )
    
        return tokens
    
