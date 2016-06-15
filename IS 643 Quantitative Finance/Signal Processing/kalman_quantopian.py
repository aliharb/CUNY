from quantopian.algorithm import attach_pipeline, pipeline_output
from quantopian.pipeline import Pipeline
from quantopian.pipeline.data.builtin import USEquityPricing
from quantopian.pipeline.factors import AverageDollarVolume

import numpy as np

def initialize(context):

    context.ewa = sid(24)
    context.ewc = sid(46631)

    context.delta = 0.0001

    context.yhat = [] # Measurement Prediction

    context.e = [] # Measurement prediction error

    context.Q = [] # Measurement prediction error variance

    # R(t|t) will be P(t)

    context.P = np.zeros([2,2])

    context.R = np.zeros([2,2])

    context.beta = np.zeros([2,1])

    context.Vw = (context.delta / (1-context.delta)) * np.eye(2)

    context.Ve = 0.001

    context.pos = None #position
    context.day = None #current day

    context.i = 0

    # Rebalance every day, 1 hour after market open.
    schedule_function(kalmanize, date_rules.every_day(), time_rules.market_open(hours=1))

def kalmanize(context, data):

    if context.i == 0:
        context.x = np.array([data.current(context.ewa, 'close'), 1]).reshape(1,-1)
        context.y = [data.current(context.ewc, 'close')]

    else:
        context.x = np.concatenate([context.x, np.array([[data.current(context.ewa, 'close'), 1]])], axis=0)
        context.y.append(data.current(context.ewc, 'close'))

    if context.i > 0:
        context.beta = np.concatenate([context.beta, context.beta[:,-1].reshape(-1,1)], axis=1)
        context.R = context.P + context.Vw

    context.yhat.append(context.x[context.i, :].dot(context.beta[:,context.i])) # Measurement Prediction, Equation 3.9

    context.Q.append(float(context.x[context.i ,:].dot(context.R.dot(context.x[context.i,:].reshape(-1,1))) + context.Ve)) # Measurement variance prediction, Equation 3.10

    #Observe y(t)
    context.e.append(context.y[context.i] - context.yhat[context.i])

    context.K = context.R.dot(context.x[context.i,:].reshape(-1,1))/context.Q[context.i] # Kalman Gain

    context.beta[:,context.i] = context.beta[:,context.i] + context.K[:,0]*context.e[-1] # State update

    context.P = context.R - (context.K*context.x[context.i,:]).dot(context.R)

    sqrt_Q = np.sqrt(context.Q[-1])
    if context.e[-1] < 5:
        record(spread=float(context.e[-1]), Q_upper=float(np.sqrt(context.Q[-1])), Q_lower=float(-np.sqrt(context.Q[-1])))

    #do the trades
    #close positions
    if context.pos is not None:
        if context.pos == 'long' and context.e[-1] > -sqrt_Q:
            #log.info('closing long')
            order_target(context.ewa, 0)
            order_target(context.ewc, 0)
            context.pos = None
        elif context.pos == 'short' and context.e[-1] < sqrt_Q:
            #log.info('closing short')
            order_target(context.ewa, 0)
            order_target(context.ewc, 0)
            context.pos = None

    #open positions
    if context.pos is None:
        if context.e[-1] < -sqrt_Q:
            #log.info('opening long')
            order(context.ewc, 1000)
            order(context.ewa, -1000 * context.beta[0,context.i])
            context.pos = 'long'
        elif context.e[-1] > sqrt_Q:
            #log.info('opening short')
            order(context.ewc, -1000)
            order(context.ewa, 1000 * context.beta[0,context.i])
            context.pos = 'short'

    context.i = context.i + 1
