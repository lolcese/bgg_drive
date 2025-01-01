# coding=utf-8
###############################################################
# En bgg, apuntar a [IMG]https://drive.google.com/file/d/1u7UxDHF1t-QAG1d_JTSXO1Mop5Z59zuB[/IMG]
###############################################################

import requests
from datetime import datetime, timezone
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import os
import re
from urllib.request import urlopen

##############################
# path = "/root/bgg_drive"
path = "."
anio = 2024
goal = 20000

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
}
##############################

######### Baja una página
def baja_pagina(url):
    page = urlopen(url)
    html_bytes = page.read()
    html = html_bytes.decode("utf-8")
    return html

######### Lee información de BGG
def lee_pagina():
    url = "https://boardgamegeek.com/support/randomblurb"
    text = baja_pagina(url)
    if text == "Error":
        return None
    supporters = re.search('"numsupporters":"(.*?)"',text)[1]
    if not supporters:
       return None
    return supporters

don = lee_pagina()
if don != None:
    f = open(f"{path}/drive_{anio}.dat", "a")
    f.write(f"{datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M')},{don}\n")
    f.close()

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
    for line in open(f"drive_{an}.dat", "r"):
        lines = [i for i in line.split(",")]
        if lines[1] == "\n":
            continue
        x.append(lines[0])
        y.append(lines[1])
    dates = [pd.to_datetime(d) - pd.DateOffset(years = an - 2015) for d in x]
    supporters = [int(d) for d in y]
    if an == anio:
        plt.plot(dates,supporters, '-', linewidth=4, markersize=0.0, color = "#FFFFFF")
        last_date = dates[-1]
        last_supporter = supporters[-1]
        ax1.annotate(
            f"{last_supporter}",
            xy=(last_date, last_supporter),  # Coordenadas del punto
            xytext=(last_date, last_supporter + 1000),  # Posición del texto
            arrowprops=dict(facecolor=colores[str(an)], shrink=0.05, width=1, headwidth=8),
            fontsize=10,
            ha='center',
            va='bottom'
        )

    plt.plot(dates, supporters, '-', label = an, linewidth=2, markersize=0.0, color = colores[str(an)])
plt.legend(loc="lower right", ncol=2)
plt.tight_layout()
plt.axhline(y=goal, color="#228b22", linestyle='-')
plt.text(x=pd.Timestamp('2015-12-01 12:00:00'), y=goal, s=f"Goal: {goal} supporters", ha='left', va='bottom', fontsize=12, color="#228b22") 
fig.text(x=0.5, y=0.01, s=f"Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC", ha='center', va='center', fontsize=8)
plt.savefig(f"bgg_{an}.png",dpi=200)
plt.close('all')

#os.system(f"rclone copy {path}/bgg_{anio}.png gdrive:bgg_drive")
os.system(f"git add bgg_{an}.png")
os.system('git commit -m "Imagen actualizada automáticamente"')
os.system("git push")
