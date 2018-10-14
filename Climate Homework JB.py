
# coding: utf-8

# Climate Change SQLAlchemy and Flask Janette Bennett

# In[1]:


#Import MatPlotlib dependencies (given)

get_ipython().run_line_magic('matplotlib', 'inline')
from matplotlib import style
style.use('fivethirtyeight')
import matplotlib.pyplot as plt


# In[2]:


#Import Pandas dependencies (given)
import numpy as np
import pandas as pd


# In[3]:


#Import Datetime dependencies (given)
import datetime as dt


# In[4]:


#Import Flask and jsonify (added) -- had to reimport Flask in the virtual environment
from flask import Flask, jsonify


# # Reflect Tables into SQLAlchemy ORM

# In[5]:


# Python SQL toolkit and Object Relational Mapper (given except for the inspect lib which was added)
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func, inspect


# In[6]:


# Database Set up / 01-Ins_BasicSQL_Connection Lesson
engine = create_engine("sqlite:///Resources/hawaii.sqlite")


# In[7]:


# reflect an existing database into a new model / 05-Ins_Reflection
Base = automap_base()

# reflect the tables
Base.prepare(engine, reflect=True)


# In[8]:


# We can view all of the classes that automap found / 05-Ins_Reflection
Base.classes.keys()


# In[9]:


# Save references to each table / 05-Ins_Reflection
Measurement = Base.classes.measurement
Station = Base.classes.station


# In[10]:


# Create our session (link) from Python to the DB / 05-Ins_Reflection
session = Session(engine)


# # Exploratory Climate Analysis

# In[11]:


#Use Inspector to retrieve table names from 'Measurement' and 'Station' / 07-Ins_Exploration
inspector = inspect(engine)
inspector.get_table_names()


# In[12]:


#Get a list of column names and types for 'Measurement' / 07-Ins_Exploration
columns = inspector.get_columns('measurement')
for c in columns:
    print(c['name'], c['type'])


# In[13]:


#View data from 'Measurement' using select query /01-Ins_BasicSQL_Connection
engine.execute('SELECT * FROM measurement LIMIT 10').fetchall()


# In[14]:


#Get a list of column names and types for 'Station' / 07-Ins_Exploration
columns = inspector.get_columns('station')
for c in columns:
    print(c['name'], c['type'])


# In[15]:


#View data from 'Station' using select query /01-Ins_BasicSQL_Connection
engine.execute('SELECT * FROM station').fetchall()


# In[16]:


# Design a query to retrieve the last 12 months of precipitation data and plot the results / 02-Ins_Dates
session.query(func.count(Measurement.date)).all()


# In[17]:


#Design a query to retrieve the last 12 months of precipitation data and plot the results / 02-Ins_Dates using 2016-08-23
results = session.query(Measurement.date, Measurement.prcp).    filter(Measurement.date > '2016-08-23').    order_by(Measurement.date).all()
print(results)


# In[18]:


# Save the query results as a Pandas DataFrame and set the index to the date column / 05-Ins_DataFunctions
data = {'date': [], 'prcp': []}

for row in results:
    data['date'].append(row.date)
    data['prcp'].append(row.prcp)
    
hawaii_rain = pd.DataFrame(data, columns = ['date','prcp'])
hawaii_rain.head(10)


# In[19]:


hawaii_rain = hawaii_rain.dropna()
hawaii_rain.head(10)


# In[20]:


#Set Index
hawaii_rain.set_index("date",drop=True,inplace=True)
hawaii_rain.head()


# In[21]:


# Use Pandas Plotting with Matplotlib to plot the data
# Rotate the xticks for the dates

# Set x axis and tick locations / 02-Ins_PandasPlot

hawaii_rain.plot(kind='bar', alpha=0.75,rot=0)
plt.show()


# In[23]:


#Use Pandas to print the summary statistics for the precipitation data. 

hawaii_rain.describe(percentiles=None, include=None, exclude=None)


# In[24]:


# Use Pandas to calculate the summary statistics for the precipitation data
hawaii_rain = hawaii_rain.groupby('date')['prcp'].sum()
hawaii_rain


# In[25]:


# Design a query to calculate the total number of stations.
station_count = session.query(func.count(Station.station)).all()
print (station_count)


# In[26]:


# List the stations and observation counts in descending order.
active_station_desc = session.query(Measurement.station,
        func.count(Measurement.tobs)).group_by(Measurement.station).order_by(func.count(Measurement.tobs).desc())

for result in active_station_desc:
    print(result)


# In[27]:


