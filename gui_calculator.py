import tkinter as tk
import os
import re
import numpy as np
import matplotlib.pyplot as plt
from math import sin,cos,tan,atan,acos,asin
calculation=""

def factorial(num):
	i=1
	for j in range(1,num+1):
		i=j*i
	return i




def add_to_calculation(symbol):
	global calculation
	calculation += str(symbol)
	text_result.delete(1.0,"end")
	text_result.insert(1.0,calculation)

def graph():
	
	ex="(-?\d+(\.\d+)?)"
	#cal="sin(-3.14159,3.14159)"
	yacc_code=text_result.get(1.0,tk.END)
	patron=re.compile(ex)
	min,max=[float(i[0]) for i in patron.findall(yacc_code)]
	func=re.findall("[a-z]+",yacc_code)[0]
	#yacc_code=text_result.get(1.0,tk.END)

	with open("tt.txt","w") as file:
			file.write(yacc_code)
	cmd='./a.out <tt.txt'
	os.system(cmd)
	x=np.arange(min,max,0.1)
	y=np.array([eval("np."+func+"({})".format(str(i))) for i in x])
	plt.plot(x,y)
	plt.show()
	
	 

def evaluate_calculation():
	global calculation
	ex=r"(\d+)!"
	patron=re.compile(ex)

	if patron.match(calculation):
		val=int(patron.findall(calculation)[0])
		fac=factorial(val)
		#calculation=str(eval(calculation))
		
			
		yacc_code=text_result.get(1.0,tk.END)
		with open("tt.txt","w") as file:
			file.write(yacc_code)
		cmd='./a.out <tt.txt'
		text_result.delete(1.0,"end")
		text_result.insert(1.0,str(fac))
		os.system(cmd)
		
	else:
		
		
		calculation=str(eval(calculation))
		
			
		yacc_code=text_result.get(1.0,tk.END)
		with open("tt.txt","w") as file:
			file.write(yacc_code)
		cmd='./a.out <tt.txt'
		text_result.delete(1.0,"end")
		text_result.insert(1.0,calculation)
		os.system(cmd)
	
def clear_field():
	global calculation
	calculation=""
	text_result.delete(1.0,"end")

root=tk.Tk()
#root.geometry("370x275")
root.geometry("400x500")
root.configure(bg="#180C0C")

text_result=tk.Text(root,height=2,width=22,font=("Arial",24),bg='#262121',fg='white')
text_result.grid(columnspan=5,rowspan=2)

btn_1=tk.Button(root,text="1",command=lambda: add_to_calculation(1),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_1.grid(row=2,column=1,padx=2,pady=2)
btn_2=tk.Button(root,text="2",command=lambda: add_to_calculation(2),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_2.grid(row=2,column=2,padx=2,pady=2)
btn_3=tk.Button(root,text="3",command=lambda: add_to_calculation(3),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_3.grid(row=2,column=3,padx=2,pady=2)
btn_4=tk.Button(root,text="4",command=lambda: add_to_calculation(4),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_4.grid(row=3,column=1,padx=2,pady=2)
btn_5=tk.Button(root,text="5",command=lambda: add_to_calculation(5),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_5.grid(row=3,column=2,padx=2,pady=2)
btn_6=tk.Button(root,text="6",command=lambda: add_to_calculation(6),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_6.grid(row=3,column=3,padx=2,pady=2)
btn_7=tk.Button(root,text="7",command=lambda: add_to_calculation(7),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_7.grid(row=4,column=1,padx=2,pady=2)
btn_8=tk.Button(root,text="8",command=lambda: add_to_calculation(8),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_8.grid(row=4,column=2,padx=2,pady=2)
btn_9=tk.Button(root,text="9",command=lambda: add_to_calculation(9),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_9.grid(row=4,column=3,padx=2,pady=2)
btn_0=tk.Button(root,text="0",command=lambda: add_to_calculation(0),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_0.grid(row=5,column=2,padx=2,pady=2)
btn_sum=tk.Button(root,text="+",command=lambda: add_to_calculation("+"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_sum.grid(row=2,column=4,padx=2,pady=2)
btn_res=tk.Button(root,text="-",command=lambda: add_to_calculation("-"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_res.grid(row=3,column=4,padx=2,pady=2)
btn_mul=tk.Button(root,text="*",command=lambda: add_to_calculation("*"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_mul.grid(row=4,column=4,padx=2,pady=2)
btn_div=tk.Button(root,text="/",command=lambda: add_to_calculation("/"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_div.grid(row=5,column=4,padx=2,pady=2)
btn_open=tk.Button(root,text="(",command=lambda: add_to_calculation("("),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_open.grid(row=5,column=1,padx=2,pady=2)
btn_close=tk.Button(root,text=")",command=lambda: add_to_calculation(")"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_close.grid(row=5,column=3,padx=2,pady=2)

btn_close=tk.Button(root,text="sin",command=lambda: add_to_calculation("sin"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_close.grid(row=6,column=1,padx=2,pady=2)
btn_close=tk.Button(root,text="cos",command=lambda: add_to_calculation("cos"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_close.grid(row=6,column=2,padx=2,pady=2)
btn_close=tk.Button(root,text="tan",command=lambda: add_to_calculation("tan"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_close.grid(row=6,column=3,padx=2,pady=2)
btn_close=tk.Button(root,text=".",command=lambda: add_to_calculation("."),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_close.grid(row=6,column=4,padx=2,pady=2)

btn_imp=tk.Button(root,text="!",command=lambda: add_to_calculation("!"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_imp.grid(row=7,column=4,padx=2,pady=2)

btn_graph=tk.Button(root,text="graph",command=graph,width=5,font=("Arial",14),bg='#161414',fg='white')
btn_graph.grid(row=7,column=3,padx=2,pady=2)

btn_asin=tk.Button(root,text="asin",command=lambda: add_to_calculation("asin"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_asin.grid(row=7,column=1,padx=2,pady=2)

btn_acos=tk.Button(root,text="acos",command=lambda: add_to_calculation("acos"),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_acos.grid(row=7,column=2,padx=2,pady=2)

btn_coma=tk.Button(root,text=",",command=lambda: add_to_calculation(","),width=5,font=("Arial",14),bg='#161414',fg='white')
btn_coma.grid(row=8,column=4,padx=2,pady=2)

btn_clear=tk.Button(root,text="C",command=clear_field,width=11,font=("Arial",14),bg='#161414',fg='white')
btn_clear.grid(row=9,column=1,columnspan=2,padx=2,pady=2)
btn_equals=tk.Button(root,text="=",command=evaluate_calculation,width=11,font=("Arial",14),bg='#161414',fg='white')
btn_equals.grid(row=9,column=3,columnspan=2,padx=2,pady=2)
root.mainloop()
