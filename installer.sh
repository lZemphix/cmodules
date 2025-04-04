#!/bin/bash
echo -e "\e[33mInstallation started!\e[0m"
echo -e "\e[33mDocker installation\e[0m"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo -e "\e[32mDocker Installation successful\e[0m"

echo -e "\e[33mBot installing\e[0m"

echo -e "\e[32mImage installing\e[0m"
sudo docker pull zemphix/trade_bot
echo -e "\e[33mImage installed\e[0m"

mkdir confmt

echo -e "\e[33mSetting bot config...\e[0m"
echo -e "\e[4;33mIf you don't know what a parameter is responsible for, enter the recommended one\e[0m"

read -p "Enter the symbol (BTCUSDT recommended): " symbol
read -p "Enter interval (5 recomendated): " interval
read -p "Enter order price (min 5 USDT): " amountBuy
read -p "Enter RSI trigger value (42 recomendated): " RSI
read -p "Enter buy step (700 for BTCUSDT recomendated): " stepBuy
read -p "Enter sell step (650 for BTCUSDT recomendated): " stepSell
read -p "Sending telegram notifications (true recomendated): " send_notify
cat <<EOF > confmt/bot_config.json
{
    "symbol" : "$symbol",
    "interval" : "$interval",
    "amountBuy" : $amountBuy,
    "RSI": $RSI,
    "stepBuy": $stepBuy,
    "stepSell": $stepSell,
    "send_notify": $send_notify
}
EOF
echo -e "\e[32mConfig ready\e[0m"
echo -e "\e[33mSetting .env\e[0m"

read -p "Enter your bybit account type (UNIFIED recomendated): " ACCOUNT_TYPE
read -p "Enter your bybit api key (https://www.bybit.com/app/user/api-management): " API_KEY
read -p "Enter your bybit secret api key (https://www.bybit.com/app/user/api-management): " API_KEY_SECRET
read -p "Enter telegram bot token (if turned true for sending notifys): " BOT_TOKEN
read -p "Enter your telegram account id: " CHAT_ID

cat <<EOF > confmt/.env
ACCOUNT_TYPE=$ACCOUNT_TYPE
API_KEY_SECRET=$API_KEY_SECRET 
API_KEY=$API_KEY 
#notify 
BOT_TOKEN=$BOT_TOKEN 
CHAT_ID=$CHAT_ID
EOF
echo -e "\e[32m.env ready\e[0m"

echo -e "\e[33mOther files initializating\e[0m"
echo '{
        "laps": 0,
        "last_order": 0,
        "orders": [],
        "buy_lines": [],
        "sell_lines": []
}' >> confmt/trade_journal.json

read -p "Enter your trade bot name (cmx for example): " cont_name

echo "#!/bin/bash
sudo docker start $cont_name" >> bot_starter.sh
echo "#!/bin/bash
sudo docker stop $cont_name" >> bot_stoper.sh

chmod +x bot_starter.sh
chmod +x bot_stoper.sh

sudo docker create -d --name \
        $cont_name \
        -v $(pwd)/confmt/.env:/bot/.env \
        -v $(pwd)/confmt/bot_config.json:/bot/src/config/bot_config.json \
        -v $(pwd)/confmt/trade_journal.json:/bot/src/src/trade_journal.json \
        zemphix/trade_bot
echo -e "Use \e[33m./bot_starter.sh\e[0m for activate bot
Use \e[33m./bot_stoper.sh\e[0m for stop bot"
echo -e "\e[32mSuccess! Your bot activated!\e[0m"
