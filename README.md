# abssa
Auto Backup Script for System Administrator

By Suyash Jain - www.coolgator.in                                                                



The script is written to take the backup of :-                                                   

 1) modified files in directories since last check.                                              
 
 2) modified individual files since last check                                                   
 



 The script relies on linux find command and its -newer and -path switch                         
 
 The script uses a list of included directories or files as well a separate list of excluded     
   and pass to -path switch     
   
 > create a file for include list and mention each path/file in a separate line
 
 > create a optional file for exclude list and mention each path/file in a separate line

 The script is capable of taking directories path and individual file in include and exclude list
 
 The script uses a timestamp file to compare the included files                                  

> I will be highly thankful for the contribution and improvements
