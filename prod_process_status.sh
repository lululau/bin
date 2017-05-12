#!/bin/bash

USER=deploy

echo -e '\0033[32mServer: kt01-prod\0033[0m'
echo -e '\0033[32m==================================================\0033[0m'
ssh -p 10080 "$USER@pm.kaitongamc.com" 'ps -ef | grep -v grep | grep baton-web-production --color=always'
ssh -p 10080 "$USER@pm.kaitongamc.com" 'sudo systemctl status baton-unicorn-production'
ssh -p 10080 "$USER@pm.kaitongamc.com" 'sudo systemctl status baton-sneakers-production'

echo -e '\0033[32mServer: kt02-prod\0033[0m'
echo -e '\0033[32m==================================================\0033[0m'
ssh -p 10080 "$USER@101.201.149.187" 'ps -ef | grep -v grep |  grep "baton-web-production" --color=always'
ssh -p 10080 "$USER@101.201.149.187" 'sudo systemctl status baton-unicorn-production'
ssh -p 10080 "$USER@101.201.149.187" 'sudo systemctl status baton-sneakers-production'

echo -e '\0033[32mServer: kt03-prod\0033[0m'
echo -e '\0033[32m==================================================\0033[0m'
ssh -p 10080 "$USER@101.201.149.250" 'ps -ef | grep -v grep | grep "baton-web-production" --color=always'
ssh -p 10080 "$USER@101.201.149.250" 'sudo systemctl status baton-unicorn-production'
ssh -p 10080 "$USER@101.201.149.250" 'sudo systemctl status baton-sneakers-production'
