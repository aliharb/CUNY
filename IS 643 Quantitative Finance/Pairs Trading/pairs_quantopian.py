import math
import numpy as np
import datetime as dt
import statsmodels.tsa.stattools as ts
import statsmodels.api as sm
import pandas as pd

max_lag = 50
max_trades = 3
max_days_open = 10
trade_list = [[], #company 1
              [], #company 2
              [], #original price spread
              [], #original price spread average
              [], #stock_x quantity
              [], #stock_y quantity
              []] #Number of days open

current_trade = None
tuple_list = [('CAB', 'ABT'),
              ('AEP', 'LLY'),
              ('CB', 'ACE'),
              ('HCN', 'MKC'),
              ('XRAY', 'BLL'),
              ('WMT', 'AMT'),
              ('GIS', 'EIX'),
              ('JNJ', 'PG'),
              ('YUM', 'NEE'),
              ('MO', 'CAG'),
              ('HCP', 'VZ'),
              ('BF-B', 'DTE'),
              ('YUM', 'ECL'),
              ('POM', 'TE'),
              ('PX', 'CVX'),
              ('DTE', 'MKC'),
              ('XL', 'CA'),
              ('CCE', 'T')
              ]

tuple_list = [('EWA', 'EWC')]

def initialize(context):
    global all_pairs

    #dictionary of our stock universe
    #(stock sid, stock history with length max_lag)
    context.stocks = {"MO": (sid(4954), []),
                      "ABT": (sid(62), []),
                      "DTE": (sid(2330), []),
                      "SRE": (sid(24778), []),
                      "VTR": (sid(18821), []),
                      "SPG": (sid(10528), []),
                      "CAB": (sid(26412), []),
                      "MKC": (sid(4705), []),
                      "ACE": (sid(8580), []),
                      "CB": (sid(1274), []),
                      "AEP": (sid(161), []),
                      "LLY": (sid(4487), []),
                      "HCN": (sid(3488), []),
                      "GIS": (sid(3214), []),
                      "XRAY": (sid(8352), []),
                      "BLL": (sid(939), []),
                      "WMT": (sid(8229), []),
                      "AMT": (sid(24760), []),
                      "EIX": (sid(14372), []),
                      "KO": (sid(4283), []),
                      "JNJ": (sid(4151), []),
                      "PG": (sid(5938), []),
                      "YUM": (sid(17787), []),
                      "NEE": (sid(5249), []),
                      "MO": (sid(4954), []),
                      "CAG": (sid(1228), []),
                      "HCP": (sid(3490), []),
                      "VZ": (sid(21839), []),
                      "BF-B": (sid(822), []),
                      "ECL": (sid(2427), []),
                      "POM": (sid(6098), []),
                      "TE": (sid(7369), []),
                      "PX": (sid(6272), []),
                      "CVX": (sid(23112), []),
                      "MMM": (sid(4922), []),
                      "PPG": (sid(6116), []),
                      "BMY": (sid(980), []),
                      "XL": (sid(8340), []),
                      "CA": (sid(1209), []),
                      "CCE": (sid(1332), []),
                      "T": (sid(6653), []),
                      "AAPL": (sid(24), []),
                      "GOOG": (sid(26578), []),
                      "TRI": (sid(23825), []),
                      "IHS": (sid(27791), []),
                      "KO": (sid(4283), []),
                      "PEP": (sid(5885), []),
                      "EWC": (sid(14517), []),
                      "EWA": (sid(14516), [])
                    }


    schedule_function(scheduled_fun, date_rules.every_day(), time_rules.market_open())
    schedule_function(trade_increment_check, date_rules.every_day(), time_rules.market_open())

def trade_increment_check(context, data):
    global trade_list
    global max_days_open

    len_adjust = 0
    for t in range(0,len(trade_list[0])):


        stock_x = trade_list[0][t-len_adjust]
        stock_y = trade_list[1][t-len_adjust]
        trade_list[6][t] = trade_list[6][t-len_adjust] + 1
        shares_x = trade_list[4][t-len_adjust]
        shares_y = trade_list[5][t-len_adjust]

        if trade_list[6][t] > max_days_open:
            #If the trade has been open for too long, close it
            print "Close it"
            if trade_list[2][t-len_adjust] > trade_list[3][t-len_adjust]:
                order(stock_x, shares_x)
                order(stock_y, -shares_y)
                trade_list[0].pop(t-len_adjust)
                trade_list[1].pop(t-len_adjust)
                trade_list[2].pop(t-len_adjust)
                trade_list[3].pop(t-len_adjust)
                trade_list[4].pop(t-len_adjust)
                trade_list[5].pop(t-len_adjust)
            else:
                order(stock_y, shares_y)
                order(stock_x, -shares_x)
                trade_list[0].pop(t-len_adjust)
                trade_list[1].pop(t-len_adjust)
                trade_list[2].pop(t-len_adjust)
                trade_list[3].pop(t-len_adjust)
                trade_list[4].pop(t-len_adjust)
                trade_list[5].pop(t-len_adjust)
            len_adjust = len_adjust + 1



