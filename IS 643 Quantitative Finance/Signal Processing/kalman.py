
x = np.concatenate([x, np.ones([len(stocks['EWA'].values),1])], axis=1)
y = stocks[pair[1]].values.reshape(-1,1)

delta = 0.0001

yhat = [] # Measurement Prediction

e = [] # Measurement prediction error

Q = [] # Measurement prediction error variance

# R(t|t) will be P(t)

P = np.zeros(2,2)

R = np.zeros(2,2)

beta = np.zeros([2,1])

Vw = (delta / (1-delta)) * np.eye(2)

Ve = 0.001

for i in np.arange(0, np.size(y)[0]):
    if i > 0:
        beta = np.concatenate([beta, beta[:,-1].reshape(-1,1)], axis=1) # State prediction
        R = P + Vw # State Covariance Prediction, 3.8

    yhat.append(np.dot(x[i, :], beta[:,i])) # Measurement Prediction, Equation 3.9

    Q.append(x[0,:].dot(R).dot(x[0,:].reshape(-1,1)) + Ve) # Measurement variance prediction, Equation 3.10

    #Observe y(t)
    e.append(y[i] - yhat[i])

    K = R.dot(x[i,:].reshape(-1,1))/Q[i] # Kalman Gain

    beta[:,i] = beta[:,i] + K[:,0]*e[-1] # State update