# Which station has the highest number of observations?
active_station_first = session.query(Measurement.station, 
        func.count(Measurement.tobs)).group_by(Measurement.station).order_by(func.count(Measurement.tobs).desc()).first()
      
print(active_station_first)


# In[28]:


#Design a query to retrieve the last 12 months of temperature observation data (tobs) prior to your trip's start date.
temp_month = session.query(Measurement.station, Measurement.date, Measurement.tobs).    filter(Measurement.date > '2016-08-23').    order_by(Measurement.date).all()
temp_month


# In[29]:


#Filter by the station with the highest number of observations.
station_obs = session.query(Measurement.station, Measurement.tobs).    filter(Measurement.date > '2016-08-23').    group_by(Measurement.station).    order_by(func.count(Measurement.tobs).desc()).all()
station_obs


# In[30]:


#Plot the results as a histogram with `bins=12`.
station_df = pd.DataFrame(temp_month, columns=['Station', 'date', 'temp'])
station_df.set_index('Station', inplace=True)
station_df


# In[31]:


rain_plot = station_df['temp'].hist(bins=12)
rain_plot.set_title('Temperature Observations', fontsize=10)
rain_plot.set_ylabel('Frequency', fontsize=10)
plt.show()


# In[32]:


#Use FLASK to create your routes. Flask Set up / 04-Ins_First_Steps_with_Flask
app = Flask(__name__)


# In[33]:


#Create welcome and API Routes / 04-Ins_First_Steps_with_Flask
    
@app.route("/")
def welcome():
    return (
        f"Available Routes:<br/>"
        f"/api/v1.0/precipitation <br/>"
        f"/api/v1.0/stations <br/r>"
        f"/api/v1.0/tobs <br/r>"
        f"/api/v1.0/<start><br/r>"
        f"/api/v1.0/<start>/<end>"
    )


# In[34]:


#/api/v1.0/precipitation` / 06-Ins_Jsonify / Query for the dates and temperature observations from the last year.

@app.route("/api/v1.0/precipitation")
def precipitation():
    prcp_results = session.query(Measurement.date, Measurement.tobs).    filter(Measurement.date > '2016-08-23').all()

#Convert the query results to a Dictionary using `date` as the key and `tobs` as the value.    
    all_pcrp = []
    for prcp in prcp_results:
        prcp_dict = {}
        prcp_dict["Date"] = Measurement.date
        pcrp_dict["TOBS"] = Measurement.tobs
        all_prcp.appent(prcp_dict)
    return jsonify(all_prcp)    
#Return the JSON representation of your dictionary.            


# In[35]:


#/api/v1.0/stations / 10-Ins_Flask_with_ORM / Return a JSON list of Temperature Observations (tobs) for the previous year.

@app.route("/api/v1.0/stations")
def stations():

    station_results = session.query(Station.station).all()

    all_stations = list(np.ravel(station_results))

    return jsonify(all_stations)
#Return a JSON list of stations from the dataset.


# In[36]:


#/api/v1.0/tobs / 10-Ins_Flask_with_ORM

@app.route("/api/v1.0/tobs")
def tobs():
    
    tobs_results = session.query(Measurement.tobs).filter(Measurement.date > '2016-08-23').all()
    
    all_tobs = list(np.ravel(tobs_results))
    
    return jsonify(all_tobs)
#Return a JSON list of Temperature Observations (tobs) for the previous year.


# In[37]:


#/api/v1.0/<start>`
# Return a JSON list of the minimum temperature, the average temperature, and the max temperature for a 
    #given start or start-end range.
# When given the start only, calculate `TMIN`, `TAVG`, and `TMAX` for all dates greater than and equal to the start date.
@app.route("/api/v1.0/<start>")
def temps_start(start_date):
    return session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).    filter(Measurement.date >= start_date).all()

print(temps_start('2016-08-23'))


# In[38]:


#/api/v1.0/<start>/<end>
# Return a JSON list of the minimum temperature, the average temperature, and the max temperature for a 
# When given the start and the end date, calculate the `TMIN`, `TAVG`, and `TMAX` for dates between 
    #the start and end date inclusive.
    
@app.route("/api/v1.0/<start>/<end>")
def temps_end(start_date, end_date):
    return session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).    filter(Measurement.date >= start_date).filter(Measurement.date <= end_date).all()

print(temps_end('2016-08-23', '2016-09-16'))


# In[39]:


#app.run / 04-Ins_First_Steps_with_Flask

if __name__ == '__main__':
    app.run(debug=True)

