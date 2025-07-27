# Wine-Quality-Prediction 🍷
This project focuses on predicting the quality of white wine based on its physicochemical properties using various supervised machine learning models implemented in R. Human evaluation of wine is often subjective, costly, and time-consuming. By leveraging data-driven approaches, this project aims to build a reliable and scalable solution to classify wines as Good or Not Good, supporting consistent quality assessment in the wine industry.

## Dataset
The dataset used in this project comprises 4,898 observations of white wine samples, each characterized by 11 input features representing their physicochemical properties. These features include fixed acidity, volatile acidity, citric acid, residual sugar, chlorides, free sulfur dioxide, total sulfur dioxide, density, pH, sulphates, and alcohol content. The target variable is the wine’s quality, scored on a scale from 0 to 10, based on sensory evaluations provided by wine experts.

## Overview
To streamline the modeling task, the original quality scores (ranging from 0 to 10) were converted into a binary target variable. Wines with a quality score of 7 or above were labeled as "Good", while those below 7 were labeled as "Not Good". This binary classification approach simplified the prediction task and addressed the sparsity of extreme ratings.
Model development was carried out using R, and the dataset was split into 60% training and 40% validation sets. Multiple supervised learning models were implemented and evaluated based on accuracy, sensitivity, specificity, and ROC AUC scores.

### EDA
- Quality vs. Features: Wine quality is moderately correlated with alcohol content.
- Trends in High-Quality Wines: Typically have lower volatile acidity, chlorides, and density, and higher alcohol.
- Feature Correlations: Strong correlations exist between free & total sulfur dioxide, and between residual sugar & density.

### Models 
- Logistic Regression: Achieved 78.78% accuracy initially; improved to 80.46% after removing correlated and insignificant variables. High sensitivity (95.8%) but poor specificity (25.6%), making it less effective at identifying high-quality wines.
- Decision Tree: Reached 81.33% accuracy using all features. Provided a clear, interpretable structure with sensitivity at 93.5% and specificity at 35.6%, showing modest improvement in class balance.
- Random Forest (Best Performer): Delivered 87.96% accuracy with strong sensitivity (96.06%) and better specificity (59.76%). ROC AUC of 0.917, with top predictors including alcohol, volatile acidity, pH, and chlorides.
- Neural Network: Achieved 77.69% accuracy on normalized, reduced data. Showed high sensitivity (94.22%) but low specificity (31.4%), and an ROC AUC of 0.775, indicating imbalance in predicting high-quality wines.

## Conclusion
The evaluation of logistic regression, random forest, and neural network models for white wine quality prediction highlighted key variables such as alcohol, density, pH, acidity, and chlorides as consistent predictors. Among the models, random forest demonstrated the most balanced and accurate performance, outperforming the others in accuracy, ROC AUC, and class sensitivity. Its ability to reliably predict both high and low-quality wines makes it the preferred model, while logistic regression and neural networks require improvements in specificity to enhance overall prediction reliability.
