#!/usr/bin/python3
#
# abstract syntax tree (from latexindent) DEMONSTRATION only
#
import argparse, json, re, lxml.etree as ET

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

# https://stackoverflow.com/a/39234239/1091649
def recursive_items(dictionary, parent):
    try:
        cmh_element = ET.Element(dictionary["type"])
        cmh_element.attrib["name"] = dictionary["name"]
    except:
        pass

    if "arguments" in dictionary:
        for item in dictionary["arguments"]:
            yield from recursive_items(item,cmh_element)

    if "text" in dictionary:
       cmh_paragraph = ET.Element("paragraph")
       cmh_paragraph.text = dictionary["text"]
       parent.append(cmh_paragraph)
       return


    if "body" in dictionary:
       if type(dictionary["body"]) is list: 
           for item in dictionary["body"]:
               yield from recursive_items(item,cmh_element)
       else:
           cmh_paragraph = ET.Element("paragraph")
           try:
               cmh_paragraph.text = dictionary["body"]
           except:
               cmh_paragraph.text = " "
           try:
               cmh_element.append(cmh_paragraph)
           except:
               pass

    try:
       parent.append(cmh_element)
    except:
       pass

# 
# read AST file
#
f = open(args.filename)
mystring = str(f.read())
mystring = re.sub(r"(?<!\\)\\\$",r"\\\$",mystring)
myAST = json.loads(mystring)
#### print(json.dumps(myAST, indent=4))

# set up HTML file
cmh_html = ET.Element('html')
cmh_head = ET.Element('head')
cmh_html.append(cmh_head) 

# main body
cmh_body = ET.Element('body')

for dict_in_list in myAST:
    for key, value in recursive_items(dict_in_list, cmh_body):
        print(key, value)

# append <body> to <html>
print('--------pre-result-------------')
cmh_html.append(cmh_body) 
print(ET.tostring(cmh_html,pretty_print=True).decode())

#
# XSLT transform
#
cmh_xslt = ET.parse("ast-demo.xsl")
transform = ET.XSLT(cmh_xslt)
result = transform(cmh_html)
###print(result)
result.write_output("env1.html")

xml_tree = ET.parse("env1.html")
root = xml_tree.getroot()
root.find(".//cmhhead").tag="head"
ET.indent(xml_tree, '    ')
tree = ET.ElementTree(root)
tree.write("env1.html", pretty_print=True, xml_declaration=False, encoding="utf-8")

exit
