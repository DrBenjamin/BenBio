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
plt.figure(figsize=(10, 5))
plt.plot(rr_intervals, marker='o')
plt.title('HRV Analyse: RR-Intervalle')
plt.xlabel('Anzahl der Herzschläge (aufeinanderfolgende Intervalle)')
plt.ylabel('RR-Intervalle (ms)')
plt.axhline(y=1000, color='r', linestyle='--', label='Durchschnitt')
plt.text(0, 1000.1, 'Wertung: {:.2f} ms\nStresslevel: {}'.format(rmssd_value, stress_level), fontsize=10, bbox=dict(facecolor='white', alpha=0.5))
plt.legend()
plt.grid()
plt.show()
