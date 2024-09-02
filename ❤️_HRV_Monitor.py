import streamlit as st
import numpy as np
import matplotlib.pyplot as plt

def calculate_hrv(rr_intervals):
    # RR-Intervalle in Sekunden umwandeln
    rr_intervals = np.array(rr_intervals) / 1000  # von ms zu s
    # RMSSD berechnen
    rmssd = np.sqrt(np.mean(np.square(np.diff(rr_intervals))))
    return rmssd

# Beispiel RR-Intervalle (in Millisekunden)
rr_intervals = [800, 810, 790, 760, 770, 800, 790]
rmssd_value = calculate_hrv(rr_intervals)

# Einstufung des Stresslevels anhand der RMSSD-Werte
if rmssd_value > 50:
    stress_level = "Niedriger Stress"
elif 25 < rmssd_value <= 50:
    stress_level = "Mittlerer Stress"
else:
    stress_level = "Hoher Stress"

# Visualisierung der HRV
st.title ('HRV Analyse: RR-Intervalle')
fig, ax = plt.subplots(figsize=(10, 5), facecolor='none')
ax.set_facecolor('none')
ax.plot(rr_intervals, marker='o')
ax.set_title('HRV Analyse: RR-Intervalle', color='gray')
ax.set_xlabel('Anzahl der Herzschläge (aufeinanderfolgende Intervalle)', color='gray')
ax.set_ylabel('RR-Intervalle (ms)', color='gray')
ax.axhline(y=1000, color='r', linestyle='--', label='Durchschnitt')
ax.text(0, 1000.1, 'Wertung: {:.2f} ms\nStresslevel: {}'.format(rmssd_value, stress_level), fontsize=10, bbox=dict(facecolor='white', alpha=0.5))
ax.legend()
ax.grid()
st.pyplot(fig)
