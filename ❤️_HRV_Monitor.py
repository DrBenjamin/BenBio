import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pytz
from datetime import datetime, timedelta

def csv_reader(file_path):
    df = pd.read_csv(file_path)
    
    # Cleaing columns
    df.columns = df.columns.str.strip()
    
    # Convert Date column to datetime
    if 'Date' in df.columns:
        df['Date'] = pd.to_datetime(df['Date'])
    return df

# Title
st.title ('HRV Analyse: SDNN')
st.header('Standard Deviation of inter-beat intervals')
st.write('Apple reports HRV as the SDNN feature. This feature has a long history and was used mostly in the context of 24-hour measurements in medical practice. The idea is that by looking at SDNN we could get an understanding of cardiac variability changes throughout the day, as a response to circadian rhythm and acute stressors.')

# Load SDNN values
csv_file = st.file_uploader('Upload CSV file with SDNN values', type='csv')
if csv_file:
  sdnn_values = csv_reader(csv_file)
  
  # Filtern der Daten der letzten Woche
  if 'Date' in sdnn_values:
    st.subheader('Selection of dates')
    end_day_sl, start_day_sl = st.slider('Select a range of days (0 = today, 0 - 7 = last week)', 0, 180, (0, 7))
    end_day = datetime.now(pytz.utc) - timedelta(days=end_day_sl)
    start_day = end_day - timedelta(days=(start_day_sl - end_day_sl))
    sdnn_values = sdnn_values[(sdnn_values['Date'] >= start_day) & (sdnn_values['Date'] <= end_day)]
    sdnn_values['Date'] = sdnn_values['Date'].dt.strftime('%Y-%m-%d')
    sdnn_values = sdnn_values.reset_index(drop=True)

  # Categorizing Stresslevels
  mean_sdnn = np.mean(sdnn_values['SDNN'].to_list())
  if mean_sdnn > 50:
      stress_level = "Low stress"
  elif 25 < mean_sdnn <= 50:
      stress_level = "Medium stress"
  else:
      stress_level = "High stress"

  # Visualising HRV
  st.subheader('SDNN visualisation')
  fig, ax = plt.subplots(figsize=(10, 5), facecolor='none')
  ax.set_facecolor('none')
  ax.set_title('Standard Deviation of the inter-beat (RR) intervals between normal heartbeats (SDNN)', color='gray')
  if 'Date' in sdnn_values:
      ax.plot(sdnn_values['Date'], sdnn_values['SDNN'], marker='o')
      ax.set_xlabel('Date', color='gray')
  else:
      ax.plot(sdnn_values['SDNN'], marker='o')
  ax.set_ylabel('SDNNs in ms', color='gray')
  ax.axhline(y=mean_sdnn, color='r', linestyle='--', label=f"Average ({mean_sdnn:.2f} ms)")
  ax.text(0, mean_sdnn, 'Avg. value: {:.2f} ms\nStresslevel: {}'.format(mean_sdnn, stress_level), fontsize=10, bbox=dict(facecolor='white', alpha=0.5))
  ax.legend()
  ax.grid()
  st.pyplot(fig)