def buy_signal(context, data, pair):

    #pair=('COKE', 'PEP')
    global max_trades
    global all_pairs
    global trade_list
    global max_lag

    #allocate cash for each trade
    cash_per_trade = (context.portfolio.cash)/(2*max_trades)

    stock_x = (context.stocks)[pair[0]][0]
    stock_y = (context.stocks)[pair[1]][0]

    stock_x_price = math.log10(data.current((context.stocks)[pair[0]][0], 'price'))
    stock_y_price = math.log10(data.current((context.stocks)[pair[1]][0], 'price'))

    shares_x = int(cash_per_trade/stock_x_price)
    shares_y = int(cash_per_trade/stock_y_price)

    #get the difflist
    x_history = data.history(stock_x, 'close', max_lag, '1d')
    y_history = data.history(stock_y, 'close', max_lag, '1d')

    deletelist = []
    for i in range(0, len(x_history)):
        if math.isnan(x_history.values[i]) or math.isnan(y_history.values[i]):
            deletelist.append(i)
    x_history = x_history.drop(x_history.index[[deletelist]])
    y_history = y_history.drop(y_history.index[[deletelist]])
    diff_list = np.log10(x_history.values) - np.log10(y_history.values)

    #Compare the price differences in x and y
    ave = np.average(diff_list)
    stdev = np.std(diff_list)
    cointegrated = are_cointegrated(x_history.values, y_history.values)

    #if the stocks are cointegrated
    if cointegrated:
        #print "Cointegrated"
        #if the difference in the normalized price is greater than 2 historical stdevs
        if (abs(stock_x_price - stock_y_price) >= (abs(ave)+(stdev))):
            #is stock_x is above its relative price or stock_y below its relative price
            if (stock_x_price - stock_y_price) > ave:
                order((context.stocks)[pair[0]][0], -shares_x)
                order((context.stocks)[pair[1]][0], shares_y)
                trade_list[0].append(stock_x)
                trade_list[1].append(stock_y)
                trade_list[2].append(stock_x_price - stock_y_price)
                trade_list[3].append(ave)
                trade_list[4].append(shares_x)
                trade_list[5].append(shares_y)
                trade_list[6].append(0)
            else:
                order((context.stocks)[pair[1]][0], -shares_y)
                order((context.stocks)[pair[0]][0], shares_x)
                trade_list[0].append(stock_x)
                trade_list[1].append(stock_y)
                trade_list[2].append(stock_x_price - stock_y_price)
                trade_list[3].append(ave)
                trade_list[4].append(shares_x)
                trade_list[5].append(shares_y)
                trade_list[6].append(0)


def sell_signal(context, data, pair, trade_index):

    global trade_list

    stock_x = (context.stocks)[pair[0]][0]
    stock_y = (context.stocks)[pair[1]][0]

    stock_x_price = math.log10(data.current((context.stocks)[pair[0]][0], 'price'))
    stock_y_price = math.log10(data.current((context.stocks)[pair[1]][0], 'price'))

    #get the difflist
    x_history = data.history(stock_x, 'close', max_lag, '1d')
    y_history = data.history(stock_y, 'close', max_lag, '1d')

    deletelist = []
    for i in range(0, len(x_history)):
        if math.isnan(x_history.values[i]) or math.isnan(y_history.values[i]):
            deletelist.append(i)
    x_history = x_history.drop(x_history.index[[deletelist]])
    y_history = y_history.drop(y_history.index[[deletelist]])
    diff_list = np.log10(x_history.values) - np.log10(y_history.values)

    #Compare the price differences in x and y
    ave = np.average(diff_list)
    old_ave = trade_list[3][trade_index]

    shares_x = trade_list[4][trade_index]
    shares_y = trade_list[5][trade_index]

    #if the original difference > old average
    if trade_list[2][trade_index] > old_ave:
        #sell if the current difference < current_ave    (crossover)
        if (stock_x_price - stock_y_price) < ave:
            order(stock_x, shares_x)
            order(stock_y, -shares_y)
            trade_list[0].pop(trade_index)
            trade_list[1].pop(trade_index)
            trade_list[2].pop(trade_index)
            trade_list[3].pop(trade_index)
            trade_list[4].pop(trade_index)
            trade_list[5].pop(trade_index)
            trade_list[6].pop(trade_index)

    #if the orignal difference < old average
    else:
        #sell if the current difference > current average    (crossover)
        if (stock_x_price - stock_y_price) > ave:
            order(stock_y, shares_y)
            order(stock_x, -shares_x)
            trade_list[0].pop(trade_index)
            trade_list[1].pop(trade_index)
            trade_list[2].pop(trade_index)
            trade_list[3].pop(trade_index)
            trade_list[4].pop(trade_index)
            trade_list[5].pop(trade_index)
            trade_list[6].pop(trade_index)






