import pandas as pd
from pathlib import Path
import json
import numpy as np


current_folder = Path(__file__).parent
csv_file = str(current_folder) + '/Sample-Superstore.csv'
dataset = pd.read_csv(csv_file, encoding='windows-1254')
# print(dataset)
# exit()
#
json_file = str(current_folder) + '/products.json'
# a = dataset['Category'].unique()
# b = dataset['Sub-Category'].unique()
# c = np.concatenate((a, b))
# pd.Series(c).to_json(json_file)

# pd.Series(c).to_json(json_file)