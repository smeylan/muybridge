library('magick')
source("helper.R", chdir = F)

project_path = dirname(sys.frame(1)$ofile) # this may fail in the R IDE, but will work from the command line
#project_path = '/Users/stephanmeylan/Nextcloud/Duke/muybridge/'

# Download the original GIF, split out the frames from the GIF and save to the first iteration
prepInputs(project_path)

# Clone pix2pix repo; even if training on the cluster, forward sampling from the trained model will be done locally with a loop call to Tensorflow. Assumes you have git installed already

system('git clone git@github.com:affinelayer/pix2pix-tensorflow.git')

# this should put a directory called pix2pix in the project_path. 
# install dependencies from the command line: cd to this directory and do `pip install -r requirements.txt`

# Train the pix2pix network

create.dir('models')
create.dir('models/muybridge_train')

# Option 1: Train the pix2pix network locally (may take a few days w/o a GPU)
system('train_local.sh') #run `chmod +x train_local.sh` to make it executable

# Option 2: Train the pix2pix network on the Duke cluster
# First, copy this directory at this state to the cluster
# then run `sbatch train_cluster.sh` ; assumes that user belongs to artai group and has access to a GPU
# Should submit the job specified in train_cluster, which will finish in a couple hours
# scp the results of models/muybridge_train back to the local version of muybridge_train to be able to forward sample from the model locally 

# Forward sample from the Pix2Pix model. Note that the inner loop of this initiates a TensorFlow Python process, but because the model is already trained, it's pretty low-resource, and it allows us to run Magick commands locally
forwardSample(1,100,project_path)

# Resize the original frames
for (i in c(1:15)){
	image_read(paste(project_path, 'continuous_runs/production/0/0_', i, '.png', sep='')) %>% image_scale("384x256!") %>% image_write(paste(project_path, 'continuous_runs/production/0/0_', i, '.jpg', sep=''), format =  'jpg')
}

# Build and composite the frames for animation; resize the output of pix2pix
makeSelectedIterationFrames(
	paste(project_path,"continuous_runs/production/", sep=''),
	paste(project_path,"continuous_runs/submission/", sep=''),
	sample_selections = c(0,2,3,6,9,15)
)


create.dir('video')
system(paste('cd ', project_path,"continuous_runs/submission/", "  && ffmpeg -r 18 -pattern_type sequence -i '%d.jpg'  ../video/submission.mp4')

