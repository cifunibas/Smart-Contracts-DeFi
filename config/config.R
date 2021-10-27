# Load Packages
require(data.table)
require(ggplot2)

print("Packages up-to-date.")

# Style Specs
theme_set(
  theme_light(base_size = 12) + theme( 
    legend.justification=c(0,1),
    legend.title = element_blank(),
    legend.position=c(0.02, 0.98),
    legend.key = element_blank(),
    axis.text.x = element_text(angle=45, hjust=1),
    panel.border = element_rect(colour = "black", fill=NA),
    legend.box.background = element_rect(colour = "black")
  )
)

# Color Options
highlight <- rgb(0.65,0.84,0.82, maxColorValue = 1)
focus <- rgb(0.72, 0, 0, maxColorValue = 1)
lightred <- rgb(0.8,0.5,0.5, maxColorValue = 1)
midgray <- rgb(190,195,200, maxColorValue = 255)

# UniBas Main Colors
mint <- rgb(165,215,210, maxColorValue = 255)
anthracite <- rgb(45,55,60, maxColorValue = 255)
red <- rgb(210,5,55, maxColorValue = 255)

# UniBas Color Palette (for graphics)
strongmint <- rgb(30,165,165, maxColorValue = 255)
darkmint <- rgb(0,110,110, maxColorValue = 255)
softanthracite <- rgb(140,145,150, maxColorValue = 255)
brightanthracite <- rgb(190,195,200, maxColorValue = 255)
softred <- rgb(235,130,155, maxColorValue = 255)

print("Style Sheet ready.")
