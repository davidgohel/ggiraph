dataset <- data.frame(
	x = sample(10, 20, replace = TRUE),
	y = sample(10, 20, replace = TRUE), 
	id = letters[1:20]
)
gg_rect_1 = ggplot(dataset, aes(xmin = x, xmax = x + 1, 
		ymin = y, ymax = y + 2, tooltip = id)) +
	geom_rect_interactive()

dataset = data.frame( x1 = c(1, 3, 1, 5, 4), 
	x2 = c(2, 4, 3, 6, 6), 
	y1 = c( 1, 1, 4, 1, 3), 
	y2 = c( 2, 2, 5, 3, 5), 
	t = c( 'a', 'a', 'a', 'b', 'b'), 
	r = c( 1, 2, 3, 4, 5), 
	tooltip = c("ID 1", "ID 2", "ID 3", "ID 4", "ID 5"),
	uid = c("ID 1", "ID 2", "ID 3", "ID 4", "ID 5"),
	oc = rep("function() {alert(this.getAttribute('data-id'))}", 5)
)

gg_rect_2 = ggplot() + 
	scale_x_continuous(name="x") + 
	scale_y_continuous(name="y") +
	geom_rect_interactive(data=dataset, mapping = aes(xmin = x1, xmax = x2, 
			ymin = y1, ymax = y2, fill = t, tooltip = tooltip, onclick = oc, data_id = uid ), 
		color="black", alpha=0.5) +
	geom_text(data=dataset, 
			aes(x = x1 + ( x2 - x1 ) / 2, y = y1 + ( y2 - y1 ) / 2, 
					label = r ), 
		size = 4 ) 

ggiraph(fun=print, x = gg_rect_1)
ggiraph(fun=print, x = gg_rect_2)
