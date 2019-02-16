# A bad function for compositing frames. Too hard for humans to process 15 up, and all frames descend into chaos.


# makeFrame = function(production_dir, iteration_index, output_dir){	
	
	# frame_dir = paste(production_dir, iteration_index, '/', sep='')
	# print(paste('Generating frame ', iteration_index))

	# composited_image = image_read("~/Nextcloud/Duke/past2future/data/white_panel_1280_768.png")

	# # recursively build the composite image
	# for (frame_index in c(1:15)){
		
		# new_image = image_read(paste(frame_dir, iteration_index, '_',frame_index, '.jpg', sep=''))

		# x_offset = ((frame_index -1) %% 5) * 256
		# y_offset = floor((frame_index -1) /5) * 256
					
		# #! build up the offset, +x+y
		# offset = paste('+', x_offset, '+', y_offset)
		# print(paste('Printing with offset:', offset))
		
		# composited_image = image_composite(composited_image, new_image, offset=offset)
		
	# }
	# output_path = paste(output_dir, iteration_index,'.jpg', sep='') 
	# composited_image %>% image_write(output_path, format='jpg')

# }

# for (i in c(1:100)){
	# makeFrame('/Users/stephanmeylan/Nextcloud/Duke/past2future/continuous_runs/production/', i, '/Users/stephanmeylan/Nextcloud/Duke/past2future/continuous_runs/final_frames/')		
# } 



# A slightly better function for compositing frames: Too hard for humans to process 15 up, but at least some frames do not descend into chaos


# makeIterationFrames = function(production_dir, output_dir){	
	# # each position in the 5*3 video space is from all successive frames in a single iteration
	# # This only works for the first 15	
	# # Note that there is different encapsulation for this one	

	# # recursively build the composite image	
	# for (i in c(1:450)){
		# frame_index = (i %% 15) + 1

		# print(paste('Generating frame ', frame_index))
		
		# composited_image = image_read("~/Nextcloud/Duke/past2future/data/white_panel_1280_768.png")
		# for (iteration_index in c(1:15)){
			# frame_dir = paste(production_dir, iteration_index, '/', sep='')
			# new_image = image_read(paste(frame_dir, iteration_index, '_',frame_index, '.jpg', sep=''))				

			# x_offset = ((iteration_index -1) %% 5) * 256
			# y_offset = floor((iteration_index -1) /5) * 256
						
			# #! build up the offset, +x+y
			# offset = paste('+', x_offset, '+', y_offset)
			# print(paste('Printing with offset:', offset))
			
			# composited_image = image_composite(composited_image, new_image, offset=offset)

		# }
		# output_path = paste(output_dir, i,'.jpg', sep='') 
		# composited_image %>% image_write(output_path, format='jpg')
	# }
# }

# makeIterationFrames("/Users/stephanmeylan/Nextcloud/Duke/past2future/continuous_runs/production/","/Users/stephanmeylan/Nextcloud/Duke/past2future/continuous_runs/iteration_animations/")

# ffmpeg -r 12 -pattern_type sequence -i '%d.jpg' -filter:v minterpolate ../video/first15_output.mp4
# ffmpeg -r 12 -pattern_type sequence -i '%d.jpg' -filter:v tblend ../video/first15_tblend_output.mp4

# #not as pronounced. Just do 3


# An attempt to interpolate between sequential frames - looks like trash

# interpolated_frames <- image_morph(c(image_read(muybridge[[1]]), image_read(muybridge[[2]])), frames = 10)


# for (i in c(1:length(interpolated_frames))){
	# frame = image_read(interpolated_frames[[i]])
	# image_write(image_convert(frame, 'png'), paste('~/Nextcloud/Duke/past2future/interpolated_muybridge_frames/',i,'.png', sep=''))
# }