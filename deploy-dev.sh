#!/bin/bash
rsync -avz -e ssh build/web/* lbdev:/data/nginx/static/apps/twinned/
rsync -avz -e ssh assets lbdev:/data/nginx/static/apps/twinned/
rsync -avz -e ssh twinned_widgets/assets lbdev:/data/nginx/static/apps/twinned/
