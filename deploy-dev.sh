#!/bin/bash
rsync -avz -e ssh build/web/* azdev:/home/ubuntu/docker/data/nginx/static/apps/twinned/
rsync -avz -e ssh assets azdev:/home/ubuntu/docker/data/nginx/static/apps/twinned/
rsync -avz -e ssh twinned_widgets/assets azdev:/home/ubuntu/docker/data/nginx/static/apps/twinned/
