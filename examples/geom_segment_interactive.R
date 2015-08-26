counts <- as.data.frame(table(x = rpois(100,5)))
counts$x <- as.numeric( as.character(counts$x) )
counts$xlab <- paste0("bar",as.character(counts$x) )

gg_segment_1 <- ggplot(data = counts, aes(x = x, y = Freq, 
			yend = 0, xend = x, tooltips = xlab ) ) + 
	geom_segment_interactive( size = I(10))

dataset = data.frame(x=c(1,2,5,6,8), 
		y=c(3,6,2,8,7), 
		vx=c(1,1.5,0.8,0.5,1.3), 
		vy=c(0.2,1.3,1.7,0.8,1.4), 
		labs = paste0("Lab", 1:5))
gg_segment_2 = ggplot() + 
		geom_segment_interactive(data=dataset, mapping=aes(x=x, y=y, 
					xend=x+vx, yend=y+vy, tooltips = labs), 
				arrow=grid::arrow(length = grid::unit(0.03, "npc")), 
				size=2, color="blue") + 
		geom_point(data=dataset, mapping=aes(x=x, y=y), size=4, shape=21, fill="white") 

ggiraph(fun=print, x = gg_segment_1)
ggiraph(fun=print, x = gg_segment_2)
