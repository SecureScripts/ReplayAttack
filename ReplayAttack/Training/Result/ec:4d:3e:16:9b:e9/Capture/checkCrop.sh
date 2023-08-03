#!/bin/bash
CROP=$(cat crop.txt)
convert reference.png reference.png -crop $CROP +repage miff:- | compare -verbose -metric MAE  - result.png 2>&1 | grep all | awk '{print $2}'