def scheduled_fun(context, data):

    global tuple_list
    global trade_list

    for t in tuple_list:
        stock_x = t[0]
        stock_y = t[1]

        #if this trade is open
        trade_exists = False
        for n in range(0, len(trade_list[0])):
            if (trade_list[0][n] == stock_x and trade_list[1][n] == stock_y) or (trade_list[0][n] == stock_y and trade_list[1][n] == stock_x):
                trade_exists = True
                sell_signal(context, data, t, n)
                break

        #if this trade is not open
        if not trade_exists and len(trade_list[0]) < max_trades:
            #look to see if meets criteria and if so buy
            buy_signal(context, data, t)


def print_average(context, data):
    pair=('COKE', 'PEP')
    assetlist = []
    for asset in (context.stocks).keys():
        assetlist.append((context.stocks)[asset][0])

    x_history = data.history((context.stocks)[pair[0]][0], 'close', max_lag, '1d')
    y_history = data.history((context.stocks)[pair[1]][0], 'close', max_lag, '1d')

    history = data.history(assetlist, 'close', 10, '1d')

    deletelist = []
    x_history_values = x_history.values
    y_history_values = y_history.values
    for i in range(0, len(x_history)):
        if math.isnan(x_history_values[i]) or math.isnan(y_history_values[i]):
            deletelist.append(i)
    x_history = x_history.drop(x_history.index[[deletelist]])
    y_history = y_history.drop(y_history.index[[deletelist]])


    print math.log10(data.current(pair[0], 'price'))


#conduct augmented dickey fuller or array x with a default
#level of 10%
def is_stationary(x, p):

    x = np.array(x)
    result = ts.adfuller(x, regression='ctt')
    #1% level
    if p == 1:
        #if DFStat <= critical value
        if result[0] >= result[4]['1%']:        #DFstat is less negative
            #is stationary
            return True
        else:
            #is nonstationary
            return False
    #5% level
    if p == 5:
        #if DFStat <= critical value
        if result[0] >= result[4]['5%']:        #DFstat is less negative
            #is stationary
            return True
        else:
            #is nonstationary
            return False
    #10% level
    if p == 10:
        #if DFStat <= critical value
        if result[0] >= result[4]['10%']:        #DFstat is less negative
            #is stationary
            return True
        else:
            #is nonstationary
            return False


#Engle-Granger test for cointegration for array x and array y
def are_cointegrated(x, y):

    #check x is I(1) via Augmented Dickey Fuller
    x_is_I1 = not(is_stationary(x, 10))
    #check y is I(1) via Augmented Dickey Fuller
    y_is_I1 = not(is_stationary(y, 10))
    #if x and y are no stationary
    if x_is_I1 and y_is_I1:
        X = sm.add_constant(x)
        #regress x on y
        model = sm.OLS(np.array(y), np.array(X))
        results = model.fit()
        const = results.params[1]
        beta_1 = results.params[0]
        #solve for ut_hat
        u_hat = []
        for i in range(0, len(y)):
            u_hat.append(y[i] - x[i] * beta_1 - const)
        #check ut_hat is I(0) via Augmented Dickey Fuller
        u_hat_is_I0 = is_stationary(u_hat, 1)
        #if ut_hat is I(0)
        if u_hat_is_I0:
            #x and y are cointegrated
            return True
        else:
            #x and y are not cointegrated
            return False
    #if x or y are nonstationary they are not cointegrated
    else:
        return False
