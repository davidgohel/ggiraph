coord_munch <- function(coord, data, range, segment_length = 0.01) {
	if (coord$is_linear()) return(coord$transform(data, range))
	
	# range has theta and r values; get corresponding x and y values
	ranges <- coord$range(range)
	
	# Convert any infinite locations into max/min
	# Only need to work with x and y because for munching, those are the
	# only position aesthetics that are transformed
	data$x[data$x == -Inf] <- ranges$x[1]
	data$x[data$x == Inf]  <- ranges$x[2]
	data$y[data$y == -Inf] <- ranges$y[1]
	data$y[data$y == Inf]  <- ranges$y[2]
	
	# Calculate distances using coord distance metric
	dist <- coord$distance(data$x, data$y, range)
	dist[data$group[-1] != data$group[-nrow(data)]] <- NA
	
	# Munch and then transform result
	munched <- munch_data(data, dist, segment_length)
	coord$transform(munched, range)
}

# For munching, only grobs are lines and polygons: everything else is
# transformed into those special cases by the geom.
#
# @param dist distance, scaled from 0 to 1 (maximum distance on plot)
# @keyword internal
munch_data <- function(data, dist = NULL, segment_length = 0.01) {
	n <- nrow(data)
	
	if (is.null(dist)) {
		data <- add_group(data)
		dist <- dist_euclidean(data$x, data$y)
	}
	
	# How many endpoints for each old segment, not counting the last one
	extra <- pmax(floor(dist / segment_length), 1)
	extra[is.na(extra)] <- 1
	# Generate extra pieces for x and y values
	# The final point must be manually inserted at the end
	x <- c(unlist(mapply(interp, data$x[-n], data$x[-1], extra, SIMPLIFY = FALSE)), data$x[n])
	y <- c(unlist(mapply(interp, data$y[-n], data$y[-1], extra, SIMPLIFY = FALSE)), data$y[n])
	
	# Replicate other aesthetics: defined by start point but also
	# must include final point
	id <- c(rep(seq_len(nrow(data) - 1), extra), nrow(data))
	aes_df <- data[id, setdiff(names(data), c("x", "y")), drop = FALSE]
	
	plyr::unrowname(data.frame(x = x, y = y, aes_df))
}

# Interpolate.
# Interpolate n-1 evenly spaced steps (n points) from start to
# (end - (end - start) / n). end is never included in sequence.
interp <- function(start, end, n) {
	if (n == 1) return(start)
	start + seq(0, 1, length.out = n + 1)[-(n + 1)] * (end - start)
}

# Euclidean distance between points.
# NA indicates a break / terminal points
dist_euclidean <- function(x, y) {
	n <- length(x)
	
	sqrt((x[-n] - x[-1]) ^ 2 + (y[-n] - y[-1]) ^ 2)
}

