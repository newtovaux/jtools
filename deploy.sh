#!/bin/bash

npm run build

ssh root@77.68.12.142 'rm -rf /var/www/html/*'

scp -r dist/* root@77.68.12.142:/var/www/html/
