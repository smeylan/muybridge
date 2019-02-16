makeSelectedIterationFrames = function(production_dir, output_dir, sample_selections){	
	# position n items in a wide formatn on a black background, with adjustable image size and padding 
	# sample selections allows me to 
	# Note that there's some dumb work here because I am generating 450 frames, rather than copying equivalent previous frames. It's okay b/c computer's love to work

	# recursively build the composite image	
	for (i in c(1:450)){
		frame_index = (i %% 15) + 1

		print(paste('Generating frame ', frame_index))
		
		composited_image = image_read(paste(project_path,'assets/', "black_panel_768_256.png")
		
		num_panes = 6

		individual_image_width= 384
		individual_image_height = 256				
		padding = 100
		num_pads_vertical = 4
		y_offsets = padding * num_pads_vertical
		x_offsets = (c(0:(num_panes -1 ))* individual_image_width) + ((c(0:(num_panes - 1)) + 1) * padding)
		# total width is last offset + an image + padding
		output_image_width = x_offsets[length(x_offsets)] + individual_image_width + padding
		output_image_height = (num_pads_vertical*padding) + individual_image_height +  (num_pads_vertical*padding)
		
		# resize the composited image
		composited_image = composited_image %>% image_scale(paste(output_image_width,"x", output_image_height,"!", sep=''))		
		
		pane = 0 # 1-indexed pane position; because sample_selections are not purely sequential
		
		if (length(sample_selections) != num_panes){
			stop('Number of sample selections must match num_panes')	
		}
		
		for (iteration_index in sample_selections){
			pane = pane + 1
			frame_dir = paste(production_dir, iteration_index, '/', sep='')
			new_image = image_read(paste(frame_dir, iteration_index, '_',frame_index, '.jpg', sep='')) %>% image_scale(paste(individual_image_width,"x", individual_image_height,"!", sep=''))				

			x_offset = x_offsets[pane]
			y_offset = padding * num_pads_vertical
						
			#! build up the offset, +x+y
			offset = paste('+', x_offset, '+', y_offset)
			print(paste('Printing with offset:', offset))
			
			composited_image = image_composite(composited_image, new_image, offset=offset)

		}
		output_path = paste(output_dir, i,'.jpg', sep='') 
		composited_image %>% image_write(output_path, format='jpg')
	}
}


output2input  = function(output_image_dir, input_image_dir, production_image_dir, generationIndex, project_path){
	# Get the output of pix2pix placed as the right side of an image so that it can be used as input
	
	#nb input_ and output_ are with respect to the pix2pix model, not referring to this function itself

	# Generation index keeps track of the batching, the index indicates the frame. Can composite in either direction (forward sampled from a single frame, or the state of the model across frames)
	
	image_paths  = list.files(output_image_dir)
	image_paths = image_paths[grep('-outputs.png', image_paths)]
	
	for (image_path in image_paths){		
		print(paste('Processing image', image_path))

		white_panel <- image_read(paste(project_path, "assets/", "white_panel_512_256.png")
		output_image = image_read(paste(output_image_dir, image_path, sep=''))

				
		filepart_names = strsplit(gsub('.jpg','',image_path),'_')[[1]]
		generation_index = filepart_names[1]
		print(paste('generation_index: ', generation_index))
		frame_index = gsub('-outputs.png','',filepart_names[2])

		
		# Save the output alone to porduction
		production_output_path = paste( production_image_dir, as.numeric(generation_index) + 1,'_', frame_index, '.jpg', sep='')
		image_write(output_image %>% image_convert('jpg'), production_output_path)

		# Create the next input; increment the generation index
		composite2 = image_composite(white_panel, output_image, offset="+256+0") #input goes on the right
		image_write(composite2 %>% image_convert('jpg'), paste(input_image_dir, as.numeric(generation_index) + 1, '_',frame_index,'.jpg', sep=''))
	}
}

forwardSample = function(start, stop, project_path){
	for (i in c(start:stop)){
			
		print(paste('Running iteration ', i,'...', sep=''))
		# this takes the input images at model_inputs/i-1, runs it through a model that is stored at models/i, and saves the output at models/i. On the first iteration, this looks back at /0, which are the original frames
	
		print('Setting up the paths...')

		pix2pix_path = paste(project_path, 'pix2pix-tensorflow/pix2pix.py', sep='')		
		checkpoint_dir = paste(project_path, 'models/muybridge_train/', sep='')
		input_dir = paste(project_path, 'continuous_runs/model_inputs/',i-1, '/', sep='')
		output_dir = paste(project_path, 'continuous_runs/models/', i, '/', sep='')	
		
		production_dir = paste(project_path, 'continuous_runs/production/', i, '/', sep='')
		input_dir_for_next_iteration = paste(project_path, 'continuous_runs/model_inputs/',i, '/', sep='')
		
				
		# create the directories from this generation
		dir.create(output_dir)
		dir.create(production_dir)
		dir.create(input_dir_for_next_iteration)
		
		print('Running pix2pix')
						
		pix2pixCommand = paste('/usr/local/bin/python ',pix2pix_path,' --mode test --output_dir ', output_dir,' --input_dir ', input_dir, ' --checkpoint ', checkpoint_dir, sep='')
		# note that R will try to revert to /usr/bin/python otherwise
		
		system(pix2pixCommand)
				
		print ('Postprocessing to prepare for next run')
		output2input(paste(output_dir,'images/', sep=''), input_dir_for_next_iteration, production_dir, i, project_path)
	
	}
}

prepInputs = function(project_path){
	
	muybridge =  image_read(paste(project_path,'assets/','muybridge.gif', sep=''))
	
	# break out the originals and keep them in assets
	create.dir(paste(project_path, 'assets/','muybridge_frames/', sep=''))	
	for (i in c(1:length(muybridge))){
		frame = image_read(muybridge[[i]])
		image_write(image_convert(frame, 'png'), paste(project_path, 'assets/muybridge_frames/',i,'.png', 			sep=''))
	}

	# [ ] use an upscaling nn to get it to a larger size? Not sure if it's needed
	# [ ] Data augmentation would work here

	# combine left and right as input to pix2pix

	# Mapping of label -> facades. Given a new label, generate a facade. Input is label, facade pairs
	# Mapping of stiimulus -> eyetracking. Given a new stimulis, generate gaze data. Input is stimulus, gaze data
	# Here: mapping of present -> future. Given a current stimulus, generate the next one in the sequence. Input image is 	present, future
	
	create.dir(paste(project_path,'continuous_runs/', sep=''))
	create.dir(paste(project_path,'continuous_runs/model_inputs/', sep=''))
	create.dir(paste(project_path,'continuous_runs/model_inputs/0/', sep=''))

	for (i in c(1:length(muybridge))){
		white_panel <- image_read(image_path, 'assets/', 'white_panel.png', sep=''))
	
		if (i == 15){
			j = 1 # the pattern repeats: 15 predicts 1
		} else {
			j = i+1
		}
		current_frame = image_read(muybridge[[i]]) %>% image_convert('png')
		next_frame = image_read(muybridge[[j]]) %>% image_convert('png')
		
		composite1 = image_composite(white_panel, next_frame, offset="+0+0")	
		composite2 = image_composite(composite1, current_frame, offset="+300+0") #input goes on the right
		
		image_write(composite2 %>% image_convert('jpg'), paste(project_path, 'continuous_runs/model_inputs/0/',i,'.jpg', sep=''))	
	
	}
}
