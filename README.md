# typea

Quickly analysis a command info. `typea` naming inspired by command `type -a`.  

How to use:  

[1]  source it first, or normally put its code in ~/.bash_aliases  

xb@dnxb:~/note/sh/typea$ chmod +x typea.sh; . typea.sh  

[2] Run as `typea <command>`, enjoy :)  

Screenshots:  

[1] Quick check file type (so now I know it's an ascii python file, not an EXE, and I will edit it):   
![Check file type](/1510210160_2017-11-09_PPabjenvK6.png?raw=true "Check file type")  

[2] Quick travel *ALL* symlink path (Please ensure you has installed namei command which located in package util-linux):   
![Check travel symlink path](/1510210226_2017-11-09_mi9R2urpJw.png?raw=true "Quick travel symlink path")  

[3] Quick check function body:  
![Check function body](/1510210328_2017-11-09_TKX67tj8jz.png?raw=true "Check function body")  


See ? I don't require any prior knowledge to any commands of pip3/cc/typea above, I just need to type `typea <command>` and boom, that's all. 

Of course, you need knowledge like `dpkg -S $(which namei)` if you want to further research, but this typea is enough as a quick look, without required you type `type -a <command>`, `file <alias path>`, `realpath <alias path>`, `file <realpath of alias path>`, `ls -la <realpath of alias path>`, highlight the function body, `whereis <command>` ... etc, there's only one command :)

