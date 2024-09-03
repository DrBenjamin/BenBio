import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def csv_reader(file_path):
    # Lesen der CSV-Datei
    df = pd.read_csv(file_path)
    # Extrahieren der SDNN-Werte aus der Spalte 'SDNN'
    sdnn_values = df['SDNN'].tolist()
    return sdnn_values

# Load SDNN values
csv_file = st.file_uploader('Upload CSV file with SDNN values', type='csv')
if csv_file:
  sdnn_values = csv_reader(csv_file)
  print(sdnn_values)

  # Einstufung des Stresslevels anhand der RMSSD-Werte
  if np.mean(sdnn_values) > 50:
      stress_level = "Niedriger Stress"
  elif 25 < np.mean(sdnn_values) <= 50:
      stress_level = "Mittlerer Stress"
  else:
      stress_level = "Hoher Stress"

  # Visualisierung der HRV
  st.title ('HRV Analyse: SDNN')
  fig, ax = plt.subplots(figsize=(10, 5), facecolor='none')
  ax.set_facecolor('none')
  ax.plot(sdnn_values, marker='o')
  ax.set_title('Standard Deviation of the inter-beat (RR) intervals between normal heartbeats (SDNN)', color='gray')
  ax.set_xlabel('SDNNs', color='gray')
  ax.set_ylabel('Intervalls in ms', color='gray')
  ax.axhline(y=np.mean(sdnn_values), color='r', linestyle='--', label=f"Durchschnitt ({np.mean(sdnn_values):.2f} ms)")
  ax.text(0, np.mean(sdnn_values), 'Wertung: {:.2f} ms\nStresslevel: {}'.format(np.mean(sdnn_values), stress_level), fontsize=10, bbox=dict(facecolor='white', alpha=0.5))
  ax.legend()
  ax.grid()
  st.pyplot(fig)
