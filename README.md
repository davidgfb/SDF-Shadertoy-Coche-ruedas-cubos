[capture.webm](https://github.com/user-attachments/assets/5b9201d3-3fb0-44ad-af97-473407223687)

TODO: ampliar rueda a prisma n lados<br>
Cada rueda cae independientemente, el chasis (hexaedro) ajusta su orientacion<br><br>

if es_Bajo_Torque: w_Rueda = 2  # Velocidad angular baja si el torque es bajo<br>
else: w_Rueda = 3  # Velocidad angular alta si el torque es alto<br><br>

if not tiene_Agarre: w_Rueda -= 1  # Reducción en la velocidad angular si no hay agarre<br><br>

# Cálculo de la velocidad del coche<br>
v_Coche = w_Rueda * r_Rueda  # Velocidad lineal del coche

