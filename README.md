# Housing_Permits_And_Population_Growth

The purpose of this project was to determine the effect of Housing Permits on Population Growth throughout United States counties from 2010-2022. Five methods were used:

A. Linear Regression (Using standard OLS with statsmodels, as well as a scikit-learn model)
B. Gradient Boosting and SHAP (Using XGBoost and Optuna)
C. Causal Inference (Using Propensity Score Matching)
D. Forecasting (Using XGBoost for one model, and ARIMA for another)
E. Neural Network (Using PyTorch, one linear model with no hidden layers, one model with one hidden layer, and one model with two hidden layers)

After making the models, I wrote five reports, one on each method. A significant part of each report is on explaining the data, the choices I made with respect to gathering it, filtering it, cleaning it, and handling outliers. Since the methods of data handling were generally the same for each method, most of the first third of each report is identical.

In the GitHub repo, there are the main data files in excel, report pdfs, SQL files, Python files, and the tableau workbook.
