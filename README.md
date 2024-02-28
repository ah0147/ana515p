# ana515p
Alberta Hardiman
ANA 515P - Spring 2024

This file contains my script for the mental health survey in tech companies. Originally, there are 2 sheets that I then combined into 1 file (see mydata.csv). 

My main goal for this assignment is to clean and prepare the data for visualization. In particular, I was interested in the varying values in the gender column because the varying values is something I see a lot in my own line of work (when creating surveys with fill-in-the-blank answer options like race/ethnicity questions with other option). Initially I was using the case when function and mutate and listing out all the possible values to transform, e.g. “Cis Man” to “Male” and so on. However, given the amount of observations we have, it’s not really conducive to do this one by one and so I use the grepl function to detect patterns in the value. While it is useful and efficient, it could also be improved because if I were to categorize any transgender individuals to its own category, it also sorts “Trans-female” into the female value (which is not what I want). 

For the visualization itself, my assumption is that female and non-binary folks would have a higher chance of seeking treatments than their male counterpart–which seems to be true from seeing the plot. The data I subset for the plot is in the hardiman_plotdata.csv file. 

Other than that, I was interested in honing my skills in cleaning the timestamp, age, and number of employees column because this seems like a pretty common occurence when dealing with survey results (i.e. the values get reformatted incorrectly). 

One interesting thing that I still can’t figure out is why there are 5 digit values in the no_employees column when the highest specified amount seems to be “more than 1000”. Once removing these values, all the “other” values in the gender column also disappear. What could be causing this I wonder.. 
