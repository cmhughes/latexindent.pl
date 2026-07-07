#!/usr/bin/python3
import argparse, json, re

# 
# argument parsing
#
parser = argparse.ArgumentParser(description='AST demonstration from latexindent')

parser.add_argument('--output', 
                    type=str, 
                    help='output file')

parser.add_argument('filename',
                    type=str,
                    help='filename')

args = parser.parse_args()

# 
# read AST file
#
f = open(args.filename)
mystring = str(f.read())
mystring = re.sub(r"(?<!\\)\\\$",r"\\\$",mystring)
myAST = json.loads(mystring)
print(json.dumps(myAST, indent=4))

for x in myAST:
    for y in x:
        print(type(x[y]))
exit
