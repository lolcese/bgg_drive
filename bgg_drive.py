# coding=utf-8
###############################################################
# En bgg, apuntar a [IMG]https://drive.google.com/file/d/1u7UxDHF1t-QAG1d_JTSXO1Mop5Z59zuB[/IMG]
###############################################################

import requests
from datetime import datetime, timezone, timedelta
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import os
import re
from urllib.request import urlopen
import numpy as np

##############################
path = "."
anio = 2025
goal = 20000
flecha = True  # Activado para mostrar la comparación
bajar = True

colores = {
    '2015': '#e0c492',
    '2016': '#323d77',
    '2017': '#ff0000',
    '2018': '#ffce00',
    '2019': '#42b0a3',
    '2020': '#ff7062',
    '2021': '#ad114c',
    '2022': '#88f2cb',
    '2023': '#3504c9',
    '2024': '#9b48a8',
    '2025': '#ffa400',
}
##############################

######### Baja una página
def baja_pagina(url):
    try:
        page = urlopen(url)
        html_bytes = page.read()
        html = html_bytes.decode("utf-8")
        return html
    except:
        return "Error"

######### Lee información de BGG
def lee_pagina():
    url = "https://boardgamegeek.com/support/randomblurb"
    text = baja_pagina(url)
    if text == "Error" or text is None:
        return None
    try:
        supporters = re.search('"numsupporters":"(.*?)"', text)[1]
        return supporters
    except:
        return None

if bajar:
    don = lee_pagina()
    if don != None:
        f = open(f"{path}/drive_{anio}.dat", "a")
        f.write(f"{datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M')},{don}\n")
        f.close()

# --- PRE-CÁLCULO PARA OBTENER FECHA OBJETIVO ---
target_date_norm = None
try:
    with open(f"drive_{anio}.dat", "r") as f:
        lines = f.readlines()
        if lines:
            last_line = lines[-1].strip().split(',')
            # Fecha original del último dato de 2025
            last_dt_orig = pd.to_datetime(last_line[0])
            # Normalizamos a 2015 para poder comparar con el gráfico
            target_date_norm = last_dt_orig - pd.DateOffset(years=anio - 2015)
except FileNotFoundError:
    pass

max_historic_val = 0
best_historic_year = ""

fig, ax1 = plt.subplots(figsize=(6, 5))
fig.suptitle(f"BGG Supporter drive {anio}")
ax1.set_xlabel('December day (UTC)')
fig.autofmt_xdate()
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%d"))
ax1.set_xlim(pd.Timestamp('2015-12-01 00:00:00'), pd.Timestamp('2016-01-01 12:00:00'))
ax1.set_ylabel('Supporters')
ax1.set_ylim(0, 21000)
ax1.xaxis.set_major_locator(mdates.DayLocator(interval=2))
plt.grid()

for an in range(2015, anio+1):
    x = []
    y = []
    try:
        for line in open(f"drive_{an}.dat", "r"):
            lines = [i for i in line.split(",")]
            if lines[1] == "\n":
                continue
            x.append(lines[0])
            y.append(lines[1])
    except FileNotFoundError:
        continue

    if not x: continue

    # Normalizar fechas al año base 2015
    dates_full = [pd.to_datetime(d) - pd.DateOffset(years=an - 2015) for d in x]
    supporters_full = [int(d) for d in y]

    dates = []
    supporters = []
    limit_date = pd.Timestamp('2016-01-01 12:00:00')

    for d, s in zip(dates_full, supporters_full):
        if d < limit_date:
            dates.append(d)
            supporters.append(s)

    if not dates: continue

    max_supporters = max(supporters) 

    # --- LÓGICA DE COMPARACIÓN ---
    # Si no es el año actual, buscamos si hay datos cerca del momento actual (+/- 10 min)
    if an != anio and target_date_norm is not None:
        # Convertimos a Series para facilitar búsqueda
        s_dates = pd.Series(dates)
        s_supp = pd.Series(supporters)
        
        # Filtro de tiempo: diferencia absoluta menor a 10 minutos
        time_diff = (s_dates - target_date_norm).abs()
        mask = time_diff <= pd.Timedelta(minutes=10)
        
        if mask.any():
            # Si hay coincidencias, tomamos el valor del punto más cercano temporalmente
            idx_closest = time_diff.idxmin()
            val_at_moment = s_supp.iloc[idx_closest]
            
            if val_at_moment > max_historic_val:
                max_historic_val = val_at_moment
                best_historic_year = str(an)

    # --- GRAFICAR ---
    if an == anio:
        plt.plot(dates, supporters, '-', linewidth=4, markersize=0.0, color="#FFFFFF")
        
        if flecha and supporters:
            last_date = dates[-1]
            last_supporter = supporters[-1]
            
            # Construir texto de la etiqueta
            label_text = f"{last_supporter}"
            
            # Si encontramos un histórico comparable, agregamos la info
            if max_historic_val > 0:
                diff = last_supporter - max_historic_val
                signo = "+" if diff >= 0 else ""
                label_text += f"\nvs {best_historic_year}:{signo}{diff}"

            # Lógica de dirección de la flecha según el día
            day_num = last_date.day
            if day_num <= 3:
                # Días 1-3: Flecha hacia la izquierda (Texto a la derecha)
                xy_text_pos = (last_date + pd.Timedelta(days=5), last_supporter + 500)
                ha_align = 'left'
            elif day_num >= 29:
                # Días 29-31: Flecha hacia la derecha (Texto a la izquierda)
                xy_text_pos = (last_date - pd.Timedelta(days=5), last_supporter + 500)
                ha_align = 'right'
            else:
                # Resto: Vertical
                xy_text_pos = (last_date, last_supporter + 2000)
                ha_align = 'center'

            ax1.annotate(
                label_text,
                xy=(last_date, last_supporter), 
                xytext=xy_text_pos, 
                arrowprops=dict(facecolor=colores[str(an)], shrink=0.05, width=1, headwidth=8),
                fontsize=9,
                ha=ha_align,
                va='bottom',
                bbox=dict(boxstyle="round,pad=0.3", fc="white", ec=colores[str(an)], alpha=0.9) # Caja de fondo para legibilidad
            )

    alpha_val = 1.0 if an == anio else 0.4
    plt.plot(dates, supporters, '-', label=f"{an} ({max_supporters})", linewidth=2, markersize=0.0, color=colores[str(an)], alpha=alpha_val)

plt.legend(loc="lower right", ncol=2, fontsize='small')
plt.tight_layout()
plt.axhline(y=goal, color="#228b22", linestyle='-')
plt.text(x=pd.Timestamp('2015-12-01 12:00:00'), y=goal, s=f"Goal: {goal} supporters", ha='left', va='bottom', fontsize=12, color="#228b22") 
fig.text(x=0.5, y=0.01, s=f"Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC", ha='center', va='center', fontsize=8)
plt.savefig(f"bgg_{anio}.png", dpi=200)
plt.close('all')

os.system(f"git add bgg_{anio}.png")
os.system('git commit -m "Imagen actualizada automáticamente"')
os.system("git push")
