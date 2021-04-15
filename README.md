# Time-Series modeling App
This app is intended to provide different instruments to professional who work with time series; it is composed by three main panels:

* **Data Cleaning**: contains different functions that help clean the dataset (remove outliers, fill gaps and normalize sampling frequency).
* **Model - Work in Progress**: help the user find the best model to fit the time-series.
* **Forecast - Work in Progress**: provide the users forecasts based on the selected model and allows the download of the model configuration.

A tutorial for the first panel is available [here](https://github.com/bigliolimatteo/Time_Series_modeling_app/blob/main/tutorial.md)

The app can be launched by installing the Shiny library on R typing in your console the following comands: 

`install.packages("shiny")`\
`library(shiny)` \
`runGitHub(repo = "bigliolimatteo/Time_Series_modeling_app", ref='main')`

Every needed library will be automatically installed and loaded in your system without any further notice (the list of the needed packages can be found in *sessionInfo.txt*).

## RCpp implementations
We developed two optimizations of the code using the RCpp libraries that can be found in the file ***data_engineering.R***.

At the end of the file you can find also the microbenchmark comparisons with the corresponding R functions. 

## File Descprition
***data_engineering.R***: 
Here you can find the functions that manipulate the dataset.

***app.R***: 
This is the core of the app containing the ui and server applications. 

***tutorial.md***: A brief tutorial that goes through the main functionalities of the app.

***default_datasets***:
This is a folder containing three default time-series datasets to help the user play with the app even if he/she doesn't have a custom dataset at hand.

***old_dependencies***:
This folder contains app dependencies that were removed by CRAN but are useful for the app itself; they are automatically installed.

***tutorial_images***:
This is a folder containing images used in the tutorial.

***www***:
This is a folder containing images used in the app.

***sessionInfo.txt***: information about loaded libraries and system specs.