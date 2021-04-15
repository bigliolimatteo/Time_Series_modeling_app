# Time-Series modeling App
This app is intended to provide the instruments to help professional in dealing with time series.

The App is reachable at **add link**

Alternatively this Shiny App can be launched by installing the Shiny library on R typing in your console the following comands: 

`install.packages("shiny")`\
`library(shiny)` \
`runGitHub(repo = "")`

Every needed library will be automatically installed and loaded in your system without any further notice (the list of the needed packages can be found in *sessionInfo.txt*).

## File Descprition
***data_engineering.R***: 
Here you can find the functions that manipulate the dataset.

***app.R***: 
This is the core of the app containing the ui and server applications. 

***tutorial.md***: A brief tutorial that goes through the main functionalities of the app.

***default_datasets***:
This is a folder containing three default time-series datasets to help the user play with the app even if he/she doesn't have a custom dataset at hand.

***tutorial_images***:
This is a folder containing images used in the tutorial.

***sessionInfo.txt***: information about loaded libraries and system specs.