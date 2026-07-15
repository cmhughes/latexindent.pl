#!/usr/bin/python3
#
# abstract syntax tree (from latexindent) DEMONSTRATION only
#
import argparse, json, re, xml.etree.ElementTree as ET

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
           cmh_paragraph.text = dictionary["body"]
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
cmh_meta = ET.Element('meta')
cmh_meta.attrib["charset"] = "UTF-8"
cmh_head.append(cmh_meta) 
cmh_meta = ET.Element('meta')
cmh_meta.attrib["author"] = "cmhughes"
cmh_head.append(cmh_meta) 
cmh_title = ET.Element('title')
cmh_title.text="ast demo title" 
cmh_head.append(cmh_title) 

cmh_html.append(cmh_head) 
cmh_script = ET.Element('script')
cmh_script.text=""" 
  MathJax = {
    tex: {
      inlineMath: [['$', '$'], ['\\(', '\\)']]
    },
    options: {
      enableMenu: true,          // set to false to disable the menu
      menuOptions: {
        settings: {
          texHints: true,        // put TeX-related attributes on MathML
          semantics: false,      // put original format in semantic tag in MathML
          zoom: 'Click',         // or 'Click' or 'DoubleClick' as zoom trigger
          zscale: '200%',        // zoom scaling factor
          renderer: 'CHTML',     // or 'SVG'
          alt: false,            // true if ALT required for zooming
          cmd: false,            // true if CMD required for zooming
          ctrl: false,           // true if CTRL required for zooming
          shift: false,          // true if SHIFT required for zooming
          scale: 1,              // scaling factor for all math
          inTabOrder: true,      // true if tabbing includes math
          assistiveMml: true,    // true if hidden assistive MathML should be generated for screen readers
          collapsible: false,    // true if complex math should be collapsible
          explorer: true,       // true if the expression explorer should be active
        },
        annotationTypes: {
          TeX: ['TeX', 'LaTeX', 'application/x-tex'],
          StarMath: ['StarMath 5.0'],
          Maple: ['Maple'],
          ContentMathML: ['MathML-Content', 'application/mathml-content+xml'],
          OpenMath: ['OpenMath']
        }
      }
    }
  };"""
cmh_head.append(cmh_script) 
cmh_script = ET.Element('script')
cmh_script.attrib["type"] = "text/javascript" 
cmh_script.attrib["id"] = "MathJax-script" 
cmh_script.attrib["src"]= "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"
cmh_script.text = " "
cmh_head.append(cmh_script) 

# main body
cmh_body = ET.Element('body')

for dict_in_list in myAST:
    for key, value in recursive_items(dict_in_list, cmh_body):
        print(key, value)

# documentclass
cmh_doc_class = cmh_body.find("commands[@name='documentclass']")
cmh_body.attrib["class"]= cmh_doc_class.find("mandatoryArgument").find("paragraph").text
cmh_body.remove(cmh_doc_class) 

# paragraph space treatment
cmh_every_paragraph = cmh_body.findall(".//*paragraph")
for indv_para in cmh_every_paragraph: 
    indv_para.text = re.sub(r"^\s*","",indv_para.text)
    indv_para.text = re.sub(r"\s+"," ",indv_para.text)

# environments
cmh_every_one = cmh_body.findall(".//environments[@name='one']")
for indv_env_one in cmh_every_one: 
    # <h1>
    cmh_heading = ET.Element('h1')
    opt_arg = indv_env_one.find("optionalArgument")
    for indv_element in opt_arg:
        cmh_heading.append(indv_element)
    indv_env_one.remove(opt_arg)
    indv_env_one.insert(0,cmh_heading)
    mand_arg = indv_env_one.find("mandatoryArgument")
    indv_env_one.remove(mand_arg)
    indv_env_one.tag = "div"
    indv_env_one.attrib["class"]="env-one"

cmh_every_two = cmh_body.findall(".//environments[@name='two']")
for indv_env_two in cmh_every_two: 
    indv_env_two.tag = "div"
    indv_env_two.attrib["class"]="env-two"

cmh_every_three = cmh_body.findall(".//environments[@name='three']")
for indv_env_three in cmh_every_three: 
    indv_env_three.tag = "div"
    indv_env_three.attrib["class"]="env-three"

# append <body> to <html>
cmh_html.append(cmh_body) 
ET.indent(cmh_html, space="  ", level=0)

# output to HTML file
tree = ET.ElementTree(cmh_html)
tree.write(args.output, encoding="utf-8")
exit
