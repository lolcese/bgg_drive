###############################################################
# En bgg, apuntar a [IMG]https://drive.google.com/uc?id=1kWXNh9uI_LlDJEDI1QWVIriGkj0L4zqZ[/IMG]
###############################################################

import requests
from datetime import datetime, timezone
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import os

##############################
path = "/root/bgg_drive"
anio = 2023

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
}

##############################

# ######### Baja una página
# def baja_pagina(url):
#     page = urlopen(url)
#     html_bytes = page.read()
#     html = html_bytes.decode("utf-8")
#     return html

# ######### Lee información de BGG
# def lee_pagina():
#     url = f"www.lilialardone.com.ar/temp/drive_{anio}.dat"
#     text = baja_pagina(url)
    # print(text)
    # if text == "Error":
    #     return None
    # supporters = re.search("<h3 class='support-drive-status-title'>(.*)? Supporters</h3>",text)
    # if not supporters:
    #    return None
    # return supporters

# don = lee_pagina()
# if don != None:
#     f = open(f"{path}/drive_{anio}.dat", "a")
#     f.write(f"{datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M')},{don}\n")
#     f.close()

url = f"http://www.lilialardone.com.ar/temp/drive_{anio}.dat"
response = requests.get(url)
open(f"drive_{anio}.dat", "wb").write(response.content)

fig, ax1 = plt.subplots()
fig.suptitle(f"BGG Supporter drive {anio}")
ax1.set_xlabel('Day (UTC)')
fig.autofmt_xdate()
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%d"))
ax1.set_xlim(pd.Timestamp('2015-12-01 00:00:00'), pd.Timestamp('2016-01-01 12:00:00'))
ax1.set_ylabel('Supporters')
ax1.set_ylim(0, 20000)
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
        ancho = 3.0
    else:
        ancho = 2.0
    plt.plot_date(dates, supporters, '-', label = an, linewidth=ancho, markersize=0.0, color = colores[str(an)])
plt.legend(loc="lower right", ncol=2)
fig.text(x=0.5, y=0.01, s=f"Generated on {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')} UTC", ha='center', va='center', fontsize=8)
plt.savefig(f"bgg_{an}.png",dpi=200)
plt.close('all')

os.system(f"rclone copy {path}/bgg_{anio}.png gdrive:bgg_drive")
