#!/bin/bash
rsync -avz -e ssh build/web/* lb:/data/nginx/static/apps/twinned/
rsync -avz -e ssh assets lb:/data/nginx/static/apps/twinned/
rsync -avz -e ssh twinned_widgets/assets lb:/data/nginx/static/apps/twinned/
