## Correlation

import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('jobs.csv')

df['time_of_post'] = pd.to_datetime(df['time_of_post'])
df['time_of_post'] = df['time_of_post'].dt.hour

cor = df.corr()
sns.heatmap(cor, annot=True, cmap=plt.cm.Reds)
plt.show()

# There seems to be a positive correlation between time_of_post (0.29) and accepted and number_of_tradies (0.23) and accepted


## Prediction

bins = [0, 4, 8, 12, 16, 20, 24]
labels = ['Late Night', 'Early Morning','Morning','Noon/Early Arvo','Evening','Night']

df['time_of_post'] = pd.cut(df['time_of_post'], bins=bins, labels=labels, include_lowest=True)

df = df.fillna(0) # number_of_impressions column contains some NaN values

from sklearn.model_selection import train_test_split

X = df.drop("accepted", axis=1)
X = pd.get_dummies(data=X) # get dummy variables (create columns containing bool values for all of the time_of_post bins and also estimated_size)
y = df["accepted"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.4, random_state=101)

from sklearn.linear_model import LinearRegression
model = LinearRegression()
model.fit(X_train,y_train)

pd.DataFrame(model.coef_,X.columns,columns=['Coefficient'])
#                               Coefficient
# latitude                        -0.000738
#  longitude                      -0.000245
# category                        -0.001255
# number_of_tradies                0.000034
# number_of_impressions            0.000004
# time_of_post_Late Night         -0.180950 *
# time_of_post_Early Morning      -0.173918 *
# time_of_post_Morning            -0.086593 *
# time_of_post_Noon/Early Arvo     0.153169 *
# time_of_post_Evening             0.126125 *
# time_of_post_Night               0.162168 *
# estimated_size_medium            0.095876
# estimated_size_small            -0.095876

model.predict(X_test)
