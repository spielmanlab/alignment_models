import sys
import os


def parse_output(parse_file):
    file_lines = parse_file.readlines()
    
    b_sp = file_lines[0]
    b_tc = file_lines[0]
    split_sp = b_sp.rsplit(" ")
    r_sp = split_sp[1]
    sp = r_sp.rstrip()
    
    split_tc = b_tc.rsplit(" ")  
    r_tc = split_tc[1]
    tc = r_tc.rstrip()   
    
       