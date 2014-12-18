If you installed the google drive application for mac, it will sync
all files to your local directory.
The google doc will be synced as XXX.gsheet/gdoc in your local machine.
However, those synced files are actually shortcuts to the web link

When read_table.pro finds out the input file is ".gsheet", it will
look for the public google doc link in the shortcut, download the
entire sheet as a csv file, and then read everything into an IDL
structure.
I have to say this a convoluted way to do it, but I found it was handy
if you also do plotting in IDL and your speadsheet is constantly
expanding.
2014-10-02