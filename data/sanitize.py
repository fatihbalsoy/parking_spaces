'''
  sanitize.py
  data

  Created by Fatih Balsoy on 8/21/22
  Last Modified by Fatih Balsoy on 8/21/22
  Copyright © 2022 Fatih Balsoy. All rights reserved.
'''

import json
import os

__location__ = os.path.realpath(os.path.join(
    os.getcwd(), os.path.dirname(__file__)))

file = open(os.path.join(__location__, "ids_indexed.json"), "r")

jFile: dict = json.load(file)
sanitizedJFile: dict = {}
for park in jFile.keys():
    print(jFile[park]["name"] + "\t------\t" + park)
    sanitizedJFile[park] = {
        "name": jFile[park]["name"],
        "zoneId": jFile[park]["_zoneId"]
    }

with open(os.path.join(__location__, 'ids_sanitized.json'), 'w') as newFile:
    json.dump(sanitizedJFile, newFile, indent=2)
    print("Sanitized and dumped data to ids_sanitized.json")
