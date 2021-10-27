# Dynamic WD change
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("../../")
print("Working directory updated.")

# Load packages
source(file = "config/config.R")

# Import Data
avg_gas_price <- read.csv("assets/data/avgGasPrice.csv", header = TRUE)
avg_gas_price$date <- as.Date(avg_gas_price$Date.UTC., "%m/%d/%Y")
avg_gas_price$price <- avg_gas_price$Value..Wei. * 10^-9
avg_gas_price <- avg_gas_price[which(avg_gas_price$UnixTimeStamp>1438905600),]

# Plot Average Gas Price
ggplot(data=avg_gas_price, aes(x = date, y = price)) + 
  geom_line(col=darkmint) + 
  scale_y_log10(breaks = c(0,1,10,50,100,250,500,1000))+
  labs(
    x = "Date",
    y = "Mean Gas Prices in Gwei" ,
    title = "Ethereum Gas Prices",
    subtitle = "Average Gas Prices (Daily Mean), Source: Etherscan.io"
  )
  
ggsave("assets/images/average_gas_prices.png", width = 10, height = 6)
