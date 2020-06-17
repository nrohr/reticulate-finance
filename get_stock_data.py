# Some resources inspiring this demo:
# - https://www.learndatasci.com/tutorials/python-finance-part-yahoo-finance-api-pandas-matplotlib/
# - https://www.codingfinance.com/post/2018-04-05-portfolio-returns-py/

from pandas_datareader import data
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
from datetime import date

# First define our 5 tech stocks:
tickers = ['AAPL', 'AMZN', 'GOOG', 'NFLX', 'TSLA']

# Get data starting in 2010 and ending today
start_date = '2010-01-01'
end_date = date.today()

# User pandas_reader.data.DataReader to load the desired data from Yahoo Finance
stock_data = data.DataReader(tickers, 'yahoo', start_date, end_date)

# Get the Adjusted Close columns and store it in a new object, prices
prices = stock_data['Adj Close']

prices.head()

# Calculate daily returns for each stock
returns = prices.pct_change(1)

# Fill missing values with 0
returns = returns.fillna(0)

returns.head()

# Assign weights
weights = [0.3, 0.3, 0.25, 0.10, 0.05]

# Calculate individually weighted returns
weighted_returns = (weights * returns)

weighted_returns.head()

# Sum across columns to calculate portfolio returns
portfolio_returns = weighted_returns.sum(axis=1).to_frame()

# Move Date index to column and rename returns column
portfolio_returns = portfolio_returns.reset_index()
portfolio_returns.rename(columns={0:'returns'}, inplace = True)

portfolio_returns.head()

fig = plt.figure()
ax1 = fig.add_axes([0.1,0.1,0.8,0.8])
ax1.hist(portfolio_returns['returns'], bins = 100)
ax1.set_xlabel('Portfolio returns')
ax1.set_ylabel("Freq")
plt.show(); 
