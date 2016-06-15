# Use the previous 10 bars' movements to predict the next movement.

# Use a random forest classifier. More here: http://scikit-learn.org/stable/user_guide.html
from sklearn.ensemble import RandomForestClassifier
from collections import deque
import numpy as np

def initialize(context):
    context.stocks = {'DIS': sid(2190)}

    context.X = []

    context.y = []

    context.w = 30

    context.classifier = RandomForestClassifier() # Use a random forest classifier

    context.prediction = 0 # Stores most recent prediction
    #set_slippage(slippage.FixedSlippage(spread=0.25))
    #set_commission(commission.PerShare(0.15))

    schedule_function(scheduled_fun, date_rules.every_day(), time_rules.market_open())


def scheduled_fun(context, data):

    changes = np.diff(data.history((context.stocks)['DIS'], 'close', context.w, '1d')) > 0

    context.X.append(changes[:-1])
    context.y.append(changes[-1])

    context.classifier.fit(np.array(context.X), np.array(context.y))

    context.prediction = int(context.classifier.predict(changes[1:]))

    order_target_percent((context.stocks)['DIS'], context.prediction)

    print int(context.prediction)

    record(prediction=int(context.prediction))

"""
def handle_data(context, data):
    context.recent_prices.append(data[context.security].price) # append recent price to the list
    if len(context.recent_prices) == context.window_length + 2: # If there's enough recent price data

        # Make a list of 1's and 0's, 1 when the price increased from the prior bar
        changes = np.diff(context.recent_prices) > 0

        context.X.append(changes[:-1]) # Add independent variables, the prior changes
        context.Y.append(changes[-1]) # Add dependent variable, the final change

        log.info(changes[:-1]) #logging
        log.info(changes[-1]) #logging

        if len(context.Y) >= 100: # There needs to be enough data points to make a good model

            context.classifier.fit(context.X, context.Y) # fit the data using the classifier (supervised learning)

            context.prediction = context.classifier.predict(changes[1:]) # predict using 1-9

            # If prediction = 1, buy all shares affordable, if 0 sell all shares
            order_target_percent(context.security, context.prediction)

            record(prediction=int(context.prediction))


            """
